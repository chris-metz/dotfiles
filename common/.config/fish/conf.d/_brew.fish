# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

set brew_path_linux /home/linuxbrew/.linuxbrew/bin

if test -d $brew_path_linux
    if not contains $brew_path_linux $fish_user_paths
        fish_add_path $brew_path_linux
    end
end

if type -q brew
    eval (brew shellenv)
end
