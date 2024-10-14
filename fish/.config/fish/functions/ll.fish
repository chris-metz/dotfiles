function ll --wraps=ls --wraps='eza --icons -lga --group-directories-first' --description 'alias ll=eza --icons -lga --group-directories-first'
  eza --icons -lga --group-directories-first $argv
        
end
