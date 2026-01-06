function dpsp
  docker ps -a --format 'table {{.Names}}\t{{.RunningFor}}\t{{.Status}}\t{{.Ports}}' $argv
end
