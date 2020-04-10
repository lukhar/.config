c.auto_save.session = True

from sys import platform
if platform == 'darwin':
    c.fonts.completion.category = 'bold 12pt monospace'
    c.fonts.completion.entry = '12pt monospace'
    c.fonts.debug_console = '12pt monospace'
    c.fonts.downloads = '12pt monospace'
    c.fonts.hints = 'bold 14pt monospace'
    c.fonts.keyhint = '12pt monospace'
    c.fonts.messages.error = '12pt monospace'
    c.fonts.messages.info = '12pt monospace'
    c.fonts.messages.warning = '12pt monospace'
    c.fonts.prompts = '12pt sans-serif'
    c.fonts.statusbar = '12pt monospace'
    c.fonts.tabs = '12pt monospace'
else:
    c.fonts.completion.category = 'bold 9pt monospace'
    c.fonts.completion.entry = '9pt monospace'
    c.fonts.debug_console = '9pt monospace'
    c.fonts.downloads = '9pt monospace'
    c.fonts.hints = 'bold 11pt monospace'
    c.fonts.keyhint = '9pt monospace'
    c.fonts.messages.error = '9pt monospace'
    c.fonts.messages.info = '9pt monospace'
    c.fonts.messages.warning = '9pt monospace'
    c.fonts.prompts = '9pt sans-serif'
    c.fonts.statusbar = '9pt monospace'
    c.fonts.tabs = '9pt monospace'
    c.fonts.default_family = ['NotoSans Nerd Font']
    c.fonts.web.family.standard = 'NotoSans Nerd Font'
    c.fonts.web.family.fixed = 'DroidSansMono Nerd Font'

c.url.searchengines = {'g': 'https://encrypted.google.com/search?q={}', 'DEFAULT': 'https://duckduckgo.com/?q={}'}
