defmodule Emoji.Extractor do
  alias Emoji.Store

  # extract data from file
  def extract_data_from_file do
    IO.puts "Extracting emojis from html file.."
    Store.initialize_store()
    Path.absname("./temp/emoji-full-list.html")
    |> File.stream!()
    |> Stream.transform(0, &extractor/2)
    |> Stream.run()
    IO.puts "Extraction completed, you can start querying!"
    "ok"
  end
  
  defp extractor(line, 0) do
    extractor(line, %{})
  end

  defp extractor(line, accu) do
    {line, accu} = case handle_line(line, accu) do
      {emoji, accu} ->
        {[emoji], accu}
      accu ->
        {[], accu}
    end

    {line, accu}
  end

  # main Category
  defp handle_line("<tr><th colspan='15' class='bighead'>" <> rest, accu) do
    title = get_title(rest)
    Map.put(accu, :category, title)
  end

  # sub Category
  defp handle_line("<tr><th colspan='15' class='mediumhead'>" <> rest, accu) do
    title = get_title(rest)
    Map.put(accu, :sub_category, title)
  end

  # TODO can be removed
  # emoji number
  # this is the first entry point to an emoji
  defp handle_line("<tr><td class='rchars'>" <> rest, accu) do
    number = get_emoji_number(rest)

    Map.put(accu, :emoji, %{number: number, support_counter: 0})
  end

  # emoji code
  # complex ones should be marked. eg:
  # <td class='code'><a href='#1f471_200d_2642_fe0f' name='1f471_200d_2642_fe0f'>U+1F471 U+200D U+2642 U+FE0F</a></td>
  defp handle_line("<td class='code'>" <> rest, %{emoji: emoji} = accu) do
    code = get_emoji_code(rest)

    emoji = Map.put(emoji, :code, code)
    Map.put(accu, :emoji, emoji)
  end

  # get the actual emoji
  defp handle_line("<td class='chars'>" <> rest, %{emoji: emoji} = accu) do
    emoji_char = get_emoji(rest)

    emoji = Map.put(emoji, :emoji, emoji_char)
    Map.put(accu, :emoji, emoji)
  end
 
  # check supported platforms
  defp handle_line("<td class='andr" <> rest, %{emoji: emoji} = accu) do
    support_counter = emoji.support_counter
    support_counter = support_counter + get_support_count(rest)

    emoji = Map.put(emoji, :support_counter, support_counter)
    Map.put(accu, :emoji, emoji)
  end
 

  # this is the last needed line for the emoji,
  # we can save at this point
  defp handle_line("<td class='name'>" <> rest, %{emoji: emoji} = accu) do
    name = get_emoji_name(rest)

    emoji = emoji
      |> Map.put(:name, name)
      |> Map.put(:category, accu.category)
      |> Map.put(:sub_category, accu.sub_category)
      |> Map.put(:all_text, "#{accu.category} #{accu.sub_category} #{name}" |> String.downcase)
      |> save_emoji

    case emoji do
      nil ->
        accu
      emoji ->
        {emoji, accu}
    end
    
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
          |> String.replace("⊛", "")

      _ ->
        "not_found"
    end
  end

  defp save_emoji(nil) do
    nil
  end

  defp save_emoji(%{support_counter: supported_platforms} = emoji) when supported_platforms >= 6 do
    Store.insert(:emoji, emoji.code, emoji)
    emoji.emoji
  end

  defp save_emoji(_) do
    nil
  end

  # this is the first line of an emoji, 
  # so at this point we should check if we collected an emoji and saved it
  defp get_emoji_number(line) do
    case Regex.named_captures(~r/^(?<emoji_number>[0-9]*)<\/td>/, line) do
      %{"emoji_number" => number} ->
        number
      _ ->
        "number_not_found"
    end
  end

  defp get_emoji_name(line) do
    case Regex.named_captures(~r/^(?<emoji_name>.*)<\/td>/, line) do
      %{"emoji_name" => name} ->
        name
          |> String.replace("&amp;","and") 
          |> String.replace(":","") 
          |> String.replace(".","")
        
      _ ->
        "number_not_found"
    end
  end
  
  defp get_support_count(line) do
    case Regex.match?(~r/img/, line) do
      true ->
        1
      _ ->
        0
    end
  end

  
  defp get_emoji_code(line) do
    case Regex.named_captures(~r/name='(?<code>[^']*)'/, line) do
      %{"code" => code} ->
        code
      _ ->
        "code_not_found"
    end
  end

  defp get_emoji(line) do
    case Regex.named_captures(~r/^(?<emoji>.*)<\/td>/, line) do
      %{"emoji" => emoji} ->
        emoji
      _ ->
        "number_not_found"
    end
  end
end
