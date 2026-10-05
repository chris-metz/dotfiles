[macos]
setup: stow_common link_claude_mods setup_macos
[linux]
setup: stow_common link_claude_mods
stow_common:
	stow -v -R common
unstow_common:
	stow -v -D common
link_claude_mods:
	#!/usr/bin/env bash
	set -euo pipefail
	shopt -s nullglob
	mkdir -p "$HOME/.claude/skills"
	for dir in "{{justfile_directory()}}"/claude-mods/*/; do
		dir="${dir%/}"
		link="$HOME/.claude/skills/mod-$(basename "$dir")"
		if [ -e "$link" ] && [ ! -L "$link" ]; then
			echo "$link is a real folder, move it into claude-mods/ first" >&2
			exit 1
		fi
		ln -sfnv "$dir" "$link"
	done
setup_macos:
	sh macos/setup.sh
backup_macos_keyboard:
	macos/keyboard-modifier-mapping backup
