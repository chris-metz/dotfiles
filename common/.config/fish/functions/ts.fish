function ts
    if test (count $argv) -ne 1
        echo "Usage: ms <epoch_timestamp>"
        echo "       (seconds or milliseconds since 1970-01-01)"
        return 1
    end

    set ts $argv[1]

    # Auto-detect: if length > 10, assume milliseconds
    if test (string length $ts) -gt 10
        # divide by 1000, round to integer seconds
        set ts_sec (math --scale 0 "$ts / 1000")
    else
        set ts_sec $ts
    end

    # BSD date on macOS uses -r <seconds>, GNU date on Linux uses -d @<seconds>
    if test (uname) = Darwin
        date -r $ts_sec "+%Y-%m-%d %H:%M:%S %Z"
    else
        date -d @$ts_sec "+%Y-%m-%d %H:%M:%S %Z"
    end
end
