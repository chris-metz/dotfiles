function dps
  docker ps -a --format 'table {{.Names}}\t{{.RunningFor}}\t{{.Status}}\t{{.Image}}' $argv
end
