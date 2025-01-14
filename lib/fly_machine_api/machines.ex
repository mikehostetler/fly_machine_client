defmodule FlyMachineApi.Machines do
  @moduledoc """
  Module for managing machines on Fly.io.
  """

  import FlyMachineApi.Helpers

  @update_machine_options [
    app_name: [type: :string, required: true],
    machine_id: [type: :string, required: true],
    config: [type: :map, required: false],
    name: [type: :string, required: false],
    region: [type: :string, required: false],
    image: [type: :string, required: false],
    env: [type: :map, required: false],
    services: [type: :list, required: false],
    metadata: [type: :map, required: false]
  ]

  @doc """
  Lists all machines for a given app.

  ## Parameters

  - app_name: The name of the app to list machines for.
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, machines} on success, where machines is a list of machine data.
  {:error, error()} on failure.
  """
  @spec list_machines(String.t(), FlyMachineApi.options()) :: FlyMachineApi.response()
  def list_machines(app_name, opts \\ []) do
    client = FlyMachineApi.new(opts)
    client |> Tesla.get("/apps/#{app_name}/machines") |> handle_request(:list_machines)
  end

  @doc """
  Gets details of a specific machine.

  ## Parameters

  - app_name: The name of the app the machine belongs to.
  - machine_id: The ID of the machine to retrieve.
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, machine} on success, where machine is the machine data.
  {:error, error()} on failure.
  """
  @spec get_machine(String.t(), String.t(), FlyMachineApi.options()) :: FlyMachineApi.response()
  def get_machine(app_name, machine_id, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.get("/apps/#{app_name}/machines/#{machine_id}")
    |> handle_request(:get_machine)
  end

  @doc """
  Creates a new machine in a Fly.io app.

  ## Parameters

  - params: A map containing the machine creation parameters:
    - app_name: The name of the app to create the machine in (required)
    - name: The name for the machine (optional)
    - region: The region to deploy the machine to (optional)
    - config: Machine configuration map (required)
    - image: Docker image to use (required)
    - env: Environment variables map (optional)
    - services: List of services (optional)
    - metadata: Metadata map (optional)
  - opts: Optional list of options

  ## Returns

  {:ok, machine} on success where machine is the created machine data
  {:error, error} on failure
  """
  @spec create_machine(map(), FlyMachineApi.options()) :: FlyMachineApi.response()
  def create_machine(params, opts \\ []) do
    client = FlyMachineApi.new(opts)
    app_name = Map.get(params, :app_name)

    client
    |> Tesla.post("/apps/#{app_name}/machines", params)
    |> handle_request(:create_machine)
  end

  @doc """
  Updates an existing machine in a Fly.io app.

  ## Parameters

  - params: A map containing the machine update parameters:
    - app_name: The name of the app containing the machine (required)
    - machine_id: The ID of the machine to update (required)
    - name: New name for the machine (optional)
    - region: New region for the machine (optional)
    - config: Updated machine configuration map (optional)
    - image: New Docker image to use (optional)
    - env: Updated environment variables map (optional)
    - services: Updated list of services (optional)
    - metadata: Updated metadata map (optional)
  - opts: Optional list of options

  ## Returns

  {:ok, machine} on success where machine is the updated machine data
  {:error, error} on failure
  """
  @spec update_machine(map(), FlyMachineApi.options()) :: FlyMachineApi.response()
  def update_machine(params, opts \\ []) do
    client = FlyMachineApi.new(opts)

    with {:ok, validated_params} <- validate_params(params, @update_machine_options) do
      app_name = Map.get(validated_params, :app_name)
      machine_id = Map.get(validated_params, :machine_id)
      update_params = Map.drop(validated_params, [:app_name, :machine_id])

      client
      |> Tesla.patch("/apps/#{app_name}/machines/#{machine_id}", update_params)
      |> handle_request(:update_machine)
    end
  end

  @doc """
  Destroys (deletes) a machine.

  ## Parameters

  - app_name: The name of the app the machine belongs to.
  - machine_id: The ID of the machine to destroy.
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, nil} on success.
  {:error, error()} on failure.
  """
  @spec destroy_machine(String.t(), String.t(), FlyMachineApi.options()) ::
          FlyMachineApi.response()
  def destroy_machine(app_name, machine_id, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.delete("/apps/#{app_name}/machines/#{machine_id}")
    |> handle_request(:destroy_machine)
  end

  @doc """
  Restarts a machine.

  ## Parameters

  - app_name: The name of the app the machine belongs to.
  - machine_id: The ID of the machine to restart.
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, machine} on success, where machine is the restarted machine data.
  {:error, error()} on failure.
  """
  @spec restart_machine(String.t(), String.t(), FlyMachineApi.options()) ::
          FlyMachineApi.response()
  def restart_machine(app_name, machine_id, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.post("/apps/#{app_name}/machines/#{machine_id}/restart", %{})
    |> handle_request(:restart_machine)
  end

  @doc """
  Sends a signal to a machine.

  ## Parameters

  - app_name: The name of the app the machine belongs to.
  - machine_id: The ID of the machine to signal.
  - signal: The signal to send (e.g., "SIGINT", "SIGTERM").
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, machine} on success, where machine is the updated machine data.
  {:error, error()} on failure.
  """
  @spec signal_machine(String.t(), String.t(), String.t(), FlyMachineApi.options()) ::
          FlyMachineApi.response()
  def signal_machine(app_name, machine_id, signal, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.post("/apps/#{app_name}/machines/#{machine_id}/signal", %{signal: signal})
    |> handle_request(:signal_machine)
  end

  @doc """
  Starts a stopped machine.

  ## Parameters

  - app_name: The name of the app the machine belongs to.
  - machine_id: The ID of the machine to start.
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, machine} on success, where machine is the started machine data.
  {:error, error()} on failure.
  """
  @spec start_machine(String.t(), String.t(), FlyMachineApi.options()) ::
          FlyMachineApi.response()
  def start_machine(app_name, machine_id, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.post("/apps/#{app_name}/machines/#{machine_id}/start", %{})
    |> handle_request(:start_machine)
  end

  @doc """
  Stops a running machine.

  ## Parameters

  - app_name: The name of the app the machine belongs to.
  - machine_id: The ID of the machine to stop.
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, machine} on success, where machine is the stopped machine data.
  {:error, error()} on failure.
  """
  @spec stop_machine(String.t(), String.t(), FlyMachineApi.options()) ::
          FlyMachineApi.response()
  def stop_machine(app_name, machine_id, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.post("/apps/#{app_name}/machines/#{machine_id}/stop", %{})
    |> handle_request(:stop_machine)
  end

  @doc """
  Suspends a running machine.

  ## Parameters

  - app_name: The name of the app the machine belongs to.
  - machine_id: The ID of the machine to suspend.
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, machine} on success, where machine is the suspended machine data.
  {:error, error()} on failure.
  """
  @spec suspend_machine(String.t(), String.t(), FlyMachineApi.options()) ::
          FlyMachineApi.response()
  def suspend_machine(app_name, machine_id, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.post("/apps/#{app_name}/machines/#{machine_id}/suspend", %{})
    |> handle_request(:suspend_machine)
  end

  @doc """
  Waits for a machine to reach a specific state.

  ## Parameters

  - app_name: The name of the app the machine belongs to.
  - machine_id: The ID of the machine to wait for.
  - instance_id: The ID of the instance to wait for.
  - state: The desired state to wait for.
  - timeout: The maximum time to wait (in seconds).
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, machine} on success, where machine is the machine data after reaching the desired state.
  {:error, error()} on failure or timeout.
  """
  @spec wait_for_machine_state(
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          integer(),
          FlyMachineApi.options()
        ) :: FlyMachineApi.response()
  def wait_for_machine_state(
        app_name,
        machine_id,
        instance_id,
        state \\ "started",
        timeout \\ 60,
        opts \\ []
      ) do
    client = FlyMachineApi.new(opts)
    url = "/apps/#{app_name}/machines/#{machine_id}/wait"

    client
    |> Tesla.get(url, query: [instance_id: instance_id, state: state, timeout: timeout])
    |> handle_request(:wait_for_machine_state)
  end
end
