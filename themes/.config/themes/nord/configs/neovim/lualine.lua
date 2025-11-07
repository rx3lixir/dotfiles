return {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		local auto = require("lualine.themes.auto")

		-- ============================================================================
		-- NORD COLOR PALETTE
		-- ============================================================================
		local colors = {
			accent = "#88c0d0",
			accent_fixed = "#81a1c1",
			secondary = "#8fbcbb",
			secondary_fixed = "#5e81ac",
			tertiary = "#a3be8c",
			tertiary_fixed = "#d08770",
			bg0 = "#2e3440",
			bg1 = "#434c5e",
			bg2 = "#3b4252",
			bg_bright = "#4c566a",
			bg_dim = "#0E1115",
			error = "#bf616a",
			on_error = "#4c566a",
			fg = "#d8dee9",
			fg_strong = "#eceff4",
			fg_muted = "#e5e9f0",
			border = "#42474E",
			border_strong = "#8D9199",
			border_dim = "#2E3135",
			overlay = "#000000",
			scrim = "#000000",
			mode_normal = "#81a1c1",
			mode_insert = "#a3be8c",
			mode_visual = "#b48ead",
			mode_replace = "#bf616a",
			mode_command = "#ebcb8b",
			mode_terminal = "#8fbcbb",
		}

		-- ============================================================================
		-- COMPONENT DEFINITIONS
		-- ============================================================================
		local components = {
			-- SEPARATOR
			separator = {
				function()
					return "│"
				end,
				color = { fg = colors.border, bg = "NONE" },
				padding = { left = 1, right = 1 },
			},

			-- MODE - current vim mode (N/I/V/etc)
			mode = {
				"mode",
				fmt = function(str)
					return str:sub(1, 1)
				end,
				color = function()
					local mode = vim.fn.mode()
					local mode_colors = {
						n = colors.mode_normal,
						i = colors.mode_insert,
						v = colors.mode_visual,
						V = colors.mode_visual,
						["\22"] = colors.mode_visual,
						c = colors.mode_command,
						R = colors.mode_replace,
						t = colors.mode_terminal,
					}
					local fg_color = mode_colors[mode] or colors.mode_normal
					return { fg = fg_color, bg = "NONE", gui = "bold" }
				end,
				padding = { left = 1, right = 0 },
			},

			-- GIT BRANCH - current branch name
			git_branch = {
				"branch",
				color = { fg = colors.fg_muted, bg = "NONE" },
				padding = { left = 0, right = 0 },
			},

			-- FILETYPE ICON - just the icon
			filetype_icon = {
				"filetype",
				icon_only = true,
				colored = false,
				color = { fg = colors.fg_muted, bg = "NONE" },
				padding = { left = 0, right = 1 },
			},

			-- FILENAME - with status symbols
			filename = {
				"filename",
				file_status = true,
				path = 0,
				shorting_target = 20,
				symbols = {
					modified = "[+]",
					readonly = "[-]",
					unnamed = "[?]",
					newfile = "[!]",
				},
				color = { fg = colors.fg_muted, bg = "NONE" },
				padding = { left = 0, right = 0 },
			},

			-- DIAGNOSTICS - errors/warnings/info/hints (only when present)
			diagnostics = {
				"diagnostics",
				sources = { "nvim_diagnostic", "coc" },
				sections = { "error", "warn", "info", "hint" },
				diagnostics_color = {
					error = { fg = colors.error, bg = "NONE" },
					warn = { fg = "#fab387", bg = "NONE" },
					info = { fg = colors.tertiary, bg = "NONE" },
					hint = { fg = colors.secondary_fixed, bg = "NONE" },
				},
				symbols = {
					error = "󰅚 ",
					warn = "󰀪 ",
					info = "󰋽 ",
					hint = "󰌶 ",
				},
				colored = true,
				update_in_insert = false,
				always_visible = false,
				padding = { left = 0, right = 1 },
			},
		}

		-- ============================================================================
		-- THEME SETUP
		-- ============================================================================
		local modes = { "normal", "insert", "visual", "replace", "command", "inactive", "terminal" }
		for _, mode in ipairs(modes) do
			if auto[mode] and auto[mode].c then
				auto[mode].c.bg = "NONE"
			end
		end

		-- ============================================================================
		-- LUALINE OPTIONS
		-- ============================================================================
		opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
			theme = auto,
			component_separators = "",
			section_separators = "",
			globalstatus = true,
			disabled_filetypes = { statusline = {}, winbar = {} },
		})

		-- ============================================================================
		-- STATUSLINE LAYOUT: mode | branch | filename | diagnostics
		-- ============================================================================
		opts.sections = {
			lualine_a = { components.mode },
			lualine_b = { components.separator, components.git_branch },
			lualine_c = { components.separator, components.filetype_icon, components.filename },
			lualine_x = {},
			lualine_y = { components.diagnostics },
			lualine_z = {},
		}

		return opts
	end,
}
