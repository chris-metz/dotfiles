set flutter_path ~/sdk/flutter/bin

if test -d $flutter_path
    if not contains $flutter_path $fish_user_paths
        fish_add_path $flutter_path
    end
end
