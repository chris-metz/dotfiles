function nuc-tunnel --description "Toggle the SSH tunnel localhost:3300 -> NUC (nuc-tunnel status: show state)"
    set -l host nucubuntu.yakalo-delta.ts.net
    set -l sock ~/.ssh/nuc-tunnel.sock

    if ssh -S $sock -O check $host 2>/dev/null
        if test "$argv[1]" = status
            echo "nuc-tunnel: on (localhost:3300)"
        else
            ssh -S $sock -O exit $host 2>/dev/null
            echo "nuc-tunnel: off"
        end
    else if test "$argv[1]" = status
        echo "nuc-tunnel: off"
    else
        # A socket left behind by a killed tunnel would keep ssh from taking control again
        rm -f $sock
        ssh -f -N -M -S $sock \
            -o ExitOnForwardFailure=yes \
            -o ServerAliveInterval=15 -o ServerAliveCountMax=4 \
            -L 3300:localhost:3300 $host
        and echo "nuc-tunnel: on (localhost:3300)"
    end
end
