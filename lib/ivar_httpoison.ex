defmodule Ivar.HTTPoison do
  @moduledoc """
  The `Ivar.HTTPoison` module provides the `HTTPoison` adapter implementation for the `Ivar` HTTP client module.
  """

  @behaviour Ivar.Adapter

  @doc """
  This function executes a given `Ivar` request using `HTTPoison`.
  
  Args
  
    * `request` - the map containing the request options to send, usually created via `Ivar.new/2`
  """
  @spec execute(map) :: {:ok, map} | {:error, binary | atom}
  def execute(request) do
    request = prepare_files(request)

    HTTPoison.request(
      request.method,
      request.url,
      Map.get(request, :body, ""),
      Map.get(request, :headers, []),
      Map.get(request, :opts, []))
  end

  defp prepare_files(%{files: files} = request) do
    content = request
    |> Map.get(:body, "")
    |> get_body_content
    |> URI.decode_query
    |> Enum.reduce([], fn (f, acc) -> [f | acc] end)
    |> Kernel.++(files)

    request
    |> Map.put(:body, {:multipart, content})
    |> Map.drop([:files])
  end
  defp prepare_files(request), do: request

  defp get_body_content(""), do: ""
  defp get_body_content({_, _, content}), do: content
  defp get_body_content(body), do: body
end
