defmodule Mix.Tasks.FlyMachineClient.CleanTestMachines do
  @moduledoc """
  Cleans up test resources created during testing.

  ## Usage

      mix clean         # Prompt for each deletion
      mix clean --all   # Delete all without prompting
  """
  use Mix.Task

  @shortdoc "Cleans up test resources"
  def run(args) do
    IO.puts("Cleaning up test resources...")
    delete_all = "--all" in args

    apps = [
      "test-machine-app-vcr-lifecycle",
      "test-machine-app-vcr-destroy",
      "test-machine-app-vcr-lifecycle-647",
      "test-machine-app-vcr-list",
      "test-machine-app-vcr-update",
      "test-machine-app-vcr-destroy-492",
      "test-machine-app-vcr-lifecycle-394",
      "test-machine-app-vcr-destroy-342"
    ]

    Enum.each(apps, fn app ->
      case FlyMachineClient.get_app(app) do
        {:ok, _app_details} ->
          IO.puts("\nFound app #{app}")

          if delete_all || confirm_deletion?(app) do
            case FlyMachineClient.destroy_app(app) do
              {:ok, _} -> IO.puts("Deleted app #{app}")
              {:error, error} -> IO.puts("Error deleting app #{app}: #{error}")
            end
          end

        {:error, _} ->
          IO.puts("Skipping #{app} - app does not exist")
      end
    end)
  end

  defp confirm_deletion?(app) do
    IO.puts("Do you want to delete #{app}? [y/N/a(ll)]")
    input = IO.gets("") |> String.trim() |> String.downcase()
    input == "y" || input == "a" || input == "all"
  end
end
