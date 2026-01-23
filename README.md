# Kaar nvim config

```sh
git clone https://github.com/kaar/nvim-config
ln -fs $PWD/nvim ~/.config/nvim
```

* [Plugins](./nvim/lua/plugins/README.md)

## Notes

### gx - Open file under cursor

The `gx` mapping in Neovim opens files/URLs under the cursor using the system default application. In Neovim 0.10+, this calls `vim.ui.open()` which delegates to `xdg-open` on Linux.

The default application is configured via XDG MIME associations stored in `~/.config/mimeapps.list`.

**Debug which config file is used:**
```bash
XDG_UTILS_DEBUG_LEVEL=3 xdg-mime query default application/pdf
```

**Set default application:**
```bash
xdg-mime default firefox.desktop application/pdf
```

Reference: [XDG MIME Applications - ArchWiki](https://wiki.archlinux.org/title/XDG_MIME_Applications)
