# for matching this should work "cat dog fish" =~ ~r/(?=.*dog)(?=.*cat)/
# the idea is to add all emojis like this <emojicode>=tags of the emoji=

defmodule Emoji.Store do

  def initialize_store() do
    if :ets.info(:emoji) == :undefined do
      :ets.new(:emoji, [:public, :named_table, read_concurrency: true])
    end
  end

  def insert(table, id, item) do
    :ets.insert(table, {id, item})
  end

  def search_emoji(search_text) do
    search_words = create_words(search_text)

    :ets.tab2list(:emoji)
    |> Enum.reduce([], fn entry, accu ->
      {_, emoji} = entry

      case find_words_in_text(emoji.all_text, search_words) do
        true ->
          [emoji | accu]
        false ->
          accu
      end
    end)
  end

  defp create_words(search_text) do
    words = search_text
    |> String.trim()
    |> String.replace(~r/\s{2,}/, " ") # replace multiple spaces with one space
    |> String.replace(~r/[^\p{L} ]/, "") # remove everything but chars (including foreign chars) and spaces
    |> String.downcase
    |> String.split(" ")
  end

  defp find_words_in_text(source_string, words) do
    Enum.reduce(words, true, fn word, result -> 
      (source_string =~ word) and result
    end)
  end

end
