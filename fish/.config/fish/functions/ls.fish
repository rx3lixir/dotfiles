function ls --wraps=eza --description 'List directory contents with eza'
    eza --grid --icons --color=auto --all $argv
end
