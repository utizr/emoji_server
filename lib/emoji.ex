defmodule Emoji do
  @moduledoc """
  Documentation for Emoji.
  """

  # fetches head data of the emoji-list html
  defdelegate get_head, to: Emoji.Fetcher
  # fetches the emoji-list html, and saves it as a file
  defdelegate get_data, to: Emoji.Fetcher
  # extracts the emojis from the emoji-list html file
  defdelegate transform_file, to: Emoji.Transformer

  def search_emoji(search_text) do
    start_time = :os.system_time(:millisecond)
    emojis = Emoji.Store.search_emoji(search_text)
    IO.puts "Queries took: #{:os.system_time(:millisecond) - start_time}"
    emojis
  end

end
