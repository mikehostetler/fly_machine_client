defmodule FlyCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
      ExVCR.Config.filter_request_headers("authorization")
      ExVCR.Config.filter_sensitive_data("Bearer .+", "Bearer FILTERED")

      def in_vcr?(name) do
        [
          Application.fetch_env!(:exvcr, :vcr_cassette_library_dir),
          ExVCR.Mock.normalize_fixture(name) <> ".json"
        ]
        |> Path.join()
        |> File.exists?()
      end
    end
  end
end
