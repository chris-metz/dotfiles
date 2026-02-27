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
