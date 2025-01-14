defmodule FlyMachineClientTest do
  use ExUnit.Case

  # describe "apps" do
  #   test "list_apps/2 returns list of apps" do
  #     expect(Tesla, :get, fn client, "/apps", [query: [org_slug: "personal"]] ->
  #       assert client

  #       {:ok,
  #        %Tesla.Env{
  #          status: 200,
  #          body: [
  #            # TODO: Replace with valid app data structure
  #            %{
  #              "name" => "test-app-1",
  #              "organization" => %{"slug" => "personal"}
  #            }
  #          ]
  #        }}
  #     end)

  #     assert {:ok, [app]} = FlyMachineClient.list_apps()
  #     assert app["name"] == "test-app-1"
  #   end

  #   test "create_app/2 creates a new app" do
  #     app_params = %{
  #       app_name: "test-app",
  #       org_slug: "personal",
  #       network: "custom-network",
  #       enable_subdomains: true
  #     }

  #     expect(Tesla, :post, fn client, "/apps", params ->
  #       assert client
  #       assert params[:app_name] == "test-app"
  #       assert params[:org_slug] == "personal"

  #       {:ok,
  #        %Tesla.Env{
  #          status: 201,
  #          body: %{
  #            # TODO: Replace with valid created app response
  #            "name" => params[:app_name],
  #            "organization" => %{"slug" => params[:org_slug]}
  #          }
  #        }}
  #     end)

  #     assert {:ok, app} = FlyMachineClient.create_app(app_params)
  #     assert app["name"] == "test-app"
  #   end

  #   test "create_app/2 validates required parameters" do
  #     app_params = %{
  #       network: "custom-network",
  #       enable_subdomains: true
  #     }

  #     assert {:error, :invalid_params} = FlyMachineClient.create_app(app_params)
  #   end

  #   test "get_app/2 returns app details" do
  #     app_name = "test-app"

  #     expect(Tesla, :get, fn client, "/apps/" <> ^app_name ->
  #       assert client

  #       {:ok,
  #        %Tesla.Env{
  #          status: 200,
  #          body: %{
  #            # TODO: Replace with valid app details response
  #            "name" => app_name,
  #            "organization" => %{"slug" => "personal"}
  #          }
  #        }}
  #     end)

  #     assert {:ok, app} = FlyMachineClient.get_app(app_name)
  #     assert app["name"] == app_name
  #   end

  #   test "get_app/2 handles not found error" do
  #     app_name = "non-existent-app"

  #     expect(Tesla, :get, fn client, "/apps/" <> ^app_name ->
  #       assert client

  #       {:ok,
  #        %Tesla.Env{
  #          status: 404,
  #          body: %{
  #            "error" => "App not found"
  #          }
  #        }}
  #     end)

  #     assert {:error, "App not found"} = FlyMachineClient.get_app(app_name)
  #   end

  #   test "destroy_app/2 deletes an app" do
  #     app_name = "test-app"

  #     expect(Tesla, :delete, fn client, "/apps/" <> ^app_name ->
  #       assert client
  #       {:ok, %Tesla.Env{status: 200, body: nil}}
  #     end)

  #     assert {:ok, nil} = FlyMachineClient.destroy_app(app_name)
  #   end

  #   test "destroy_app/2 handles not found error" do
  #     app_name = "non-existent-app"

  #     expect(Tesla, :delete, fn client, "/apps/" <> ^app_name ->
  #       assert client

  #       {:ok,
  #        %Tesla.Env{
  #          status: 404,
  #          body: %{
  #            "error" => "App not found"
  #          }
  #        }}
  #     end)

  #     assert {:error, "App not found"} = FlyMachineClient.destroy_app(app_name)
  #   end
  # end
end
