# dotfiles

## Kitty + SSH + tmux

If a remote `tmux` session fails with `missing or unsuitable terminal: xterm-kitty`, run:

```fish
kitty_terminfo <host>
```

The function copies the local `xterm-kitty` terminfo entry to the remote `~/.terminfo` and verifies it.

Examples:

```fish
kitty_terminfo harry
kitty_terminfo harry user@db-01
```

Manual one-liner:

```bash
infocmp -x xterm-kitty | ssh HOST 'mkdir -p ~/.terminfo && tic -x -o ~/.terminfo /dev/stdin'
```

## macOS

`macos/setup.sh` applies system settings that stow cannot cover, currently the
per-keyboard modifier key mapping (Caps Lock → Globe on the external keyboard, so
Wispr Flow's Fn hotkey works there too). It is idempotent:

```fish
just setup_macos
```

After changing a mapping in System Settings, refresh the generated block in
`setup.sh` with `just backup_macos_keyboard` (or `macos/keyboard-modifier-mapping show`
to only print the current mapping).
