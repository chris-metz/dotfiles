function nuc-tunnel --description "Toggle the SSH tunnel to the NUC (status: show state, ports/add/remove <port>: the ports it always forwards, open/close <port>: forward one more port)"
    set -l host nucubuntu.yakalo-delta.ts.net
    set -l sock ~/.ssh/nuc-tunnel.sock
    # The ports the tunnel always forwards, one per line, kept on this Mac rather than in the repo
    set -l list ~/.config/nuc-tunnel/ports
    set -l ports
    if test -r $list
        set ports (string match -rg '^\s*(\d+)\s*$' <$list)
    end
    set -l command $argv[1]
    set -l port $argv[2]
    # Cancelling a forward takes the exact spec it was opened with. 127.0.0.1, not
    # localhost: the NUC's apps may listen on IPv4 only
    set -l forward $port:127.0.0.1:$port

    switch "$command"
        case '' status
        case ports
            printf '%s\n' $ports
            return
        case open close add remove
            # At most five digits, so that test below gets a number it can compare
            if not string match -qr '^[1-9][0-9]{0,4}$' -- "$port"; or test $port -lt 1024 -o $port -gt 65535
                echo "nuc-tunnel: $command needs a port from 1024 to 65535" >&2
                return 1
            end
            if test $command = close; and contains -- $port $ports
                echo "nuc-tunnel: $port stays open as long as the tunnel is on (nuc-tunnel remove $port takes it off the list)" >&2
                return 1
            end
        case '*'
            echo "usage: nuc-tunnel [status | ports | add <port> | remove <port> | open <port> | close <port>]" >&2
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
            if test -z "$pid"
                echo "nuc-tunnel: off"
            else if set -q forwarded[1]
                echo "nuc-tunnel: on (localhost:"(string join , $forwarded)")"
            else
                echo "nuc-tunnel: on"
            end
            return
        case add
            # ssh could not forward a port something else on this Mac listens on, and
            # would then not start the tunnel at all (ExitOnForwardFailure)
            if not contains -- $port $forwarded; and __nuc_tunnel_taken $port
                echo "nuc-tunnel: localhost:$port is taken on this Mac already" >&2
                return 1
            end
            if not contains -- $port $ports
                mkdir -p (path dirname $list)
                printf '%s\n' $ports $port >$list
                echo "nuc-tunnel: $port is on the list"
            end
            # A tunnel that is off forwards it once it turns on
            if test -n "$pid"; and not contains -- $port $forwarded
                ssh -S $sock -O forward -L $forward $host
                and echo "nuc-tunnel: opened localhost:$port"
            end
            return
        case remove
            if contains -- $port $ports
                for p in $ports
                    test $p = $port; or echo $p
                end >$list
                echo "nuc-tunnel: $port is off the list"
            end
            contains -- $port $forwarded; or return 0
            ssh -S $sock -O cancel -L $forward $host
            and echo "nuc-tunnel: closed localhost:$port"
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
        set -l ports_started
        for p in $ports
            # A port taken since it went on the list would keep the others from starting
            if __nuc_tunnel_taken $p
                echo "nuc-tunnel: skipped localhost:$p, it is taken on this Mac" >&2
                continue
            end
            set -a forwards -L $p:127.0.0.1:$p
            set -a ports_started $p
        end
        # A socket left behind by a killed tunnel would keep ssh from taking control again
        rm -f $sock
        ssh -f -N -M -S $sock \
            -o ExitOnForwardFailure=yes \
            -o ServerAliveInterval=15 -o ServerAliveCountMax=4 \
            $forwards $host
        or return 1
        set forwarded $ports_started
        if set -q forwarded[1]
            echo "nuc-tunnel: on (localhost:"(string join , $forwarded)")"
        else
            echo "nuc-tunnel: on"
        end
    end

    if test "$command" = open; and not contains -- $port $forwarded
        ssh -S $sock -O forward -L $forward $host
        and echo "nuc-tunnel: opened localhost:$port"
    end
end

# Whether something on this Mac answers on localhost:<port>, over IPv4 or IPv6. A
# connection rather than netstat or lsof, which run from fish see no other process's ports.
function __nuc_tunnel_taken --argument-names port
    nc -z -G 1 127.0.0.1 $port 2>/dev/null; or nc -z -G 1 ::1 $port 2>/dev/null
end
