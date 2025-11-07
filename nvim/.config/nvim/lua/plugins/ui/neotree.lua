return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	lazy = false,
	keys = {
		{ "<leader>e", ":Neotree toggle left<CR>", silent = true, desc = "Float file explorer" },
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true, -- Закрываем дерево, если оно — последнее окно
			popup_border_style = "",
			enable_git_status = true,
			enable_diagnostics = true,
			default_component_configs = {
				indent = {
					with_expanders = true, -- стрелочки разворачивания
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "",
					default = "",
					highlight = "NeoTreeFileIcon",
				},
				modified = {
					symbol = "",
					highlight = "NeoTreeModified",
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
					highlight = "NeoTreeFileName",
				},
				git_status = {
					symbols = {
						added = "",
						modified = "",
						deleted = "",
						renamed = "➜",
						untracked = "",
						ignored = "◌",
						unstaged = "",
						staged = "",
						conflict = "",
					},
				},
			},
			event_handlers = {
				{
					event = "file_open_requested",
					handler = function()
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},
			filesystem = {
				filtered_items = {
					visible = true, -- показывать скрытые файлы
					hide_dotfiles = false,
					hide_gitignored = false,
				},
				follow_current_file = {
					enabled = true, -- autoficues
				},
				hijack_netrw_behavior = "disabled", -- replaces netrw
				use_libuv_file_watcher = true,
				components = {
					harpoon_index = function(config, node, _)
						local Marked = require("harpoon.mark")
						local path = node:get_id()
						local success, index = pcall(Marked.get_index_of, path)
						if success and index and index > 0 then
							return {
								text = string.format("󰈺 %d ", index), -- иконка Harpoon
								highlight = config.highlight or "NeoTreeDirectoryIcon",
							}
						else
							return {
								text = "   ",
							}
						end
					end,
				},
				renderers = {
					file = {
						{ "icon" },
						{ "name", use_git_status_colors = true },
						{ "harpoon_index" },
						{ "diagnostics" },
						{ "git_status", highlight = "NeoTreeDimText" },
					},
					directory = {
						{ "indent" },
						{ "icon" },
						{ "current_filter" },
						{ "name", use_git_status_colors = true },
						{ "git_status", highlight = "NeoTreeDimText" },
					},
				},
			},
		})
	end,
}
