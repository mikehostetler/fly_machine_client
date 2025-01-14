defmodule FlyMachineClient.Orchestrator do
  @moduledoc """
  High-level orchestrator for multi-step or state-aware Fly API operations.

  This module provides higher-level flows that often involve:
    * Checking resource states (e.g., pending vs. active)
    * Retrying or waiting for readiness
    * Handling subtle edge cases where Fly returns 500 or other errors during transitions

  Example usage could include:
  - create_app_and_wait/2: Create an app, then poll get_app until the status is no longer "pending".
  - create_machine_and_wait/2: Create a machine, wait for it to be "started".
  - orchestrated deployments involving multiple resources.
  """

  alias FlyMachineClient.{Apps, Machines}

  @doc """
  Creates an app, then waits for it to become active.
  Accepts:
    - `params`: Map with `:app_name`, `:org_slug`, etc.
    - `wait_opts`: Options for how long to poll, intervals, etc. (optional)
  Returns `{:ok, app}` or `{:error, reason}`.
  """
  def create_app_and_wait(params, wait_opts \\ []) do
    with {:ok, created_app} <- Apps.create_app(params),
         {:ok, _active_app} <- wait_for_app_active(created_app["name"], wait_opts) do
      {:ok, created_app}
    end
  end

  @doc """
  Waits for the given Fly app to become active.
  Polls get_app until status != "pending" or until timeout.
  
  `wait_opts` may include:
    * `:timeout` (in seconds), default 60
    * `:interval` (in ms), default 2000
  """
  def wait_for_app_active(app_name, wait_opts \\ []) do
    timeout = Keyword.get(wait_opts, :timeout, 60)
    interval = Keyword.get(wait_opts, :interval, 2000)
    deadline = System.monotonic_time(:millisecond) + (timeout * 1000)

    poll_until_active(app_name, deadline, interval)
  end

  defp poll_until_active(app_name, deadline, interval) do
    # For this example, we just check "status" from get_app. Real logic might be more advanced.
    case Apps.get_app(app_name) do
      {:ok, %{"status" => status} = app} when status != "pending" ->
        {:ok, app}

      {:ok, _still_pending} ->
        maybe_continue_poll(app_name, deadline, interval)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_continue_poll(app_name, deadline, interval) do
    now = System.monotonic_time(:millisecond)
    if now >= deadline do
      {:error, "Timeout waiting for app to become active"}
    else
      :timer.sleep(interval)
      poll_until_active(app_name, deadline, interval)
    end
  end

  @doc """
  Creates a machine, then waits for it to be in the "started" state.
  Example multi-step flow:
    - create_machine/2
    - wait_for_machine_state/6
  """
  def create_machine_and_wait(params, wait_opts \\ []) do
    with {:ok, machine} <- Machines.create_machine(params),
         {:ok, _ready_machine} <-
           Machines.wait_for_machine_state(
             params.app_name,
             machine["id"],
             machine["instance_id"],
             "started",
             Keyword.get(wait_opts, :timeout, 60)
           ) do
      {:ok, machine}
    end
  end
end