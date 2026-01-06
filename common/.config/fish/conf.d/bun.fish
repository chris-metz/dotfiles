set bun_path ~/.bun/bin

if test -d $bun_path
    if not contains $bun_path $fish_user_paths
        fish_add_path $bun_path
    end
end
