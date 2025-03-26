defmodule FlyMachineClient.MachinesTest do
  use FlyCase

  @moduletag :capture_log
  @base_app_name "test-machine-app-vcr"
  @node_image "node:20-slim"

  setup do
    base_app_params = %{
      org_slug: "personal",
      network: "custom-network",
      enable_subdomains: true
    }

    base_machine_params = %{
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

    {:ok, base_app_params: base_app_params, base_machine_params: base_machine_params}
  end

  describe "create_machine/2" do
    setup %{base_app_params: base_app_params, base_machine_params: base_machine_params} do
      app_name = "#{@base_app_name}-create"
      app_params = Map.put(base_app_params, :app_name, app_name)
      machine_params = Map.put(base_machine_params, :app_name, app_name)
      {:ok, app_params: app_params, machine_params: machine_params}
    end

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

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end

    test "returns error with invalid params", %{app_params: app_params} do
      use_cassette "machines/create_machine_invalid" do
        # Create app first
        {:ok, _app} = FlyMachineClient.create_app(app_params)

        # Try to create machine with invalid params
        invalid_params = %{app_name: app_params.app_name}
        assert {:error, _} = FlyMachineClient.create_machine(invalid_params)

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end
  end

  describe "list_machines/2" do
    setup %{base_app_params: base_app_params, base_machine_params: base_machine_params} do
      app_name = "#{@base_app_name}-list"
      app_params = Map.put(base_app_params, :app_name, app_name)
      machine_params = Map.put(base_machine_params, :app_name, app_name)
      {:ok, app_params: app_params, machine_params: machine_params}
    end

    test "lists machines for an app", %{app_params: app_params, machine_params: machine_params} do
      use_cassette "machines/list_flow" do
        # Create app and machine first
        {:ok, _app} = FlyMachineClient.create_app(app_params)
        {:ok, created_machine} = FlyMachineClient.create_machine(machine_params)

        # List machines
        {:ok, machines} = FlyMachineClient.list_machines(app_params.app_name)
        assert is_list(machines)
        assert length(machines) > 0

        # Find our created machine
        found_machine = Enum.find(machines, &(&1["id"] == created_machine["id"]))
        assert found_machine
        assert found_machine["name"] == machine_params.name
        assert found_machine["region"] == machine_params.region

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end

    test "returns empty list for app with no machines", %{app_params: app_params} do
      use_cassette "machines/list_machines_empty" do
        # Create app without machines
        {:ok, _app} = FlyMachineClient.create_app(app_params)

        # List machines
        {:ok, machines} = FlyMachineClient.list_machines(app_params.app_name)
        assert is_list(machines)
        assert Enum.empty?(machines)

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)

        # Returns 500 when there are no machines - but this may be expected

        # * test list_machines/2 returns empty list for app with no machines (5144.3ms) [L#99]

        # 1) test list_machines/2 returns empty list for app with no machines (FlyMachineClient.MachinesTest)
        #    test/fly_machine_client/machines_test.exs:99
        #    ** (MatchError) no match of right hand side value: {:error, "Unexpected error occurred"}
        #    code: {:ok, _app} = FlyMachineClient.create_app(app_params)
        #    stacktrace:
        #      test/fly_machine_client/machines_test.exs:102: (test)

        #    The following output was logged:

        #    08:36:32.547 [warning] Fly API request failed

        #    08:36:32.547 [warning] Fly API error in create_app: 500 - Unexpected error occurred
      end
    end
  end

  describe "get_machine/3" do
    setup %{base_app_params: base_app_params, base_machine_params: base_machine_params} do
      app_name = "#{@base_app_name}-get"
      app_params = Map.put(base_app_params, :app_name, app_name)
      machine_params = Map.put(base_machine_params, :app_name, app_name)
      {:ok, app_params: app_params, machine_params: machine_params}
    end

    test "gets machine details", %{app_params: app_params, machine_params: machine_params} do
      use_cassette "machines/get_flow" do
        # Create app and machine first
        {:ok, _app} = FlyMachineClient.create_app(app_params)
        {:ok, created_machine} = FlyMachineClient.create_machine(machine_params)

        # Get machine details
        {:ok, machine} = FlyMachineClient.get_machine(app_params.app_name, created_machine["id"])
        assert machine["id"] == created_machine["id"]
        assert machine["name"] == machine_params.name
        assert machine["region"] == machine_params.region
        assert machine["config"]["image"] == @node_image

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end

    test "returns error for non-existent machine", %{app_params: app_params} do
      use_cassette "machines/get_machine_not_found" do
        # Create app first
        {:ok, _app} = FlyMachineClient.create_app(app_params)

        # Try to get non-existent machine
        assert {:error, _} = FlyMachineClient.get_machine(app_params.app_name, "non-existent-id")

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end
  end

  describe "update_machine/2" do
    setup %{base_app_params: base_app_params, base_machine_params: base_machine_params} do
      app_name = "#{@base_app_name}-update"
      app_params = Map.put(base_app_params, :app_name, app_name)
      machine_params = Map.put(base_machine_params, :app_name, app_name)
      {:ok, app_params: app_params, machine_params: machine_params}
    end

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
          app_name: app_params.app_name,
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

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end
  end

  describe "machine lifecycle operations" do
    setup %{base_app_params: base_app_params, base_machine_params: base_machine_params} do
      app_name = "#{@base_app_name}-lifecycle-#{:rand.uniform(1000)}"
      app_params = Map.put(base_app_params, :app_name, app_name)
      machine_params = Map.put(base_machine_params, :app_name, app_name)

      use_cassette "machines/lifecycle_setup" do
        {:ok, _app} = FlyMachineClient.create_app(app_params)
        {:ok, machine} = FlyMachineClient.create_machine(machine_params)
        # Wait for machine to be fully started
        {:ok, started_machine} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            machine["id"],
            machine["instance_id"],
            "started",
            30
          )

        {:ok, %{machine: started_machine, app_params: app_params}}
      end
    end

    test "stop_machine/3", %{machine: machine, app_params: app_params} do
      use_cassette "machines/stop_flow" do
        {:ok, stopped_machine} = FlyMachineClient.stop_machine(app_params.app_name, machine["id"])

        # Wait for machine to be fully stopped
        {:ok, final_machine} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            machine["id"],
            machine["instance_id"],
            "stopped",
            30
          )

        assert final_machine["state"] == "stopped"

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end

    test "start_machine/3", %{machine: machine, app_params: app_params} do
      use_cassette "machines/start_flow" do
        # Stop first and wait for stopped state
        {:ok, _} = FlyMachineClient.stop_machine(app_params.app_name, machine["id"])

        {:ok, _} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            machine["id"],
            machine["instance_id"],
            "stopped",
            30
          )

        # Then start and wait for started state
        {:ok, _} = FlyMachineClient.start_machine(app_params.app_name, machine["id"])

        {:ok, final_machine} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            machine["id"],
            machine["instance_id"],
            "started",
            30
          )

        assert final_machine["state"] == "started"

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end

    test "restart_machine/3", %{machine: machine, app_params: app_params} do
      use_cassette "machines/restart_flow" do
        # Ensure machine is started first
        {:ok, _} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            machine["id"],
            machine["instance_id"],
            "started",
            30
          )

        {:ok, _} = FlyMachineClient.restart_machine(app_params.app_name, machine["id"])

        # Wait for machine to be restarted
        {:ok, final_machine} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            machine["id"],
            machine["instance_id"],
            "started",
            30
          )

        assert final_machine["state"] == "started"

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end

    test "signal_machine/4", %{machine: machine, app_params: app_params} do
      use_cassette "machines/signal_flow" do
        # Ensure machine is started first
        {:ok, _} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            machine["id"],
            machine["instance_id"],
            "started",
            30
          )

        {:ok, signaled_machine} =
          FlyMachineClient.signal_machine(app_params.app_name, machine["id"], "SIGTERM")

        assert signaled_machine["id"] == machine["id"]

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end

    test "suspend_machine/3", %{machine: machine, app_params: app_params} do
      use_cassette "machines/suspend_flow" do
        # Ensure machine is started first
        {:ok, _} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            machine["id"],
            machine["instance_id"],
            "started",
            30
          )

        {:ok, _} = FlyMachineClient.suspend_machine(app_params.app_name, machine["id"])

        # Wait for machine to be suspended
        {:ok, final_machine} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            machine["id"],
            machine["instance_id"],
            "suspended",
            30
          )

        assert final_machine["state"] == "suspended"

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end

    test "wait_for_machine_state/6", %{machine: machine, app_params: app_params} do
      use_cassette "machines/wait_state_flow" do
        # Ensure machine is started first
        {:ok, started_machine} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            machine["id"],
            machine["instance_id"],
            "started",
            30
          )

        assert started_machine["state"] == "started"

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end
  end

  describe "destroy_machine/3" do
    setup %{base_app_params: base_app_params, base_machine_params: base_machine_params} do
      app_name = "#{@base_app_name}-destroy-#{:rand.uniform(1000)}"
      app_params = Map.put(base_app_params, :app_name, app_name)
      machine_params = Map.put(base_machine_params, :app_name, app_name)
      {:ok, app_params: app_params, machine_params: machine_params}
    end

    test "destroys a machine", %{app_params: app_params, machine_params: machine_params} do
      use_cassette "machines/destroy_flow" do
        # Create app and machine first
        {:ok, _app} = FlyMachineClient.create_app(app_params)
        {:ok, created_machine} = FlyMachineClient.create_machine(machine_params)

        # Wait for machine to be started
        {:ok, _} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            created_machine["id"],
            created_machine["instance_id"],
            "started",
            30
          )

        # Stop machine first
        {:ok, _} = FlyMachineClient.stop_machine(app_params.app_name, created_machine["id"])

        {:ok, _} =
          FlyMachineClient.wait_for_machine_state(
            app_params.app_name,
            created_machine["id"],
            created_machine["instance_id"],
            "stopped",
            30
          )

        # Now destroy
        assert {:ok, _} =
                 FlyMachineClient.destroy_machine(app_params.app_name, created_machine["id"])

        # Verify machine is gone
        assert {:error, _} =
                 FlyMachineClient.get_machine(app_params.app_name, created_machine["id"])

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end

    test "returns error for non-existent machine", %{app_params: app_params} do
      use_cassette "machines/destroy_machine_not_found" do
        # Create app first
        {:ok, _app} = FlyMachineClient.create_app(app_params)

        # Try to destroy non-existent machine
        assert {:error, _} =
                 FlyMachineClient.destroy_machine(app_params.app_name, "non-existent-id")

        # Clean up
        {:ok, _} = FlyMachineClient.destroy_app(app_params.app_name)
      end
    end
  end
end
