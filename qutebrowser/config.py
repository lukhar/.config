from sys import platform

c.auto_save.session = True

if platform == "darwin":
    c.fonts.completion.category = "bold 14pt monospace"
    c.fonts.completion.entry = "14pt monospace"
    c.fonts.debug_console = "14pt monospace"
    c.fonts.downloads = "14pt monospace"
    c.fonts.hints = "bold 14pt monospace"
    c.fonts.keyhint = "14pt monospace"
    c.fonts.messages.error = "14pt monospace"
    c.fonts.messages.info = "14pt monospace"
    c.fonts.messages.warning = "14pt monospace"
    c.fonts.prompts = "14pt sans-serif"
    c.fonts.statusbar = "14pt monospace"
    c.fonts.tabs = "14pt monospace"
else:
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
