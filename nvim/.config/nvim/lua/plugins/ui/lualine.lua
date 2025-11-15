return {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		local auto = require("lualine.themes.auto")

		-- ============================================================================
		-- MONOCHROME COLOR PALETTE
		-- ============================================================================
		local colors = {
			-- Primary accent (Flexoki text/foreground)
			accent = "#CECDC3", -- tx (main text)
			accent_fixed = "#B7B5AC", -- tx-2 (dimmer text)

			-- Secondary (Flexoki red for errors/warnings)
			secondary = "#D14D41", -- red (flexoki red)
			secondary_fixed = "#AF3029", -- red-2 (darker red)

			-- Tertiary (Flexoki green for success/insert)
			tertiary = "#879A39", -- green (flexoki green)
			tertiary_fixed = "#66800B", -- green-2 (darker green)

			-- Backgrounds (Flexoki base colors)
			bg0 = "#100F0F", -- base (darkest)
			bg1 = "#1C1B1A", -- bg (dark)
			bg2 = "#282726", -- bg-2 (medium dark)
			bg_bright = "#403E3C", -- ui (brighter UI elements)
			bg_dim = "#100F0F", -- base (same as bg0)

			-- Error states
			error = "#D14D41", -- red
			on_error = "#1C1B1A", -- bg (dark background)

			-- Foreground variations
			fg = "#CECDC3", -- tx (main text)
			fg_strong = "#E6E4D9", -- tx-3 (brightest text)
			fg_muted = "#878580", -- ui-2 (muted text)

			-- Borders
			border = "#282726", -- bg-2
			border_strong = "#403E3C", -- ui
			border_dim = "#1C1B1A", -- bg

			-- Overlays
			overlay = "#100F0F", -- base (with alpha in use)
			scrim = "#100F0F", -- base (with alpha in use)

			-- Mode colors (Vim modes)
			mode_normal = "#4385BE", -- cyan (normal mode)
			mode_insert = "#879A39", -- green (insert mode)
			mode_visual = "#8B7EC8", -- purple (visual mode)
			mode_replace = "#D14D41", -- red (replace mode)
			mode_command = "#DA702C", -- orange (command mode)
			mode_terminal = "#66800B", -- green-2 (terminal mode)
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
