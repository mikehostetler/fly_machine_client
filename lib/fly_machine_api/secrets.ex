defmodule FlyMachineApi.Secrets do
  @moduledoc """
  Module for managing secrets on Fly.io machines.
  """

  import FlyMachineApi.Helpers

  @doc """
  Lists all secrets for a given app.

  ## Parameters

  - app_name: The name of the app to list secrets for
  - opts: Optional list of options

  ## Returns

  {:ok, secrets} on success where secrets is a list of secret data
  {:error, error} on failure
  """
  @spec list_secrets(String.t(), FlyMachineApi.options()) :: FlyMachineApi.response()
  def list_secrets(app_name, opts \\ []) do
    client = FlyMachineApi.new(opts)
    client |> Tesla.get("/apps/#{app_name}/secrets") |> handle_request(:list_secrets)
  end

  @doc """
  Creates a new secret for an app.

  ## Parameters

  - app_name: The name of the app to create the secret for
  - secret_label: The label/name for the secret
  - secret_type: The type of secret
  - value: The secret value as a list of integers
  - opts: Optional list of options

  ## Returns

  {:ok, nil} on success (201 Created)
  {:error, error} on failure (400 Bad Request)
  """
  @spec create_secret(String.t(), String.t(), String.t(), [integer()], FlyMachineApi.options()) ::
          FlyMachineApi.response()
  def create_secret(app_name, secret_label, secret_type, value, opts \\ []) when is_list(value) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.post(
      "/apps/#{app_name}/secrets/#{secret_label}/type/#{secret_type}",
      %{value: value}
    )
    |> handle_request(:create_secret)
  end

  @doc """
  Generates a new secret for an app.

  ## Parameters

  - app_name: The name of the app to generate the secret for
  - secret_label: The label/name for the secret
  - secret_type: The type of secret
  - opts: Optional list of options

  ## Returns

  {:ok, nil} on success (201 Created)
  {:error, error} on failure (400 Bad Request)
  """
  @spec generate_secret(String.t(), String.t(), String.t(), FlyMachineApi.options()) ::
          FlyMachineApi.response()
  def generate_secret(app_name, secret_label, secret_type, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.post(
      "/apps/#{app_name}/secrets/#{secret_label}/type/#{secret_type}/generate",
      %{}
    )
    |> handle_request(:generate_secret)
  end

  @doc """
  Destroys (deletes) a secret from an app.

  ## Parameters

  - app_name: The name of the app to delete the secret from
  - secret_label: The label/name of the secret to delete
  - opts: Optional list of options

  ## Returns

  {:ok, nil} on success (200 OK)
  {:error, error} on failure
  """
  @spec destroy_secret(String.t(), String.t(), FlyMachineApi.options()) ::
          FlyMachineApi.response()
  def destroy_secret(app_name, secret_label, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.delete("/apps/#{app_name}/secrets/#{secret_label}")
    |> handle_request(:destroy_secret)
  end
end
