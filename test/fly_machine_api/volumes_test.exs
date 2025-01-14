defmodule FlyMachineApi.VolumesTest do
  use FlyCase

  @moduletag :capture_log
  @test_app_name "test-app-vcr"

  describe "list_volumes/3" do
    test "returns list of volumes" do
      use_cassette "volumes/list_volumes" do
        {:ok, volumes} = FlyMachineApi.list_volumes(@test_app_name)
        assert is_list(volumes)

        if length(volumes) > 0 do
          volume = List.first(volumes)
          assert Map.has_key?(volume, "id")
          assert Map.has_key?(volume, "name")
          assert Map.has_key?(volume, "size_gb")
          assert Map.has_key?(volume, "region")
          assert Map.has_key?(volume, "state")
        end
      end
    end

    test "returns list of volumes with summary" do
      use_cassette "volumes/list_volumes_summary" do
        {:ok, volumes} = FlyMachineApi.list_volumes(@test_app_name, summary: true)
        assert is_list(volumes)
      end
    end
  end

  describe "create_volume/3" do
    test "creates a new volume" do
      volume_params = %{
        name: "test-volume",
        size_gb: 1,
        region: "ord",
        encrypted: true
      }

      use_cassette "volumes/create_volume" do
        {:ok, volume} = FlyMachineApi.create_volume(@test_app_name, volume_params)
        assert Map.has_key?(volume, "id")
        assert volume["name"] == volume_params.name
        assert volume["size_gb"] == volume_params.size_gb
        assert volume["region"] == volume_params.region
        assert volume["encrypted"] == volume_params.encrypted
      end
    end
  end

  describe "get_volume/3" do
    test "returns volume details" do
      volume_params = %{
        name: "test-volume-get",
        size_gb: 1,
        region: "ord"
      }

      use_cassette "volumes/get_volume_flow" do
        # Create a volume first
        {:ok, created_volume} = FlyMachineApi.create_volume(@test_app_name, volume_params)
        assert Map.has_key?(created_volume, "id")

        # Then get its details
        {:ok, volume} = FlyMachineApi.get_volume(@test_app_name, created_volume["id"])
        assert volume["id"] == created_volume["id"]
        assert volume["name"] == volume_params.name
        assert volume["size_gb"] == volume_params.size_gb
        assert volume["region"] == volume_params.region
      end
    end

    test "returns error for non-existent volume" do
      use_cassette "volumes/get_volume_not_found" do
        assert {:error, "Unexpected error occurred"} =
                 FlyMachineApi.get_volume(@test_app_name, "non-existent-volume")
      end
    end
  end

  describe "update_volume/4" do
    test "updates volume configuration" do
      volume_params = %{
        name: "test-volume-update",
        size_gb: 1,
        region: "ord"
      }

      update_params = %{
        auto_backup_enabled: true,
        snapshot_retention: 5
      }

      use_cassette "volumes/update_volume_flow" do
        # Create a volume first
        {:ok, created_volume} = FlyMachineApi.create_volume(@test_app_name, volume_params)
        assert Map.has_key?(created_volume, "id")

        # Then update it
        {:ok, volume} =
          FlyMachineApi.update_volume(@test_app_name, created_volume["id"], update_params)

        assert volume["auto_backup_enabled"] == update_params.auto_backup_enabled
        assert volume["snapshot_retention"] == update_params.snapshot_retention
      end
    end
  end

  describe "delete_volume/3" do
    test "deletes a volume" do
      volume_params = %{
        name: "test-volume-delete",
        size_gb: 1,
        region: "ord"
      }

      use_cassette "volumes/delete_volume_flow" do
        # Create a volume first
        {:ok, created_volume} = FlyMachineApi.create_volume(@test_app_name, volume_params)
        assert Map.has_key?(created_volume, "id")

        # Then delete it
        {:ok, _} = FlyMachineApi.delete_volume(@test_app_name, created_volume["id"])
      end
    end

    test "returns error for non-existent volume" do
      use_cassette "volumes/delete_volume_not_found" do
        assert {:error, "Unexpected error occurred"} =
                 FlyMachineApi.delete_volume(@test_app_name, "non-existent-volume")
      end
    end
  end

  describe "extend_volume/4" do
    test "extends volume size" do
      volume_params = %{
        name: "test-volume-extend",
        size_gb: 1,
        region: "ord"
      }

      use_cassette "volumes/extend_volume_flow" do
        # Create a volume first
        {:ok, created_volume} = FlyMachineApi.create_volume(@test_app_name, volume_params)
        assert Map.has_key?(created_volume, "id")

        # Then extend it
        {:ok, response} = FlyMachineApi.extend_volume(@test_app_name, created_volume["id"], 2)
        assert Map.has_key?(response, "needs_restart")
        assert Map.has_key?(response, "volume")
        assert response["volume"]["size_gb"] == 2
      end
    end
  end

  describe "list_snapshots/3" do
    test "returns list of snapshots" do
      volume_params = %{
        name: "test-volume-snapshots",
        size_gb: 1,
        region: "ord"
      }

      use_cassette "volumes/list_snapshots_flow" do
        # Create a volume first
        {:ok, created_volume} = FlyMachineApi.create_volume(@test_app_name, volume_params)
        assert Map.has_key?(created_volume, "id")

        # Then list its snapshots
        {:ok, snapshots} =
          FlyMachineApi.list_volume_snapshots(@test_app_name, created_volume["id"])

        assert is_list(snapshots)
      end
    end
  end

  describe "create_snapshot/3" do
    test "creates a new snapshot" do
      volume_params = %{
        name: "test-volume-snapshot",
        size_gb: 1,
        region: "ord"
      }

      use_cassette "volumes/create_snapshot_flow" do
        # Create a volume first
        {:ok, created_volume} = FlyMachineApi.create_volume(@test_app_name, volume_params)
        assert Map.has_key?(created_volume, "id")

        # Then create a snapshot
        {:ok, _} = FlyMachineApi.create_volume_snapshot(@test_app_name, created_volume["id"])
      end
    end
  end
end
