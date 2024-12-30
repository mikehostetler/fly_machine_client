defmodule FlyMachineApi.Request.UpdateMachine do
  @moduledoc """
  Module for updating an existing machine in a Fly.io app.
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
  Updates an existing machine in a Fly.io app.

  ## Parameters

  - params: A map containing the machine update parameters.

  ## Returns

  {:ok, machine} on success, where machine is the updated machine data.
  {:error, error()} on failure.
  """
  @spec update_machine(map(), Fly.options()) :: Fly.response()
  def update_machine(params, opts \\ []) do
    client = Fly.new(opts)

    with {:ok, validated_params} <- validate_params(params, @update_machine_options) do
      app_name = Map.get(validated_params, :app_name)
      machine_id = Map.get(validated_params, :machine_id)
      update_params = Map.drop(validated_params, [:app_name, :machine_id])

      client
      |> Tesla.patch("/apps/#{app_name}/machines/#{machine_id}", update_params)
      |> handle_request(:update_machine)
    end
  end
end
