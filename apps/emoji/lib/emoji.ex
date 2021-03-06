defmodule Emoji do
  require Logger

  # fetches head data of the emoji-list html
  defdelegate get_head, to: Emoji.Fetcher
  # fetches the emoji-list html, and saves it as a file
  defdelegate get_data, to: Emoji.Fetcher
  # extracts the emojis from the emoji-list html file
  defdelegate extract_data_from_file, to: Emoji.Extractor

  def search(search_text) do
    start_time = :os.system_time(:millisecond)
    emojis = Emoji.Store.search_emoji(search_text)
    end_time = :os.system_time(:millisecond)
    Logger.info "Queries took: #{end_time - start_time}ms"
    emojis
  end

  def search(search_text, opts) do
    start_time = :os.system_time(:millisecond)
    emojis = Emoji.Store.search_emoji(search_text, opts)
    end_time = :os.system_time(:millisecond)
    Logger.info "Queries took: #{end_time - start_time}ms"
    emojis
  end

end
