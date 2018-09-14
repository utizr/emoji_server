# Emoji

This app is responsible for syncing the emojis with the unicode.org site's emoji list.
It checks every day if there was an update on the site making a head request and checking the modification date. If the modification date is different from the locally saved one, it will grab the content and saved it on disk along with the last modifictation date.
After fetching the content, it will extract the emojis, and save them in :ets.
The `Emoji` module provides an api to query the emojis. Usage example:

```
# iex -S mix
iex(1)> Emoji.search "racing car"

20:12:31.816 [info]  Queries took: 3ms
[
  %{
    category: "Travel and Places",
    emoji: "🏎",
    name: "racing car",
    sub_category: "transport ground"
  }
]
```

## Todo:

- add option to not sync with the unicode website, and only use the currenlty available emojis on the server.
