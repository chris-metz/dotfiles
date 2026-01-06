function ports
  sudo lsof -nP -iTCP $argv
end
