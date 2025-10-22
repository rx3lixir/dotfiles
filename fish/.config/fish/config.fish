# Main Fish configuration file
# Everything else is auto-loaded from conf.d/ and functions

# Disable welcome message
set -g fish_greeting

# Enabling vim mode
set -g fish_key_bindings fish_vi_key_bindings

# History settings
set -g fish_history_max 5000

# Shell integrations
if type -q zoxide 
    zoxide init fish --cmd cd | source
end

# Customizing fzf.fish keybindings
fzf_configure_bindings --directory=\cf --git_status=\cs --processes=\cp
