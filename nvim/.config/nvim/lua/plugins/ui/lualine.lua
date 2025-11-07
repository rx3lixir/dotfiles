return {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		local auto = require("lualine.themes.auto")

		-- ============================================================================
		-- EVERFOREST COLOR PALETTE
		-- ============================================================================
		local colors = {
			accent = "#A7C080",
			accent_fixed = "#83C092",
			secondary = "#7FBBB3",
			secondary_fixed = "#7FBBB3",
			tertiary = "#E69875",
			tertiary_fixed = "#DBBC7F",
			bg0 = "#272E33",
			bg1 = "#374145",
			bg2 = "#2E383C",
			bg_bright = "#414B50",
			bg_dim = "#1E2326",
			error = "#E67E80",
			on_error = "#374145",
			fg = "#D3C6AA",
			fg_strong = "#F2EFDF",
			fg_muted = "#5C6A72",
			border = "#4a4d45",
			border_strong = "#8D9199",
			border_dim = "#353831",
			overlay = "#000000",
			scrim = "#000000",
			mode_normal = "#A7C080",
			mode_insert = "#7FBBB3",
			mode_visual = "#DBBC7F",
			mode_replace = "#E67E80",
			mode_command = "#E69875",
			mode_terminal = "#83C092",
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
				color = { fg = colors.fg, bg = "NONE" },
				padding = { left = 0, right = 0 },
			},

			-- FILETYPE ICON - just the icon
			filetype_icon = {
				"filetype",
				icon_only = true,
				colored = false,
				color = { fg = colors.fg, bg = "NONE" },
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
				color = { fg = colors.fg, bg = "NONE" },
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
