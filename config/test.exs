import Config

config :tesla, adapter: Tesla.Adapter.Hackney

config :exvcr,
  vcr_cassette_library_dir: "test/support/vcr",
  filter_request_headers: [
    "Authorization"
  ]
