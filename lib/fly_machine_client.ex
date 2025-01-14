defmodule FlyMachineClient do
  @moduledoc false
  use Tesla

  @type response :: {:ok, map() | list(map()) | nil} | {:error, any()}
  @type options :: [token: String.t()]

  @default_base_url "https://api.machines.dev/v1"

  def new(options \\ []) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url()},
      {Tesla.Middleware.JSON, engine: Jason},
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{get_token(options)}"}]},
      FlyMachineClient.ErrorHandlerMiddleware
    ]

    adapter = if Mix.env() == :test, do: Tesla.Adapter.Hackney, else: nil
    Tesla.client(middleware, adapter)
  end

  defp get_token(options) do
    Keyword.get(options, :token, token())
  end

  def base_url, do: Application.get_env(:fly_machine_client, :base_url, @default_base_url)

  def token do
    case Application.get_env(:fly_machine_client, :token) do
      nil ->
        raise "Fly API token not configured. Please set the :fly_machine_client, :token config value."

      token ->
        token
    end
  end

  # -----------------------------------------------------
  # Low-level direct calls (to Apps, Machines, Secrets, etc.)
  # -----------------------------------------------------

  @doc """
  Lists all apps for the authenticated user.
  """
  @spec list_apps(String.t(), options()) :: response()
  defdelegate list_apps(org_slug \\ "personal", opts \\ []), to: FlyMachineClient.Apps

  @doc """
  Creates a new app.
  """
  @spec create_app(map(), options()) :: response()
  defdelegate create_app(params, opts \\ []), to: FlyMachineClient.Apps

  @doc """
  Gets details of a specific app.
  """
  @spec get_app(String.t(), options()) :: response()
  defdelegate get_app(app_name, opts \\ []), to: FlyMachineClient.Apps

  @doc """
  Destroys (deletes) an app.
  """
  @spec destroy_app(String.t(), options()) :: response()
  defdelegate destroy_app(app_name, opts \\ []), to: FlyMachineClient.Apps

  @doc """
  Lists all secrets for a given app.
  """
  @spec list_secrets(String.t(), options()) :: response()
  defdelegate list_secrets(app_name, opts \\ []), to: FlyMachineClient.Secrets

  @doc """
  Creates a new secret for an app.
  """
  @spec create_secret(String.t(), String.t(), String.t(), [integer()], options()) :: response()
  defdelegate create_secret(app_name, secret_label, secret_type, value, opts \\ []),
    to: FlyMachineClient.Secrets

  @doc """
  Generates a new secret for an app.
  """
  @spec generate_secret(String.t(), String.t(), String.t(), options()) :: response()
  defdelegate generate_secret(app_name, secret_label, secret_type, opts \\ []),
    to: FlyMachineClient.Secrets

  @doc """
  Destroys (deletes) a secret from an app.
  """
  @spec destroy_secret(String.t(), String.t(), options()) :: response()
  defdelegate destroy_secret(app_name, secret_label, opts \\ []), to: FlyMachineClient.Secrets

  # Machine-related functions
  @doc """
  Lists all machines for a given app.
  """
  @spec list_machines(String.t(), options()) :: response()
  defdelegate list_machines(app_name, opts \\ []), to: FlyMachineClient.Machines

  @doc """
  Gets details of a specific machine.
  """
  @spec get_machine(String.t(), String.t(), options()) :: response()
  defdelegate get_machine(app_name, machine_id, opts \\ []), to: FlyMachineClient.Machines

  @doc """
  Creates a new machine in a Fly.io app.
  """
  @spec create_machine(map(), options()) :: response()
  defdelegate create_machine(params, opts \\ []), to: FlyMachineClient.Machines

  @doc """
  Updates an existing machine in a Fly.io app.
  """
  @spec update_machine(map(), options()) :: response()
  defdelegate update_machine(params, opts \\ []), to: FlyMachineClient.Machines

  @doc """
  Destroys (deletes) a machine.
  """
  @spec destroy_machine(String.t(), String.t(), options()) :: response()
  defdelegate destroy_machine(app_name, machine_id, opts \\ []), to: FlyMachineClient.Machines

  @doc """
  Restarts a machine.
  """
  @spec restart_machine(String.t(), String.t(), options()) :: response()
  defdelegate restart_machine(app_name, machine_id, opts \\ []), to: FlyMachineClient.Machines

  @doc """
  Sends a signal to a machine.
  """
  @spec signal_machine(String.t(), String.t(), String.t(), options()) :: response()
  defdelegate signal_machine(app_name, machine_id, signal, opts \\ []),
    to: FlyMachineClient.Machines

  @doc """
  Starts a stopped machine.
  """
  @spec start_machine(String.t(), String.t(), options()) :: response()
  defdelegate start_machine(app_name, machine_id, opts \\ []), to: FlyMachineClient.Machines

  @doc """
  Stops a running machine.
  """
  @spec stop_machine(String.t(), String.t(), options()) :: response()
  defdelegate stop_machine(app_name, machine_id, opts \\ []), to: FlyMachineClient.Machines

  @doc """
  Suspends a running machine.
  """
  @spec suspend_machine(String.t(), String.t(), options()) :: response()
  defdelegate suspend_machine(app_name, machine_id, opts \\ []), to: FlyMachineClient.Machines

  @doc """
  Waits for a machine to reach a specific state.
  """
  @spec wait_for_machine_state(
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          integer(),
          options()
        ) ::
          response()
  defdelegate wait_for_machine_state(
                app_name,
                machine_id,
                instance_id,
                state \\ "started",
                timeout \\ 60,
                opts \\ []
              ),
              to: FlyMachineClient.Machines

  @doc """
  Lists all volumes associated with a specific app.
  """
  @spec list_volumes(String.t(), keyword(), options()) :: response()
  defdelegate list_volumes(app_name, opts \\ [], client_opts \\ []),
    to: FlyMachineClient.Volumes,
    as: :list

  @doc """
  Creates a volume for a specific app.
  """
  @spec create_volume(String.t(), map(), options()) :: response()
  defdelegate create_volume(app_name, params, opts \\ []),
    to: FlyMachineClient.Volumes,
    as: :create

  @doc """
  Gets details about a specific volume by its ID within an app.
  """
  @spec get_volume(String.t(), String.t(), options()) :: response()
  defdelegate get_volume(app_name, volume_id, opts \\ []), to: FlyMachineClient.Volumes, as: :get

  @doc """
  Updates a volume's configuration.
  """
  @spec update_volume(String.t(), String.t(), map(), options()) :: response()
  defdelegate update_volume(app_name, volume_id, params, opts \\ []),
    to: FlyMachineClient.Volumes,
    as: :update

  @doc """
  Deletes a specific volume within an app by volume ID.
  """
  @spec delete_volume(String.t(), String.t(), options()) :: response()
  defdelegate delete_volume(app_name, volume_id, opts \\ []),
    to: FlyMachineClient.Volumes,
    as: :delete

  @doc """
  Extends a volume's size within an app.
  """
  @spec extend_volume(String.t(), String.t(), integer(), options()) :: response()
  defdelegate extend_volume(app_name, volume_id, size_gb, opts \\ []),
    to: FlyMachineClient.Volumes,
    as: :extend

  @doc """
  Lists all snapshots for a specific volume within an app.
  """
  @spec list_volume_snapshots(String.t(), String.t(), options()) :: response()
  defdelegate list_volume_snapshots(app_name, volume_id, opts \\ []),
    to: FlyMachineClient.Volumes,
    as: :list_snapshots

  @doc """
  Creates a snapshot for a specific volume within an app.
  """
  @spec create_volume_snapshot(String.t(), String.t(), options()) :: response()
  defdelegate create_volume_snapshot(app_name, volume_id, opts \\ []),
    to: FlyMachineClient.Volumes,
    as: :create_snapshot

  # -----------------------------------------------------
  # Higher-level orchestrations
  # -----------------------------------------------------

  @doc """
  Creates an app, then waits for it to become active (polling get_app).
  """
  @spec create_app_and_wait(map(), keyword()) :: response()
  defdelegate create_app_and_wait(params, wait_opts \\ []),
    to: FlyMachineClient.Orchestrator

  @doc """
  Creates a machine, then waits for it to reach "started" state.
  """
  @spec create_machine_and_wait(map(), keyword()) :: response()
  defdelegate create_machine_and_wait(params, wait_opts \\ []),
    to: FlyMachineClient.Orchestrator
end