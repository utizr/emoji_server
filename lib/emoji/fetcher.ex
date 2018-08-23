defmodule Emoji.Fetcher do
  @moduledoc """
  Documentation for Emoji.
  """
  @user_agent [{"User-agent", "chrome"}]
  @folder "./temp/"
  @html_file "emoji-full-list.html"
  @date_file "last_mod_date.txt"



  # get head and check last modification date
  def get_head do
    url()
    |> HTTPoison.head!(@user_agent)
    |> get_last_modified
  end

  # download the emoji data
  def get_data do
    IO.puts "fetching..."
    url()
    |> HTTPoison.get(@user_agent)
    |> handle_response
    |> write_to_file
  end



  def data_updated? do
    with {:ok, saved_date} <- get_saved_date(),
      {:ok, mod_date} <- get_head(),
      true <- up_to_date?(saved_date, mod_date)
    do
      IO.puts "Local Data up to date."
      :ok
    else
      _ ->
        IO.puts "Data needs to be fetched."
        :error
    end
  end

  defp up_to_date?(saved_date, mod_date) do
    saved_date = date_to_unix(saved_date)
    mod_date = date_to_unix(mod_date)
    saved_date >= mod_date
  end

  defp get_saved_date do
    File.read(Path.absname("#{@folder}#{@date_file}"))
  end

  defp url do
    "https://unicode.org/emoji/charts/full-emoji-list.html"
  end

  defp get_last_modified(%HTTPoison.Response{headers: headers}) do
    {"Last-Modified", date} = Enum.find(headers, fn {name, _} -> name == "Last-Modified" end)
    {:ok, date}
  end

  defp get_last_modified(_) do
    :error
  end

  defp write_date_to_file(date) do
    Path.absname("#{@folder}#{@date_file}")
    |> File.write(date)
  end

  defp date_to_unix(date_str) do
    Timex.parse!(date_str, "{RFC1123}")
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    IO.puts "fetch Completed, replacing inline images to reduce size.."
    Regex.replace(~r/'data:.*'/, body, "yyy")
  end

  defp write_to_file(data) do
    IO.puts "replace completed, saving.."
    Path.absname("#{@folder}#{@html_file}")
    |> File.write(data)
  end

end
