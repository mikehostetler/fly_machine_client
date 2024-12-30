defmodule FlyMachineApi.Request.CreateApp do
  @moduledoc false
  import FlyMachineApi.Helpers

  @create_app_options [
    app_name: [type: :string, required: true],
    org_slug: [type: :string, required: true],
    network: [type: :string, default: ""],
    enable_subdomains: [type: :boolean, default: false]
  ]

  @spec create_app(map() | keyword(), Fly.options()) :: Fly.response()
  def create_app(params, opts \\ []) do
    client = FlyMachineApi.new(opts)
    params = if is_map(params), do: Enum.into(params, []), else: params

    with {:ok, validated_params} <- validate_params(params, @create_app_options) do
      client
      |> Tesla.post("/apps", validated_params)
      |> handle_request(:create_app)
    end
  end
end
