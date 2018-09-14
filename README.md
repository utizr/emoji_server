# EmojiServer

Emoji server providing a simple search API. It auto syncs with the unicode.org site to fetch latest emoji list.
The idea is to only use emojis that are supported in all major operating system, and the unicode site provides this information.

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
curl localhost:8088/emoji/search/?query=racing+car
```

## docker usage:

```
docker build . -t emoji_server_image
docker run -d --name emoji_server -p 8088:8088 emoji_server_image

# then if you want to stop it: 
docker stop emoji_server
```