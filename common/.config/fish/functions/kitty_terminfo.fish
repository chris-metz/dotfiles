function kitty_terminfo
    if test (count $argv) -eq 0
        printf "Usage: kitty_terminfo <host> [host ...]\n"
        return 1
    end

    if not infocmp -x xterm-kitty >/dev/null 2>/dev/null
        printf "Local terminfo entry 'xterm-kitty' not found.\n"
        return 1
    end

    for host in $argv
        printf "Installing xterm-kitty on %s...\n" "$host"
        infocmp -x xterm-kitty | ssh "$host" "mkdir -p ~/.terminfo && tic -x -o ~/.terminfo /dev/stdin"
        if test $status -ne 0
            printf "Failed to install terminfo on %s.\n" "$host"
            return 1
        end

        ssh "$host" "infocmp -x xterm-kitty >/dev/null 2>/dev/null"
        if test $status -ne 0
            printf "Verification failed on %s.\n" "$host"
            return 1
        end

        printf "OK: %s\n" "$host"
    end
end
