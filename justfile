stow_common:
	stow -v -R common
	ln -sf {{justfile_directory()}}/common/.config/kitty/hosts/$(hostname).conf ~/.config/kitty/current-host.conf
unstow_common:
	stow -v -D common
	rm -f ~/.config/kitty/current-host.conf

stow_pi:
	stow -v -R pi
unstow_pi:
	stow -v -D pi
