return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x", -- Use stable branch 0.1.x

	dependencies = {
		"nvim-lua/plenary.nvim", -- Utility library for Lua in Neovim
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- Fast native fzf search algorithm
		"nvim-tree/nvim-web-devicons", -- File icons
		"nvim-telescope/telescope-file-browser.nvim", -- File browser
		"nvim-telescope/telescope-ui-select.nvim", -- Replacement for vim.ui.select
	},

	-- Configuration function, runs after plugin is loaded
	config = function()
		-- Import required modules
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		-- Telescope setup
		telescope.setup({
			defaults = {
				-- UI settings
				border = {}, -- Empty border uses default style
				borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
				path_display = { "truncate" }, -- Shorten long file paths
				color_devicons = true, -- Colored file icons

				-- Environment settings
				set_env = { ["COLORTERM"] = "truecolor" }, -- Ensure true color support

				-- Enhanced file preview
				file_previewer = require("telescope.previewers").vim_buffer_cat.new,
				grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,

				-- Ignore specific files and folders
				file_ignore_patterns = {
					"node_modules",
					".git",
					"target",
					"build",
					"dist",
				},

				-- Sorting strategy
				sorting_strategy = "ascending", -- Show results from top to bottom
				layout_strategy = "horizontal", -- Horizontal layout
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},

				-- Key mappings for insert mode
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- Move to previous result
						["<C-j>"] = actions.move_selection_next, -- Move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- Send selected files to quickfix and open it
					},
				},
			},
		})

		-- Load extensions
		telescope.load_extension("fzf") -- Fast fzf search
		telescope.load_extension("file_browser") -- File browser
		telescope.load_extension("ui-select") -- Enhanced selection UI

		-- Key mappings for quick Telescope access
		local keymap = vim.keymap -- Shortcut alias

		-- Find files
		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" }) -- Search files in current directory

		-- Find recently opened files
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" }) -- Search recently opened files

		-- Search text in files
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" }) -- Search for a string across files (requires ripgrep)

		-- Search word under cursor
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" }) -- Search for word under cursor

		-- Find open buffers
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find open buffers" })

		-- Find in help tags
		keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help" })

		-- Show diagnostics for current file
		keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Document diagnostics" })

		-- Show diagnostics for entire workspace
		keymap.set("n", "<leader>fD", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace diagnostics" })

		-- Open file browser
		keymap.set("n", "<leader>fe", "<cmd>Telescope file_browser<cr>", { desc = "Open file browser" })
	end,
}
