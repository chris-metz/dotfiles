function dps --wraps=docker\ ps\ -a\ --format\ \'table\ \{\{.Names\}\}\\t\{\{.RunningFor\}\}\\t\{\{.Status\}\}\\t\{\{.Image\}\}\' --description alias\ dps=docker\ ps\ -a\ --format\ \'table\ \{\{.Names\}\}\\t\{\{.RunningFor\}\}\\t\{\{.Status\}\}\\t\{\{.Image\}\}\'
  docker ps -a --format 'table {{.Names}}\t{{.RunningFor}}\t{{.Status}}\t{{.Image}}' $argv
        
end
