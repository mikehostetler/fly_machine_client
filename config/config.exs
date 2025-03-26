import Config

config :fly_machine_client,
  base_url: "https://api.machines.dev/v1",
  token: System.get_env("FLY_MACHINE_TOKEN")

if Mix.env() == :test do
  import_config "test.exs"
end
