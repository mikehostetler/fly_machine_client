defmodule FlyMachineApi.AppsTest do
  use FlyCase

  @moduletag :capture_log
  @test_app_name "test-app-vcr"

  describe "create_app/2" do
    test "creates a new app" do
      app_params = %{
        app_name: @test_app_name,
        org_slug: "personal",
        network: "custom-network",
        enable_subdomains: true
      }

      use_cassette "apps/create_app" do
        {:ok, app} = FlyMachineApi.create_app(app_params)
        assert Map.has_key?(app, "id")
        assert Map.has_key?(app, "created_at")
      end
    end

    test "returns error with invalid params" do
      app_params = %{
        network: "custom-network",
        enable_subdomains: true
      }

      assert {:error, %NimbleOptions.ValidationError{}} = FlyMachineApi.create_app(app_params)
    end
  end

  describe "list_apps/2" do
    test "returns list of apps" do
      app_params = %{
        app_name: "#{@test_app_name}-list",
        org_slug: "personal",
        network: "custom-network",
        enable_subdomains: true
      }

      use_cassette "apps/list_flow" do
        # Create an app first
        {:ok, created_app} = FlyMachineApi.create_app(app_params)
        assert Map.has_key?(created_app, "id")

        # Then list apps
        {:ok, response} = FlyMachineApi.list_apps()
        assert Map.has_key?(response, "apps")
        assert Map.has_key?(response, "total_apps")

        apps = response["apps"]
        assert length(apps) > 0

        # Find our created app in the list
        created_app = Enum.find(apps, &(&1["name"] == app_params.app_name))
        assert created_app
        assert Map.has_key?(created_app, "id")
        assert Map.has_key?(created_app, "name")
        assert Map.has_key?(created_app, "machine_count")
        assert Map.has_key?(created_app, "network")
      end
    end
  end

  describe "get_app/2" do
    test "returns app details" do
      app_params = %{
        app_name: "#{@test_app_name}-get",
        org_slug: "personal",
        network: "custom-network",
        enable_subdomains: true
      }

      use_cassette "apps/get_flow" do
        # Create an app first
        {:ok, created_app} = FlyMachineApi.create_app(app_params)
        assert Map.has_key?(created_app, "id")

        # Then get its details
        {:ok, app} = FlyMachineApi.get_app(app_params.app_name)
        assert app["name"] == app_params.app_name
        assert app["status"] == "pending"
      end
    end

    test "returns error for non-existent app" do
      use_cassette "apps/get_app_not_found" do
        assert {:error, "Unexpected error occurred"} = FlyMachineApi.get_app("non-existent-app")
      end
    end
  end

  describe "destroy_app/2" do
    test "deletes an app" do
      app_params = %{
        app_name: "#{@test_app_name}-destroy",
        org_slug: "personal",
        network: "custom-network",
        enable_subdomains: true
      }

      use_cassette "apps/destroy_flow" do
        # Create an app first
        {:ok, created_app} = FlyMachineApi.create_app(app_params)
        assert Map.has_key?(created_app, "id")

        # Then delete it
        assert {:ok, ""} = FlyMachineApi.destroy_app(app_params.app_name)
      end
    end

    test "returns error for non-existent app" do
      use_cassette "apps/destroy_app_not_found" do
        assert {:error, "Unexpected error occurred"} =
                 FlyMachineApi.destroy_app("non-existent-app")
      end
    end
  end
end
