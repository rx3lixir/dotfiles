# Add Bun to PATH
if test -d $HOME/.bun/bin
    fish_add_path $HOME/.bun/bin
end

# Add cargo binaries to PATH
if test -d $HOME/.cargo/bin
    fish_add_path $HOME/.cargo/bin
end

# Add Go to PATH
if test -d $HOME/go/bin
    fish_add_path $HOME/go/bin
end

# Add any local bin directories
if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end
