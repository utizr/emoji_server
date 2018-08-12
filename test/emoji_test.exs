defmodule EmojiTest do
  use ExUnit.Case
  doctest Emoji

  test "greets the world" do
    assert Emoji.hello() == :world
  end
end
