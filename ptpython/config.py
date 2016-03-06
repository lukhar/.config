from __future__ import unicode_literals

__all__ = (
    'configure',
)


def configure(repl):
    repl.vi_mode = True
    repl.use_code_colorscheme('vim')
