function dpsp --wraps=docker\ ps\ -a\ --format\ \'table\ \{\{.Names\}\}\\t\{\{.RunningFor\}\}\\t\{\{.Status\}\}\\t\{\{.Ports\}\}\' --description alias\ dpsp=docker\ ps\ -a\ --format\ \'table\ \{\{.Names\}\}\\t\{\{.RunningFor\}\}\\t\{\{.Status\}\}\\t\{\{.Ports\}\}\'
  docker ps -a --format 'table {{.Names}}\t{{.RunningFor}}\t{{.Status}}\t{{.Ports}}' $argv
        
end
