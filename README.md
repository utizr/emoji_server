# EmojiServer

Emoji server providing a simple search API. It auto syncs with the unicode.org site to fetch the latest emoji list.
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
The docker file will build the release with distillery 2.0.
You can then run the built docker image and expose port 8088 as in below example.

```
docker build . -t emoji_server_image
docker run -d --name emoji_server -p 8088:8088 emoji_server_image

# then if you want to stop it: 
docker stop emoji_server
```

## building in docker for linux target
If you are developing on MAC for example and would like to build the app for a linux server, you can also make use of docker.
Just build the docker image which will create the linux artifacts, and copy the files out of docker to your machine.

```
# build the image as in the above step:
docker build . -t emoji_server_image

# cd into a folder where you would like to copy the _build folder to on your host machine and execute:
docker run -v `pwd`:/linux-build -w /linux-build -i -t emoji_server_image cp -R /app/_build .

# you will find the _build folder in your current directory
```