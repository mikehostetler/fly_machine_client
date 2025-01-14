ExUnit.start()

ExVCR.Config.cassette_library_dir("test/vcr_cassettes")
ExVCR.Config.filter_sensitive_data("Bearer .+", "Bearer <TOKEN>")
ExVCR.Config.filter_url_params(true)

# Configure ExVCR for Tesla
Application.ensure_all_started(:hackney)
