return {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		local auto = require("lualine.themes.auto")

		-- ============================================================================
		-- CATPPUCCIN COLOR PALETTE
		-- ============================================================================
		local colors = {
			accent = "#b4befe",
			accent_fixed = "#81a1c1",
			secondary = "#a6e3a1",
			secondary_fixed = "#94e2d5",
			tertiary = "#89b4fa",
			tertiary_fixed = "#74c7ec",
			bg0 = "#11111b",
			bg1 = "#1e1e2e",
			bg2 = "#181825",
			bg_bright = "#585b70",
			bg_dim = "#171723",
			error = "#f38ba8",
			on_error = "#1e1e2e",
			fg = "#bac2de",
			fg_strong = "#cdd6f4",
			fg_muted = "#9399b2",
			border = "#3D3C48",
			border_strong = "#967BB9",
			border_dim = "#2E2D33",
			overlay = "#000000",
			scrim = "#000000",
			mode_normal = "#89b4fa",
			mode_insert = "#a6e3a1",
			mode_visual = "#b4befe",
			mode_replace = "#f38ba8",
			mode_command = "#f9e2af",
			mode_terminal = "#94e2d5",
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
