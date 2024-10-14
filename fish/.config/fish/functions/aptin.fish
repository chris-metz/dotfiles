function aptin --wraps='sudo apt install' --description 'alias aptin=sudo apt install'
  sudo apt install $argv
        
end
