defmodule FlyMachineClient.MachinesTest do
  use FlyCase

  @moduletag :capture_log
  @test_app_name "test-machine-app-vcr"
  @node_image "node:20-slim"

  setup do
    app_params = %{
      app_name: @test_app_name,
      org_slug: "personal",
      network: "custom-network",
      enable_subdomains: true
    }

    machine_params = %{
      app_name: @test_app_name,
      name: "test-machine",
      region: "ewr",
      config: %{
        image: @node_image,
        env: %{
          "NODE_ENV" => "test"
        },
        services: [
          %{
            "ports" => [
              %{
                "port" => 3000,
                "handlers" => ["http"]
              }
            ],
            "protocol" => "tcp"
          }
        ]
      }
    }

    {:ok, app_params: app_params, machine_params: machine_params}
  end

  describe "create_machine/2" do
    test "creates a new machine", %{app_params: app_params, machine_params: machine_params} do
      use_cassette "machines/create_flow" do
        # Create app first
        {:ok, _app} = FlyMachineClient.create_app(app_params)

        # Create machine
        {:ok, machine} = FlyMachineClient.create_machine(machine_params)
        assert Map.has_key?(machine, "id")
        assert Map.has_key?(machine, "name")
        assert Map.has_key?(machine, "state")
        assert Map.has_key?(machine, "region")
        assert machine["config"]["image"] == @node_image
      end
    end

    test "returns error with invalid params", %{app_params: app_params} do
      use_cassette "machines/create_machine_invalid" do
        # Create app first
        {:ok, _app} = FlyMachineClient.create_app(app_params)

        # Try to create machine with invalid params
        invalid_params = %{app_name: @test_app_name}
        assert {:error, _} = FlyMachineClient.create_machine(invalid_params)
      end
    end
  end

  describe "list_machines/2" do
    test "lists machines for an app", %{app_params: app_params, machine_params: machine_params} do
      use_cassette "machines/list_flow" do
        # Create app and machine first
        {:ok, _app} = FlyMachineClient.create_app(app_params)
        {:ok, created_machine} = FlyMachineClient.create_machine(machine_params)

        # List machines
        {:ok, machines} = FlyMachineClient.list_machines(@test_app_name)
        assert is_list(machines)
        assert length(machines) > 0

        # Find our created machine
        found_machine = Enum.find(machines, &(&1["id"] == created_machine["id"]))
        assert found_machine
        assert found_machine["name"] == machine_params.name
        assert found_machine["region"] == machine_params.region
      end
    end

    test "returns empty list for app with no machines", %{app_params: app_params} do
      use_cassette "machines/list_machines_empty" do
        # Create app without machines
        {:ok, _app} = FlyMachineClient.create_app(app_params)

        # List machines
        {:ok, machines} = FlyMachineClient.list_machines(@test_app_name)
        assert is_list(machines)
        assert Enum.empty?(machines)
      end
    end
  end

  describe "get_machine/3" do
    test "gets machine details", %{app_params: app_params, machine_params: machine_params} do
      use_cassette "machines/get_flow" do
        # Create app and machine first
        {:ok, _app} = FlyMachineClient.create_app(app_params)
        {:ok, created_machine} = FlyMachineClient.create_machine(machine_params)

        # Get machine details
        {:ok, machine} = FlyMachineClient.get_machine(@test_app_name, created_machine["id"])
        assert machine["id"] == created_machine["id"]
        assert machine["name"] == machine_params.name
        assert machine["region"] == machine_params.region
        assert machine["config"]["image"] == @node_image
      end
    end

    test "returns error for non-existent machine", %{app_params: app_params} do
      use_cassette "machines/get_machine_not_found" do
        # Create app first
        {:ok, _app} = FlyMachineClient.create_app(app_params)

        # Try to get non-existent machine
        assert {:error, _} = FlyMachineClient.get_machine(@test_app_name, "non-existent-id")
      end
    end
  end

  describe "update_machine/2" do
    test "updates machine configuration", %{
      app_params: app_params,
      machine_params: machine_params
    } do
      use_cassette "machines/update_flow" do
        # Create app and machine first
        {:ok, _app} = FlyMachineClient.create_app(app_params)
        {:ok, created_machine} = FlyMachineClient.create_machine(machine_params)

        # Update machine
        update_params = %{
          app_name: @test_app_name,
          machine_id: created_machine["id"],
          config: %{
            env: %{
              "NODE_ENV" => "production"
            }
          }
        }

        {:ok, updated_machine} = FlyMachineClient.update_machine(update_params)
        assert updated_machine["id"] == created_machine["id"]
        assert updated_machine["config"]["env"]["NODE_ENV"] == "production"
      end
    end
  end

  describe "machine lifecycle operations" do
    setup %{app_params: app_params, machine_params: machine_params} do
      use_cassette "machines/lifecycle_setup" do
        {:ok, _app} = FlyMachineClient.create_app(app_params)
        {:ok, machine} = FlyMachineClient.create_machine(machine_params)
        {:ok, %{machine: machine}}
      end
    end

    test "stop_machine/3", %{machine: machine} do
      use_cassette "machines/stop_flow" do
        assert {:ok, stopped_machine} =
                 FlyMachineClient.stop_machine(@test_app_name, machine["id"])

        assert stopped_machine["state"] == "stopped"
      end
    end

    test "start_machine/3", %{machine: machine} do
      use_cassette "machines/start_flow" do
        # Stop first
        {:ok, _} = FlyMachineClient.stop_machine(@test_app_name, machine["id"])

        # Then start
        assert {:ok, started_machine} =
                 FlyMachineClient.start_machine(@test_app_name, machine["id"])

        assert started_machine["state"] == "started"
      end
    end

    test "restart_machine/3", %{machine: machine} do
      use_cassette "machines/restart_flow" do
        assert {:ok, restarted_machine} =
                 FlyMachineClient.restart_machine(@test_app_name, machine["id"])

        assert restarted_machine["state"] == "started"
      end
    end

    test "signal_machine/4", %{machine: machine} do
      use_cassette "machines/signal_flow" do
        assert {:ok, signaled_machine} =
                 FlyMachineClient.signal_machine(@test_app_name, machine["id"], "SIGTERM")

        assert signaled_machine["id"] == machine["id"]
      end
    end

    test "suspend_machine/3", %{machine: machine} do
      use_cassette "machines/suspend_flow" do
        assert {:ok, suspended_machine} =
                 FlyMachineClient.suspend_machine(@test_app_name, machine["id"])

        assert suspended_machine["state"] == "suspended"
      end
    end

    test "wait_for_machine_state/6", %{machine: machine} do
      use_cassette "machines/wait_state_flow" do
        # Stop the machine first
        {:ok, _} = FlyMachineClient.stop_machine(@test_app_name, machine["id"])

        # Start and wait for it to be ready
        {:ok, _} = FlyMachineClient.start_machine(@test_app_name, machine["id"])

        assert {:ok, ready_machine} =
                 FlyMachineClient.wait_for_machine_state(
                   @test_app_name,
                   machine["id"],
                   machine["instance_id"],
                   "started",
                   30
                 )

        assert ready_machine["state"] == "started"
      end
    end
  end

  describe "destroy_machine/3" do
    test "destroys a machine", %{app_params: app_params, machine_params: machine_params} do
      use_cassette "machines/destroy_flow" do
        # Create app and machine first
        {:ok, _app} = FlyMachineClient.create_app(app_params)
        {:ok, created_machine} = FlyMachineClient.create_machine(machine_params)

        # Destroy machine
        assert {:ok, _} = FlyMachineClient.destroy_machine(@test_app_name, created_machine["id"])

        # Verify machine is gone
        assert {:error, _} = FlyMachineClient.get_machine(@test_app_name, created_machine["id"])
      end
    end

    test "returns error for non-existent machine", %{app_params: app_params} do
      use_cassette "machines/destroy_machine_not_found" do
        # Create app first
        {:ok, _app} = FlyMachineClient.create_app(app_params)

        # Try to destroy non-existent machine
        assert {:error, _} = FlyMachineClient.destroy_machine(@test_app_name, "non-existent-id")
      end
    end
  end
end
