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
    :ets.tab2list(:emoji)
    |> Enum.reduce([], fn entry, accu ->
      {_, emoji} = entry

      all_text = [emoji.category, emoji.sub_category, emoji.name]
        |> Enum.join(" ")
      case find_in_text(all_text, search_text) do
        true ->
          [emoji | accu]
        false ->
          accu
      end
    end)
  end

  defp find_in_text(source_string, search_text) do
    words = search_text
    |> String.trim()
    |> String.replace(~r/\s{2,}/, " ") # replace multiple spaces with one space
    |> String.replace(~r/[^\p{L} ]/, "") # remove everything but chars (including foreign chars) and spaces
    |> String.downcase
    |> String.split(" ")

    reg_string = Enum.map(words, fn word -> "(?=.*#{word})" end)
    |> Enum.join("")

    source_string = source_string |> String.downcase
    source_string =~ ~r/#{reg_string}/
  end

end
