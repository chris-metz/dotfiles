function ips
    ip -o addr show | awk '{print $2, $4}'
end
