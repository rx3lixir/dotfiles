# Auto-install Fisher Plugin Manager and plugins
set -g fisher_path $HOME/.local/share/fisher

# Check if fisher is installed
if not test -f $fisher_path/functions/fisher.fish
    echo "Fisher not found. Installing Fisher..."
    
    # Create fisher directory
    mkdir -p $fisher_path/functions
    
    # Download and install Fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish -o $fisher_path/functions/fisher.fish
    
    # Source fisher
    source $fisher_path/functions/fisher.fish

    echo "Fisher installed successfully!"
    echo "Installing plugins..."

    # Install plugins
    fisher install patrickf1/fzf.fish
    fisher install meaningful-ooo/sponge
    fisher install PatrickF1/fzf.fish
    
    echo "All plugins installed. Run 'tide configure' to set up your prompt"
else
    # Fisher is installed, just source it
    source $fisher_path/functions/fisher.fish
end

# Add fisher to function path
set -gp fish_function_path $fisher_path/functions
set -gp fish_complete_path $fisher_path/completions
