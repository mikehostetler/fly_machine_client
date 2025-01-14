defmodule FlyMachineClient.SecretsTest do
  use FlyCase

  @moduletag :capture_log
  @test_app_name "test-app-secrets-vcr"
  @test_secret_label "test-secret"
  @test_secret_type "general"
  # API expects array of integers for secret value
  @test_secret_value [1, 2, 3]

  describe "list_secrets/2" do
    test "lists secrets for an app" do
      app_params = %{
        app_name: "#{@test_app_name}-list",
        org_slug: "personal",
        network: "custom-network",
        enable_subdomains: true
      }

      use_cassette "secrets/list_flow" do
        # Create an app first
        {:ok, created_app} = FlyMachineClient.create_app(app_params)
        assert Map.has_key?(created_app, "id")

        # Create a secret to list
        assert {:ok, _} =
                 FlyMachineClient.create_secret(
                   app_params.app_name,
                   @test_secret_label,
                   @test_secret_type,
                   @test_secret_value
                 )

        # List secrets
        assert {:ok, secrets} = FlyMachineClient.list_secrets(app_params.app_name)
        assert is_list(secrets)

        # Verify the secret we created is in the list
        secret = Enum.find(secrets, &(&1["label"] == @test_secret_label))
        assert secret
        assert secret["type"] == @test_secret_type
      end
    end

    test "returns empty list for app with no secrets" do
      app_params = %{
        app_name: "#{@test_app_name}-list-empty",
        org_slug: "personal",
        network: "custom-network",
        enable_subdomains: true
      }

      use_cassette "secrets/list_empty" do
        # Create an app first
        {:ok, created_app} = FlyMachineClient.create_app(app_params)
        assert Map.has_key?(created_app, "id")

        # List secrets
        assert {:ok, secrets} = FlyMachineClient.list_secrets(app_params.app_name)
        assert is_list(secrets)
        assert Enum.empty?(secrets)
      end
    end
  end

  describe "create_secret/5" do
    test "creates a new secret" do
      app_params = %{
        app_name: "#{@test_app_name}-create",
        org_slug: "personal",
        network: "custom-network",
        enable_subdomains: true
      }

      use_cassette "secrets/create_flow" do
        # Create an app first
        {:ok, created_app} = FlyMachineClient.create_app(app_params)
        assert Map.has_key?(created_app, "id")

        # Create a secret
        assert {:ok, _} =
                 FlyMachineClient.create_secret(
                   app_params.app_name,
                   @test_secret_label,
                   @test_secret_type,
                   @test_secret_value
                 )

        # Verify it exists
        {:ok, secrets} = FlyMachineClient.list_secrets(app_params.app_name)
        secret = Enum.find(secrets, &(&1["label"] == @test_secret_label))
        assert secret
        assert secret["type"] == @test_secret_type
      end
    end

    test "returns error for non-existent app" do
      use_cassette "secrets/create_error" do
        assert {:error, "Unexpected error occurred"} =
                 FlyMachineClient.create_secret(
                   "non-existent-app",
                   @test_secret_label,
                   @test_secret_type,
                   @test_secret_value
                 )
      end
    end
  end

  describe "generate_secret/4" do
    test "generates a new secret" do
      app_params = %{
        app_name: "#{@test_app_name}-generate",
        org_slug: "personal",
        network: "custom-network",
        enable_subdomains: true
      }

      use_cassette "secrets/generate_flow" do
        # Create an app first
        {:ok, created_app} = FlyMachineClient.create_app(app_params)
        assert Map.has_key?(created_app, "id")

        # Generate a secret
        assert {:ok, _} =
                 FlyMachineClient.generate_secret(
                   app_params.app_name,
                   @test_secret_label,
                   @test_secret_type
                 )

        # Verify it exists
        {:ok, secrets} = FlyMachineClient.list_secrets(app_params.app_name)
        secret = Enum.find(secrets, &(&1["label"] == @test_secret_label))
        assert secret
        assert secret["type"] == @test_secret_type
      end
    end

    test "returns error for non-existent app" do
      use_cassette "secrets/generate_error" do
        assert {:error, "Unexpected error occurred"} =
                 FlyMachineClient.generate_secret(
                   "non-existent-app",
                   @test_secret_label,
                   @test_secret_type
                 )
      end
    end
  end

  describe "destroy_secret/3" do
    test "destroys a secret" do
      app_params = %{
        app_name: "#{@test_app_name}-destroy",
        org_slug: "personal",
        network: "custom-network",
        enable_subdomains: true
      }

      use_cassette "secrets/destroy_flow" do
        # Create an app first
        {:ok, created_app} = FlyMachineClient.create_app(app_params)
        assert Map.has_key?(created_app, "id")

        # Create a secret
        assert {:ok, _} =
                 FlyMachineClient.create_secret(
                   app_params.app_name,
                   @test_secret_label,
                   @test_secret_type,
                   @test_secret_value
                 )

        # Destroy the secret
        assert {:ok, _} = FlyMachineClient.destroy_secret(app_params.app_name, @test_secret_label)

        # Verify it's gone
        {:ok, secrets} = FlyMachineClient.list_secrets(app_params.app_name)
        refute Enum.any?(secrets, &(&1["label"] == @test_secret_label))
      end
    end

    test "returns error for non-existent secret" do
      app_params = %{
        app_name: "#{@test_app_name}-destroy-error",
        org_slug: "personal",
        network: "custom-network",
        enable_subdomains: true
      }

      use_cassette "secrets/destroy_error" do
        # Create an app first
        {:ok, created_app} = FlyMachineClient.create_app(app_params)
        assert Map.has_key?(created_app, "id")

        assert {:error, "Unexpected error occurred"} =
                 FlyMachineClient.destroy_secret(app_params.app_name, "non-existent-secret")
      end
    end
  end
end
