defmodule Emoji.Fetcher do
  @moduledoc """
  Documentation for Emoji.
  """
  @user_agent [{"User-agent", "chrome"}]

  defp url do
    "https://unicode.org/emoji/charts/full-emoji-list.html"
  end

  # get head and check last modification date
  def get_head do
    url()
    |> HTTPoison.head!(@user_agent)
    |> get_last_modified
    |> IO.puts
  end

  defp get_last_modified(%HTTPoison.Response{headers: headers}) do
    {"Last-Modified", date} = Enum.find(headers, fn {name, _} -> name == "Last-Modified" end)
    date
  end

  # download the emoji data
  def get_data do
    url()
    |> HTTPoison.get(@user_agent)
    |> handle_response
    |> write_to_file
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    body
  end

  defp write_to_file(data) do
    Path.absname("./temp/emoji-full-list.html")
    |> File.write(data)
  end

end
