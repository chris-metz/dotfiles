stow_common:
	stow -v -t ~ common
	ln -sf {{justfile_directory()}}/common/.config/kitty/hosts/$(hostname).conf ~/.config/kitty/current-host.conf
unstow_common:
	stow -v -D -t ~ common
	rm -f ~/.config/kitty/current-host.conf
