defmodule Mix.Tasks.FlyMachineClient.ListTestApps do
  @moduledoc """
  Lists all test apps (apps with 'test-app' prefix).

  ## Usage

      mix fly_machine_client.list_test_apps
  """
  use Mix.Task

  @shortdoc "Lists test apps"
  def run(_args) do
    IO.puts("Listing test apps...")

    case FlyMachineClient.list_apps() do
      {:ok, %{"apps" => apps}} ->
        test_apps =
          Enum.filter(apps, fn app ->
            String.starts_with?(app["name"], "test-")
          end)

        if Enum.empty?(test_apps) do
          IO.puts("No test apps found")
        else
          Enum.each(test_apps, fn app ->
            IO.puts("\"#{app["name"]}\",")
          end)

          IO.puts("\nTotal test apps: #{length(test_apps)}")
        end

      {:error, error} ->
        IO.puts("Error listing apps: #{error}")
    end
  end
end
