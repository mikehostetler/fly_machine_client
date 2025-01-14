Below is a **revised high-level architecture** plan for grouping all API requests by resource into **one file per resource**, instead of splitting each function call into its own file. This approach results in fewer modules and can be simpler to navigate.

---

## 1. Updated Directory Structure

You already have a structure similar to:
```
lib/fly_machine_api/
  ├── error_handler.ex
  ├── helpers.ex
  └── fly_machine_api.ex
```

You will add **one file per resource** at the same level. Each of these files will contain all of the relevant API calls for that resource:

```
lib/fly_machine_api/
  ├── app.ex          # All endpoints for the "Apps" resource
  ├── machine.ex      # All endpoints for the "Machines" resource
  ├── secret.ex       # All endpoints for "Secrets"
  ├── volume.ex       # All endpoints for "Volumes"
  ├── token.ex        # Optional file for token endpoints
  ├── error_handler.ex
  ├── helpers.ex
  └── fly_machine_api.ex
```

> **Note**: If you decide to keep or remove some modules like `fly_machine_api.ex` for top-level calls, that’s up to you. Typically, `fly_machine_api.ex` can still serve as your “entry point” that delegates to these submodules if desired.

---

## 2. Resource Modules

Below is an example pattern for **`app.ex`** (the resource for working with Fly.io Apps). The same approach applies to machines, secrets, volumes, etc.

### 2.1 `lib/fly_machine_api/app.ex`

```elixir
defmodule FlyMachineApi.App do
  @moduledoc """
  This module contains functions that interact with the Fly.io Apps resource.
  """

  import FlyMachineApi.Helpers
  require Logger

  @doc """
  Lists all apps for the authenticated user.

  - `org_slug`: The organization slug (e.g., "personal") to filter by.
  - `opts`: Additional options for the request (contains `token`, etc.).

  ## Examples

      iex> FlyMachineApi.App.list_apps("personal")
      {:ok, [%{"id" => "...", "name" => "..."}]}

  """
  @spec list_apps(String.t(), keyword()) :: {:ok, list(map())} | {:error, any()}
  def list_apps(org_slug \\ "personal", opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.get("/apps", query: [org_slug: org_slug])
    |> handle_request(:list_apps)
  end

  @doc """
  Creates a new app.
  """
  @spec create_app(map(), keyword()) :: {:ok, map()} | {:error, any()}
  def create_app(params, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.post("/apps", params)
    |> handle_request(:create_app)
  end

  @doc """
  Retrieves a specific app by name.
  """
  @spec get_app(String.t(), keyword()) :: {:ok, map()} | {:error, any()}
  def get_app(app_name, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.get("/apps/#{app_name}")
    |> handle_request(:get_app)
  end

  @doc """
  Destroys a specific app by name.
  """
  @spec destroy_app(String.t(), keyword()) :: {:ok, nil} | {:error, any()}
  def destroy_app(app_name, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.delete("/apps/#{app_name}")
    |> handle_request(:destroy_app)
  end
end
```

- The **`FlyMachineApi.new(opts)`** call is your standard way of creating a Tesla client with relevant middleware and tokens.  
- **`handle_request/2`** is already defined in `helpers.ex`, so you simply use it to parse responses and unify error handling.

---

## 3. Adding Other Resource Modules

You will create similarly structured modules for each Fly API resource. For example:

### 3.1 Machines: `lib/fly_machine_api/machine.ex`

