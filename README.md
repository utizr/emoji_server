# EmojiServer

**TODO: Add description**

## search in interactive shell:

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

## test search route:

```
url localhost:8088/emoji/search/?query=racing+car
```