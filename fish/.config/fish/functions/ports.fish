function ports --wraps='sudo lsof -nP -iTCP' --description 'alias ports=sudo lsof -nP -iTCP'
  sudo lsof -nP -iTCP $argv
        
end
