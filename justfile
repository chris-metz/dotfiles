stow_common:
	stow -v -R common
unstow_common:
	stow -v -D common
setup_macos:
	sh macos/setup.sh
backup_macos_keyboard:
	macos/keyboard-modifier-mapping backup
