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
    c.fonts.completion.category = "bold 9pt monospace"
    c.fonts.completion.entry = "9pt monospace"
    c.fonts.debug_console = "9pt monospace"
    c.fonts.downloads = "9pt monospace"
    c.fonts.hints = "bold 11pt monospace"
    c.fonts.keyhint = "9pt monospace"
    c.fonts.messages.error = "9pt monospace"
    c.fonts.messages.info = "9pt monospace"
    c.fonts.messages.warning = "9pt monospace"
    c.fonts.prompts = "9pt sans-serif"
    c.fonts.statusbar = "9pt monospace"
    c.fonts.tabs = "9pt monospace"
    c.fonts.web.family.standard = "NotoSans Nerd Font"
    c.fonts.web.family.fixed = "DroidSansMono Nerd Font"
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
