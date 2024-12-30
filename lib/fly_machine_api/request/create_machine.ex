defmodule FlyMachineApi.Request.CreateMachine do
  @moduledoc """
  Module for creating a new machine in a Fly.io app.
  """

  import FlyMachineApi.Helpers

  # @create_machine_options [
  # app_name: [type: :string, required: true],
  # name: [type: :string, required: false],
  # region: [type: :string, required: false]
  # config: [type: :map, required: true],
  # image: [type: :string, required: true],
  # env: [type: :map, required: false],
  # services: [type: :list, required: false],
  # metadata: [type: :map, required: false]
  # ]

  @doc """
  Creates a new machine in a Fly.io app.

  ## Parameters

  - params: A map containing the machine creation parameters.

  ## Returns

  {:ok, machine} on success, where machine is the created machine data.
  {:error, error()} on failure.
  """
  @spec create_machine(map(), Fly.options()) :: Fly.response()
  def create_machine(params, opts \\ []) do
    # with {:ok, validated_params} <- validate_params(params, @create_machine_options) do
    client = FlyMachineApi.new(opts)
    app_name = Map.get(params, :app_name)

    client
    |> Tesla.post("/apps/#{app_name}/machines", params)
    |> handle_request(:create_machine)

    # end
  end
end
