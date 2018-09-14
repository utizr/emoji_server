defmodule Emoji.Store do

  @moduledoc """
  Reponsible for: 

    - initializing the :ets store for the emojis
    - saving emojis into :ets
    - searching emojis
  """

  def initialize_store() do
    if tab_info() == :undefined do
      :ets.new(:emoji, [:public, :named_table, read_concurrency: true])
    end
  end

  def count() do
    tab_info() |> Keyword.get(:size)
  end

  def tab_info do
    :ets.info(:emoji)
  end

  def insert(table, id, item) do
    :ets.insert(table, {id, item})
  end

  # should be extended/generalized
  def find_by_category(category) do
    :ets.match_object(:emoji, {:"_", %{category: category}})
  end

  # might be usefull to create only retrieve keys and search in those.. :
  # https://stackoverflow.com/questions/35122608/how-to-retrieve-a-list-of-ets-keys-without-scanning-entire-table
  def search_emoji(search_text) do
    search_words = create_words(search_text)

    :ets.tab2list(:emoji)
    |> find_emojis(search_words)
  end

  def search_emoji(search_text, %{category: category}) do
    search_words = create_words(search_text)
    
    :ets.match_object(:emoji, {:"_", %{category: category}})
    |> find_emojis(search_words)
  end

  def search_emoji(search_text, %{sub_category: sub_category}) do
    search_words = create_words(search_text)

    :ets.match_object(:emoji, {:"_", %{sub_category: sub_category}})
    |> find_emojis(search_words)
  end

  defp find_emojis(emojis, search_words) do
    Enum.reduce(emojis, [], fn entry, accu ->
      {_, emoji} = entry

      case find_words_in_text(emoji.all_text, search_words) do
        true ->
          emoji = Map.take(emoji, [:name,:emoji,:category,:sub_category])
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
