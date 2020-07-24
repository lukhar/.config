from sys import platform

c.auto_save.session = True

if platform != "darwin":
    c.downloads.location.directory = "~/downloads/"

    config.bind(",m", "spawn mpv {url}")
    config.bind(",M", "hint links spawn mpv {hint-url}")

c.url.searchengines = {
    "g": "https://encrypted.google.com/search?q={}",
    "d": "https://duckduckgo.com/?q={}",
    "y": "https://www.youtube.com/results?search_query={}",
    "wa":"https://wiki.archlinux.org/index.php?search={}",
    "DEFAULT": "https://duckduckgo.com/?q=g! {}",
}
