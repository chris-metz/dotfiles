if command -q nvim
    set -gx EDITOR (command -s nvim)
else
    set -gx EDITOR vim
end
