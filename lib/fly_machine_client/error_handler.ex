defmodule FlyMachineClient.ErrorHandlerMiddleware do
  @moduledoc false
  @behaviour Tesla.Middleware

  require Logger

  def call(env, next, _options) do
    env
    |> Tesla.run(next)
    |> handle_errors()
  end

  defp handle_errors({:ok, env}) do
    if env.status >= 400 do
      Logger.warning("Fly API response: #{env.status}",
        status: env.status,
        body: inspect(env.body),
        method: env.method,
        url: env.url
      )
    end

    {:ok, env}
  end

  defp handle_errors({:error, reason} = error) do
    Logger.warning("Fly API request failed", error: inspect(reason))
    error
  end
end
