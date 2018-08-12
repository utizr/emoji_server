defmodule Emoji.Transformer do
  @moduledoc """
  Documentation for Emoji.
  """

  # extract data from file
  def transform_file do
    # Path.absname("./emoji-full-list.html")
    Path.absname("./temp/sample.html")
    |> File.stream!()
    |> Stream.transform(0, &transformer/2)
    # |> Enum.into(File.stream!("output.txt"))
    |> Stream.run()
  end
  
  defp transformer(line, 0) do
    transformer(line, %{})
  end

  defp transformer(line, accu) do
    accu = handle_line(line, accu)
    # IO.puts "accu"
    # IO.inspect accu
    {[], accu}
  end

  # main Category
  defp handle_line("<tr><th colspan='15' class='bighead'>" <> rest, accu) do
    title = get_title(rest)
    IO.puts "Category: \t\t#{title}"
    Map.put(accu, :category, title)
  end

  # sub Category
  defp handle_line("<tr><th colspan='15' class='mediumhead'>" <> rest, accu) do
    title = get_title(rest)
    IO.puts "Sub Category: \t#{title}"
    Map.put(accu, :sub_category, title)
  end

  # emoji number
  defp handle_line("<tr><td class='rchars'>" <> rest, accu) do
    number = get_emoji_number(rest)
    IO.puts "Number: \t#{number}"
    accu
  end

  defp handle_line(_, accu) do
    accu
  end

  defp get_title(line) do
    case Regex.named_captures(~r/>(?<title>[^>]*)<\/a>/, line) do
      %{"title" => title} ->
        title 
          |> String.replace("&amp;","and") 
          |> String.replace("-"," ") 
      _ ->
        "not_found"
    end
  end

  defp get_emoji_number(line) do
    case Regex.named_captures(~r/^(?<emoji_number>[0-9]*)<\/td>/, line) do
      %{"emoji_number" => number} ->
        number
      _ ->
        "number_not_found"
    end
  end
end
