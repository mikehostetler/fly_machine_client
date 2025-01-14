defmodule FlyMachineClient.Volumes do
  @moduledoc """
  API client for managing Fly.io volumes.
  """

  import FlyMachineClient.Helpers

  @doc """
  List all volumes associated with a specific app.
  """
  @spec list(app_name :: String.t(), opts :: keyword(), FlyMachineClient.options()) ::
          FlyMachineClient.response()
  def list(app_name, opts \\ [], client_opts \\ []) do
    client = FlyMachineClient.new(client_opts)
    query = if opts[:summary], do: [summary: opts[:summary]], else: []

    client
    |> Tesla.get("/apps/#{app_name}/volumes", query: query)
    |> handle_request(:list_volumes)
  end

  @doc """
  Create a volume for a specific app.
  """
  @spec create(app_name :: String.t(), params :: map(), FlyMachineClient.options()) ::
          FlyMachineClient.response()
  def create(app_name, params, opts \\ []) do
    client = FlyMachineClient.new(opts)

    client
    |> Tesla.post("/apps/#{app_name}/volumes", params)
    |> handle_request(:create_volume)
  end

  @doc """
  Get details about a specific volume by its ID within an app.
  """
  @spec get(app_name :: String.t(), volume_id :: String.t(), FlyMachineClient.options()) ::
          FlyMachineClient.response()
  def get(app_name, volume_id, opts \\ []) do
    client = FlyMachineClient.new(opts)

    client
    |> Tesla.get("/apps/#{app_name}/volumes/#{volume_id}")
    |> handle_request(:get_volume)
  end

  @doc """
  Update a volume's configuration.
  """
  @spec update(
          app_name :: String.t(),
          volume_id :: String.t(),
          params :: map(),
          FlyMachineClient.options()
        ) :: FlyMachineClient.response()
  def update(app_name, volume_id, params, opts \\ []) do
    client = FlyMachineClient.new(opts)

    client
    |> Tesla.put("/apps/#{app_name}/volumes/#{volume_id}", params)
    |> handle_request(:update_volume)
  end

  @doc """
  Delete a specific volume within an app by volume ID.
  """
  @spec delete(app_name :: String.t(), volume_id :: String.t(), FlyMachineClient.options()) ::
          FlyMachineClient.response()
  def delete(app_name, volume_id, opts \\ []) do
    client = FlyMachineClient.new(opts)

    client
    |> Tesla.delete("/apps/#{app_name}/volumes/#{volume_id}")
    |> handle_request(:delete_volume)
  end

  @doc """
  Extend a volume's size within an app.
  """
  @spec extend(
          app_name :: String.t(),
          volume_id :: String.t(),
          size_gb :: integer(),
          FlyMachineClient.options()
        ) :: FlyMachineClient.response()
  def extend(app_name, volume_id, size_gb, opts \\ []) do
    client = FlyMachineClient.new(opts)

    client
    |> Tesla.put("/apps/#{app_name}/volumes/#{volume_id}/extend", %{size_gb: size_gb})
    |> handle_request(:extend_volume)
  end

  @doc """
  List all snapshots for a specific volume within an app.
  """
  @spec list_snapshots(
          app_name :: String.t(),
          volume_id :: String.t(),
          FlyMachineClient.options()
        ) ::
          FlyMachineClient.response()
  def list_snapshots(app_name, volume_id, opts \\ []) do
    client = FlyMachineClient.new(opts)

    client
    |> Tesla.get("/apps/#{app_name}/volumes/#{volume_id}/snapshots")
    |> handle_request(:list_volume_snapshots)
  end

  @doc """
  Create a snapshot for a specific volume within an app.
  """
  @spec create_snapshot(
          app_name :: String.t(),
          volume_id :: String.t(),
          FlyMachineClient.options()
        ) ::
          FlyMachineClient.response()
  def create_snapshot(app_name, volume_id, opts \\ []) do
    client = FlyMachineClient.new(opts)

    client
    |> Tesla.post("/apps/#{app_name}/volumes/#{volume_id}/snapshots", %{})
    |> handle_request(:create_volume_snapshot)
  end
end
