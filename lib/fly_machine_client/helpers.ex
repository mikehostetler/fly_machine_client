defmodule FlyMachineClient.Helpers do
  @moduledoc false

  require Logger

  def validate_params(params, options) do
    case NimbleOptions.validate(params, options) do
      {:ok, validated_params} -> {:ok, Map.new(validated_params)}
      {:error, error} -> {:error, error}
    end
  end

  def handle_request(request, operation) do
    request
    |> handle_response()
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, error} -> log_and_return_error(operation, error)
    end
  end

  def handle_response({:ok, %{status: status, body: body}}) when status in 200..299,
    do: {:ok, body}

  def handle_response({:ok, %{status: status, body: body}}),
    do: {:error, build_error(status, body)}

  def handle_response({:error, reason}), do: {:error, build_error(nil, reason)}

  defp build_error(status, details) do
    message =
      case details do
        %{"error" => error} -> error
        _ -> error_message(status)
      end

    %{
      status: status || 500,
      message: message,
      details: details
    }
  end

  defp error_message(nil), do: "Unexpected error occurred"
  defp error_message(status) when status in 400..499, do: "Client error occurred"
  defp error_message(status) when status in 500..599, do: "Server error occurred"
  defp error_message(_), do: "Unknown error occurred"

  defp log_and_return_error(operation, %{status: status, message: message, details: details}) do
    Logger.warning("Fly API error in #{operation}: #{status} - #{message}",
      operation: operation,
      status: status,
      details: inspect(details)
    )

    {:error, message}
  end
end