```elixir
defmodule FlyMachineApi.Machine do
  @moduledoc """
  This module contains functions that interact with the Fly.io Machines resource.
  """

  import FlyMachineApi.Helpers
  require Logger

  @type response :: {:ok, map() | list(map()) | nil} | {:error, any()}

  @doc """
  Lists all machines for a given app.
  """
  @spec list_machines(String.t(), keyword()) :: response()
  def list_machines(app_name, opts \\ []) do
    client = FlyMachineApi.new(opts)
    client
    |> Tesla.get("/apps/#{app_name}/machines")
    |> handle_request(:list_machines)
  end

  @doc """
  Creates a new machine for an existing app.
  """
  @spec create_machine(map(), keyword()) :: response()
  def create_machine(params, opts \\ []) do
    client = FlyMachineApi.new(opts)

    # The "app_name" can come from the params map or be an explicit argument, up to your design
    app_name = Map.fetch!(params, :app_name)

    client
    |> Tesla.post("/apps/#{app_name}/machines", params)
    |> handle_request(:create_machine)
  end

  @doc """
  Updates an existing machine.
  """
  @spec update_machine(map(), keyword()) :: response()
  def update_machine(params, opts \\ []) do
    client = FlyMachineApi.new(opts)

    app_name = Map.fetch!(params, :app_name)
    machine_id = Map.fetch!(params, :machine_id)
    update_params = Map.drop(params, [:app_name, :machine_id])

    client
    |> Tesla.patch("/apps/#{app_name}/machines/#{machine_id}", update_params)
    |> handle_request(:update_machine)
  end

  # ... etc. Add the rest of the endpoints here: destroy_machine, restart_machine,
  # signal_machine, start_machine, stop_machine, suspend_machine, wait_for_machine_state,
  # list_machine_events, exec_machine, lease endpoints, metadata endpoints, cordon/uncordon, etc.
end
```

In this single file, add **all** the machine-centric API functions. They can remain logically grouped (e.g., a block for create/destroy, a block for state changes, a block for metadata calls, etc.).

### 3.2 Secrets: `lib/fly_machine_api/secret.ex`

```elixir
defmodule FlyMachineApi.Secret do
  @moduledoc """
  This module contains functions for interacting with app secrets on Fly.io.
  """

  import FlyMachineApi.Helpers

  @spec list_secrets(String.t(), keyword()) :: {:ok, list(map())} | {:error, any()}
  def list_secrets(app_name, opts \\ []) do
    client = FlyMachineApi.new(opts)
    client
    |> Tesla.get("/apps/#{app_name}/secrets")
    |> handle_request(:list_secrets)
  end

  @spec create_secret(String.t(), String.t(), String.t(), any(), keyword()) :: {:ok, map()} | {:error, any()}
  def create_secret(app_name, secret_label, secret_type, value, opts \\ []) do
    client = FlyMachineApi.new(opts)

    body = %{value: :erlang.binary_to_list(value)}
    path = "/apps/#{app_name}/secrets/#{secret_label}/type/#{secret_type}"

    client
    |> Tesla.post(path, body)
    |> handle_request(:create_secret)
  end

  @spec destroy_secret(String.t(), String.t(), keyword()) :: {:ok, nil} | {:error, any()}
  def destroy_secret(app_name, secret_label, opts \\ []) do
    client = FlyMachineApi.new(opts)
    path = "/apps/#{app_name}/secrets/#{secret_label}"

    client
    |> Tesla.delete(path)
    |> handle_request(:destroy_secret)
  end
end
```

### 3.3 Volumes: `lib/fly_machine_api/volume.ex`

```elixir
defmodule FlyMachineApi.Volume do
  @moduledoc """
  This module contains functions for interacting with volumes on Fly.io.
  """

  import FlyMachineApi.Helpers

  @spec list_volumes(String.t(), keyword()) :: {:ok, list(map())} | {:error, any()}
  def list_volumes(app_name, opts \\ []) do
    client = FlyMachineApi.new(opts)
    client
    |> Tesla.get("/apps/#{app_name}/volumes")
    |> handle_request(:list_volumes)
  end

  @spec create_volume(String.t(), map(), keyword()) :: {:ok, map()} | {:error, any()}
  def create_volume(app_name, volume_params, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.post("/apps/#{app_name}/volumes", volume_params)
    |> handle_request(:create_volume)
  end

  # Add get_volume, update_volume, destroy_volume, extend_volume, list_snapshots, create_snapshot, etc.
end
```

