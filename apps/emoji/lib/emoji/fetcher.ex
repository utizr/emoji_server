defmodule Emoji.Fetcher do
  require Logger
  @moduledoc """
  Documentation for Emoji.
  """
  @user_agent [{"User-agent", "chrome"}]
  @folder "./assets/"
  @html_file "emoji-full-list.html"
  @date_file "last_mod_date.txt"

  def start() do
    with :data_outdated <- local_data_up_to_date?(),
      :ok <- get_data()
    do
      Logger.info "Data loaded successfully."
      :data_refreshed
    else
      :data_uptodate ->
        Logger.info "Data up to date!"
        :data_uptodate
      _ ->
        Logger.info "unknown error occured at fetching data"
        :error
    end
  end

  # get head and check last modification date
  def get_head do
    url()
    |> HTTPoison.head!(@user_agent)
    |> extract_last_modified
  end

  # download the emoji data
  def get_data do
    Logger.info "Fetching data..."
    url()
    |> HTTPoison.get(@user_agent)
    |> handle_response
    |> write_to_file
  end

  defp local_data_up_to_date? do
    with {:ok, saved_date} <- get_saved_date(),
      {:ok, mod_date} <- get_head(),
      true <- up_to_date?(saved_date, mod_date)
    do
      :data_uptodate
    else
      _ ->
        Logger.info "Data outdated.."
        :data_outdated
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

  defp extract_last_modified(%HTTPoison.Response{headers: headers}) do
    {"Last-Modified", date} = Enum.find(headers, fn {name, _} -> name == "Last-Modified" end)
    {:ok, date}
  end

  defp extract_last_modified(_) do
    :error
  end

  defp write_last_modified_to_file(date) do
    Path.absname("#{@folder}#{@date_file}")
    |> File.write(date)
  end

  defp date_to_unix(date_str) do
    Timex.parse!(date_str, "{RFC1123}")
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body} = response}) do
    Logger.info "fetch Completed, replacing inline images to reduce size.."
    {:ok, mod_date} = extract_last_modified(response)
    write_last_modified_to_file(mod_date)
    Regex.replace(~r/'data:.*'/, body, "yyy")
  end

  defp write_to_file(data) do
    Logger.info "replace completed, saving.."
    Path.absname("#{@folder}#{@html_file}")
    |> File.write(data)
  end

end
