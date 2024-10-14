function sd --wraps='cd ~ && cd $(find * -type d -name .git -prune -o -type d -print | fzf)' --description 'alias sd=cd ~ && cd $(find * -type d -name .git -prune -o -type d -print | fzf)'
  cd ~ && cd $(find * -type d -name .git -prune -o -type d -print | fzf) $argv
        
end
