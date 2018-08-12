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

end
