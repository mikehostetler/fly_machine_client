defmodule FlyMachineApi do
  @moduledoc false
  use Tesla

  import FlyMachineApi.Helpers

  require Logger

  @type response :: {:ok, map() | list(map()) | nil} | {:error, any()}
  @type options :: [token: String.t()]

  @default_base_url "https://api.machines.dev/v1"

  def new(options \\ []) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url()},
      {Tesla.Middleware.JSON, engine: Jason},
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{get_token(options)}"}]},
      Fly.ErrorHandlerMiddleware
    ]

    Tesla.client(middleware)
  end

  defp get_token(options) do
    Keyword.get(options, :token, token())
  end

  def base_url, do: Application.get_env(:fly_machine_api, :base_url, @default_base_url)

  def token do
    case Application.get_env(:fly_machine_api, :token) do
      nil ->
        raise "Fly API token not configured. Please set the :fly_machine_api, :token config value."

      token ->
        token
    end
  end

  @doc """
  Lists all apps for the authenticated user.

  ## Parameters

  - org_slug: Optional. The organization slug to filter apps by.
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, apps} on success, where apps is a list of app data.
  {:error, reason} on failure.
  """
  @spec list_apps(String.t(), options()) :: response()
  def list_apps(org_slug \\ "personal", opts \\ []) do
    client = new(opts)

    client
    |> Tesla.get("/apps", query: [org_slug: org_slug])
    |> handle_request(:list_apps)
  end

  @doc """
  Creates a new app.

  ## Parameters

  - params: A map containing the app creation parameters.
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, app} on success, where app is the created app data.
  {:error, error()} on failure.
  """
  @spec create_app(map(), FlyMachineApi.options()) :: FlyMachineApi.response()
  defdelegate create_app(params, opts \\ []), to: FlyMachineApi.Request.CreateApp

  @doc """
  Gets details of a specific app.

  ## Parameters

  - app_name: The name of the app to retrieve.
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, app} on success, where app is the app data.
  {:error, error()} on failure.
  """
  @spec get_app(String.t(), FlyMachineApi.options()) :: FlyMachineApi.response()
  def get_app(app_name, opts \\ []) do
    client = new(opts)
    client |> Tesla.get("/apps/#{app_name}") |> handle_request(:get_app)
  end

  @doc """
  Destroys (deletes) an app.

  ## Parameters

  - app_name: The name of the app to destroy.
  - opts: Optional. Additional options for the request.

  ## Returns

  {:ok, nil} on success.
  {:error, error()} on failure.
  """
  @spec destroy_app(String.t(), FlyMachineApi.options()) :: FlyMachineApi.response()
  def destroy_app(app_name, opts \\ []) do
    client = new(opts)
    client |> Tesla.delete("/apps/#{app_name}") |> handle_request(:destroy_app)
  end

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
    client = new(opts)
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
    client = new(opts)

    client
    |> Tesla.get("/apps/#{app_name}/machines/#{machine_id}")
    |> handle_request(:get_machine)
  end

  @doc """
  Creates a new machine in a Fly.io app.

  ## Parameters

  - params: A map containing the machine creation parameters.
  - opts: Optional. Additional options for the request.

  ## Returns

  """
  @spec create_machine(map(), FlyMachineApi.options()) :: FlyMachineApi.response()
  defdelegate create_machine(params, opts \\ []), to: FlyMachineApi.Request.CreateMachine

  @spec update_machine(map(), FlyMachineApi.options()) :: FlyMachineApi.response()
  defdelegate update_machine(params, opts \\ []), to: FlyMachineApi.Request.UpdateMachine

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
    client = new(opts)

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
    client = new(opts)

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
    client = new(opts)

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
    client = new(opts)

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
    client = new(opts)

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
    client = new(opts)

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
    client = new(opts)
    url = "/apps/#{app_name}/machines/#{machine_id}/wait"

    client
    |> Tesla.get(url, query: [instance_id: instance_id, state: state, timeout: timeout])
    |> handle_request(:wait_for_machine_state)
  end

  # def execute_machine_command, do: :ok
  # def get_machine_metadata, do: :ok
  # def update_machine_metadata, do: :ok
  # def delete_machine_metadata, do: :ok
  # def list_versions, do: :ok

  # def list_app_secrets, do: :ok
  # def create_app_secret, do: :ok
  # def get_app_secret, do: :ok
  # def update_app_secret, do: :ok
  # def delete_app_secret, do: :ok
  # def delete_app_secret, do: :ok
end
