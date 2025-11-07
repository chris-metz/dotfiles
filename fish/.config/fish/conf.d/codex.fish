if status is-interactive
    if type -q codex
        codex completion fish | source
    end
end
