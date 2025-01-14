defmodule FlyMachineApi.Apps do
  @moduledoc false

  import FlyMachineApi.Helpers

  @create_app_options [
    app_name: [type: :string, required: true],
    org_slug: [type: :string, required: true],
    network: [type: :string, default: ""],
    enable_subdomains: [type: :boolean, default: false]
  ]

  @doc """
  Lists all apps for the authenticated user.
  """
  @spec list_apps(String.t(), FlyMachineApi.options()) :: FlyMachineApi.response()
  def list_apps(org_slug \\ "personal", opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.get("/apps", query: [org_slug: org_slug])
    |> handle_request(:list_apps)
  end

  @doc """
  Creates a new app.
  """
  @spec create_app(map() | keyword(), FlyMachineApi.options()) :: FlyMachineApi.response()
  def create_app(params, opts \\ []) do
    client = FlyMachineApi.new(opts)
    params = if is_map(params), do: Enum.into(params, []), else: params

    with {:ok, validated_params} <- validate_params(params, @create_app_options) do
      client
      |> Tesla.post("/apps", validated_params)
      |> handle_request(:create_app)
    end
  end

  @doc """
  Gets details of a specific app.
  """
  @spec get_app(String.t(), FlyMachineApi.options()) :: FlyMachineApi.response()
  def get_app(app_name, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.get("/apps/#{app_name}")
    |> handle_request(:get_app)
  end

  @doc """
  Destroys (deletes) an app.
  """
  @spec destroy_app(String.t(), FlyMachineApi.options()) :: FlyMachineApi.response()
  def destroy_app(app_name, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.delete("/apps/#{app_name}")
    |> handle_request(:destroy_app)
  end
end
