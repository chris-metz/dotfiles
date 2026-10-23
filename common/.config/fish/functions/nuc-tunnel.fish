function nuc-tunnel --description "Toggle the SSH tunnel localhost:3300,8025 -> NUC (status: show state, open/close <port>: forward one more port)"
    set -l host nucubuntu.yakalo-delta.ts.net
    set -l sock ~/.ssh/nuc-tunnel.sock
    set -l ports 3300 8025
    set -l command $argv[1]
    set -l port $argv[2]
    # Cancelling a forward takes the exact spec it was opened with. 127.0.0.1, not
    # localhost: the NUC's apps may listen on IPv4 only
    set -l forward $port:127.0.0.1:$port

    switch "$command"
        case '' status
        case open close
            # At most five digits, so that test below gets a number it can compare
            if not string match -qr '^[1-9][0-9]{0,4}$' -- "$port"; or test $port -lt 1024 -o $port -gt 65535
                echo "nuc-tunnel: $command needs a port from 1024 to 65535" >&2
                return 1
            end
            if test $command = close; and contains -- $port $ports
                echo "nuc-tunnel: $port stays open as long as the tunnel is on" >&2
                return 1
            end
        case '*'
            echo "usage: nuc-tunnel [status | open <port> | close <port>]" >&2
            return 1
    end

    # The tunnel's ssh process, empty while the tunnel is off
    set -l pid (ssh -S $sock -O check $host 2>&1 | string match -rg 'pid=(\d+)')
    # ssh cannot list its forwards, so read the ports its process listens on
    set -l forwarded
    if test -n "$pid"
        set forwarded (lsof -nP -a -p $pid -iTCP -sTCP:LISTEN -Fn 2>/dev/null | string match -rg ':(\d+)$' | sort -nu)
    end

    switch "$command"
        case status
            if test -n "$pid"
                echo "nuc-tunnel: on (localhost:"(string join , $forwarded)")"
            else
                echo "nuc-tunnel: off"
            end
            return
        case close
            # Closed already, or the tunnel is off
            contains -- $port $forwarded; or return 0
            ssh -S $sock -O cancel -L $forward $host
            and echo "nuc-tunnel: closed localhost:$port"
            return
        case ''
            if test -n "$pid"
                ssh -S $sock -O exit $host 2>/dev/null
                echo "nuc-tunnel: off"
                return
            end
    end

    # Turning on, or open: the tunnel has to be on
    if test -z "$pid"
        set -l forwards
        for p in $ports
            set -a forwards -L $p:localhost:$p
        end
        # A socket left behind by a killed tunnel would keep ssh from taking control again
        rm -f $sock
        ssh -f -N -M -S $sock \
            -o ExitOnForwardFailure=yes \
            -o ServerAliveInterval=15 -o ServerAliveCountMax=4 \
            $forwards $host
        or return 1
        echo "nuc-tunnel: on (localhost:"(string join , $ports)")"
    end

    if test "$command" = open; and not contains -- $port $ports $forwarded
        ssh -S $sock -O forward -L $forward $host
        and echo "nuc-tunnel: opened localhost:$port"
    end
end