### 3.4 Optional Tokens: `lib/fly_machine_api/token.ex`

If needed:
```elixir
defmodule FlyMachineApi.Token do
  @moduledoc """
  This module contains token-related API calls, e.g., requesting an OIDC or KMS token.
  """

  import FlyMachineApi.Helpers

  @spec request_kms_token(keyword()) :: {:ok, map()} | {:error, any()}
  def request_kms_token(opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.post("/tokens/kms", %{})
    |> handle_request(:request_kms_token)
  end

  @spec request_oidc_token(map(), keyword()) :: {:ok, map()} | {:error, any()}
  def request_oidc_token(params, opts \\ []) do
    client = FlyMachineApi.new(opts)

    client
    |> Tesla.post("/tokens/oidc", params)
    |> handle_request(:request_oidc_token)
  end
end
```

---

## 4. Using These Modules

### 4.1 Direct Usage

Your consumers can call them directly:
```elixir
alias FlyMachineApi.{App, Machine, Secret, Volume}

App.list_apps("personal")
Machine.create_machine(%{app_name: "my-app", ...})
Secret.create_secret("my-app", "DB_PASSWORD", "postgres", "secret_value")
Volume.list_volumes("my-app")
```

### 4.2 Single Entry Module (Optional)

You can also expose them via `fly_machine_api.ex` if desired:
```elixir
defmodule FlyMachineApi do
  @moduledoc """
  Main entry point for the Fly Machines API client.
  """

  alias FlyMachineApi.{App, Machine, Secret, Volume}

  defdelegate list_apps(org_slug \\ "personal", opts \\ []), to: App
  defdelegate create_app(params, opts \\ []), to: App
  # ...
  
  defdelegate list_machines(app_name, opts \\ []), to: Machine
  defdelegate create_machine(params, opts \\ []), to: Machine
  # ...
end
```
Users can then keep calling `FlyMachineApi.create_app(...)` with minimal changes.

---

## 5. Tests

With one module per resource, you can similarly **create one test file per resource** under `test/fly_machine_api/`:

```
test/fly_machine_api/
  app_test.exs
  machine_test.exs
  secret_test.exs
  volume_test.exs
  ...
```

For instance, **`test/fly_machine_api/app_test.exs`**:

```elixir
defmodule FlyMachineApi.AppTest do
  use ExUnit.Case, async: true
  import Mimic
  alias FlyMachineApi.App

  setup :set_mimic_global

  test "list_apps/2 returns a list of apps" do
    # Mock Tesla call
    Tesla
    |> stub(:get, fn "/apps", query: [org_slug: "personal"] -> 
      {:ok, %{status: 200, body: [%{"name" => "test-app"}]}} 
    end)

    assert {:ok, [%{"name" => "test-app"}]} = App.list_apps("personal")
  end

  # ...
end
```

---

## 6. Summary

1. **Create single resource-based modules** under `lib/fly_machine_api/` (one file per resource: `app.ex`, `machine.ex`, `secret.ex`, `volume.ex`, etc.).  
2. **Implement** all the relevant endpoints in each resource module, using your existing style:
   - `Tesla` calls in each function
   - `handle_request/2` from `helpers.ex`
   - Return `{:ok, ...} | {:error, ...}`  
3. **Optionally** keep a top-level `FlyMachineApi` module that delegates calls to these new resource modules, retaining a “one-stop shop” interface.  
4. **Tests** should mirror these files, each containing the relevant test coverage for that resource’s endpoints.  
5. This design keeps the codebase simpler and more discoverable—each file only deals with one resource but includes all endpoints for that resource.

This updated approach focuses on **grouping by resource** in single modules rather than splitting each function out. It provides a cohesive, consistent client and an easy path to maintain or extend the Fly Machines API coverage.