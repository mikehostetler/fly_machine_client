defmodule Clean do
  def clean do
    apps = [
      "test-app-vcr-list",
      "test-app-secrets-vcr-destroy-error",
      "test-app-secrets-vcr-destroy",
      "test-app-secrets-vcr-list",
      "test-app-secrets-vcr-create",
      "test-app-secrets-vcr-list-empty",
      "test-app-secrets-vcr-generate",
      "test-app-vcr-get",
      "test-app-vcr"
    ]

    Enum.each(apps, fn app ->
      case FlyMachineApi.destroy_app(app) do
        {:ok, _} -> IO.puts("Deleted app #{app}")
        {:error, error} -> IO.puts("Error deleting app #{app}: #{error}")
      end
    end)
  end
end
