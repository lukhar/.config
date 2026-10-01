# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Neovim Configuration Structure

This is a modern Neovim configuration using Lazy.nvim as the plugin manager. The configuration follows a modular structure:

### Core Architecture

- **Entry Point**: `init.lua` - Minimal entry point that loads core modules
- **Global Settings**: `lua/globals.lua` - Leader keys and Python provider configuration
- **Configuration**: `lua/config/` - Core Neovim settings and keymaps
  - `init.lua` - Sets up Lazy.nvim plugin manager with configuration
  - `options.lua` - All Neovim options, autocommands, and UI settings
  - `keymaps.lua` - Custom key mappings
- **Plugins**: `lua/plugins/` - Plugin configurations (one file per plugin/category)
- **Custom Plugins**: `lua/custom/plugins/` - Custom or heavily modified plugin configurations

### Plugin Management

Uses Lazy.nvim with these key features:
- Plugins are lazy-loaded by default (overridden to `lazy = false`)
- Plugin configurations are modularized in separate files
- Disabled built-in plugins for performance: gzip, matchit, netrw, etc.
- Default colorscheme: solarized

### Key Features

1. **AI Integration**: Custom `lgpt` plugin for OpenAI integration
   - `:Lgen` command for AI queries (supports visual selection)
   - Streaming and non-streaming modes
   - Currently configured for OpenAI API

2. **Session Management**: Automatic session creation in Git repositories
   - Sessions saved to `.vim/session.vim` using vim-obsession

3. **Window Management**: Visual feedback for active/inactive windows
   - Uses Solarized color scheme for dimming inactive panes

4. **Development Tools**: 
   - LSP integration (nvim-jdtls for Java)
   - Telescope for fuzzy finding
   - Treesitter for syntax highlighting
   - Git integration (fugitive, gitsigns)

### Configuration Reload

The configuration includes a live reload system:
- `<leader>R` reloads the entire configuration
- Uses plenary.reload for module reloading

### Python Environment

Configured for Neovim development with pyenv:
- Python provider: `~/.pyenv/versions/neovim/bin/python`
- Python 2 provider disabled for performance

### Custom Key Mappings

- Leader key: Space
- `jk`/`kj` for escaping insert mode
- Alt+hjkl for window resizing
- `;e` and `;f` for fuzzy file opening
- `cp` for copying to system clipboard

## File Modification Guidelines

When modifying this configuration:

1. **Plugin Changes**: Add new plugins to appropriate files in `lua/plugins/`
2. **Options**: Modify `lua/config/options.lua` for Neovim settings
3. **Keymaps**: Add custom keymaps to `lua/config/keymaps.lua`
4. **Custom Plugins**: Place heavily customized plugins in `lua/custom/plugins/`

The configuration automatically manages sessions for Git repositories and includes comprehensive error handling and user experience features.