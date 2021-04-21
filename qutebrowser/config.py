from sys import platform


config.load_autoconfig(False)

c.auto_save.session = True

if platform != "darwin":
    c.downloads.location.directory = "~/downloads/"

    c.fonts.default_family = "Liberation Sans"
    c.fonts.default_size = "10pt"

    c.fonts.web.family.fixed = "Liberation Mono"
    c.fonts.web.family.sans_serif = "Liberation Sans"
    c.fonts.web.family.standard = "Liberation Sans"
    c.fonts.web.family.serif = "Liberation Serif"

    config.bind(",m", "spawn mpv {url}")
    config.bind(",M", "hint links spawn mpv {hint-url}")

else:
    c.fonts.default_size = "14pt"

c.url.searchengines = {
    "g": "https://encrypted.google.com/search?q={}",
    "d": "https://duckduckgo.com/?q={}",
    "y": "https://www.youtube.com/results?search_query={}",
    "wa":"https://wiki.archlinux.org/index.php?search={}",
    "DEFAULT": "https://duckduckgo.com/?q=g! {}",
}
