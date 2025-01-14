import Config

config :fly_machine_client,
  base_url: "https://api.machines.dev/v1"

if Mix.env() == :test do
  import_config "test.exs"
end
