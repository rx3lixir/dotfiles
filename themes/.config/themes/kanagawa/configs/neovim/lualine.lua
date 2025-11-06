return {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		local auto = require("lualine.themes.auto")

		-- ============================================================================
		-- KANAGAWA COLOR PALETTE
		-- ============================================================================

		local colors = {
			-- Primary accent - main highlight color
			accent = "#7E9CD8",
			accent_fixed = "#658594",
			-- Secondary accent - supporting highlight
			secondary = "#98BB6C",
			secondary_fixed = "#76946A",
			-- Tertiary accent - subtle emphasis
			tertiary = "#7FB4CA",
			tertiary_fixed = "#7AA89F",
			-- Background layers
			bg0 = "#16161D",
			bg1 = "#1F1F28",
			bg2 = "#2A2A37",
			bg_bright = "#54546D",
			bg_dim = "#16161D",
			-- Error colors
			error = "#E82424",
			on_error = "#1F1F28",
			-- Text colors
			fg = "#DCD7BA",
			fg_strong = "#DCD7BA",
			fg_muted = "#727169",
			-- Borders
			border = "#54546D",
			border_strong = "#957FB8",
			border_dim = "#363646",
			-- Overlays / shadows
			overlay = "#000000",
			scrim = "#000000",
			-- Mode-specific colors (using Kanagawa palette)
			mode_normal = "#7E9CD8", -- crystalBlue
			mode_insert = "#98BB6C", -- springGreen
			mode_visual = "#957FB8", -- oniViolet
			mode_replace = "#E82424", -- samuraiRed
			mode_command = "#DCA561", -- autumnYellow
			mode_terminal = "#7AA89F", -- waveAqua2
		}

		-- ============================================================================
		-- HELPER FUNCTIONS
		-- ============================================================================

		-- Separator component (the vertical bar between sections)
		local function separator()
			return {
				function()
					return "│"
				end,
				color = { fg = colors.border, bg = "NONE" },
				padding = { left = 1, right = 1 },
			}
		end

		-- Custom git branch display (tries gitsigns first, falls back to fugitive)
		local function custom_branch()
			local gitsigns = vim.b.gitsigns_head
			local fugitive = vim.fn.exists("*FugitiveHead") == 1 and vim.fn.FugitiveHead() or ""
			local branch = gitsigns or fugitive

			if branch == nil or branch == "" then
				return ""
			else
				return " " .. branch
			end
		end

		-- Active LSP clients display
		local function lsp_clients()
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			if next(clients) == nil then
				return ""
			end

			local client_names = {}
			for _, client in pairs(clients) do
				table.insert(client_names, client.name)
			end

			return "󰒓 " .. table.concat(client_names, ", ")
		end

		-- ============================================================================
		-- THEME SETUP
		-- ============================================================================
		-- Make the middle section (lualine_c) transparent
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
		-- STATUSLINE SECTIONS
		-- ============================================================================
		opts.sections = {
			-- LEFT: Mode indicator (bright and distinct per mode)
			lualine_a = {
				{
					"mode",
					fmt = function(str)
						return str:sub(1, 1) -- Just first letter (N, I, V, etc.)
					end,
					color = function()
						local mode = vim.fn.mode()
						local mode_colors = {
							n = colors.mode_normal, -- Normal mode - blue
							i = colors.mode_insert, -- Insert mode - green
							v = colors.mode_visual, -- Visual mode - lavender
							V = colors.mode_visual, -- Visual Line - lavender
							["\22"] = colors.mode_visual, -- Visual Block - lavender
							c = colors.mode_command, -- Command mode - yellow
							R = colors.mode_replace, -- Replace mode - red
							t = colors.mode_terminal, -- Terminal mode - teal
						}
						local fg_color = mode_colors[mode] or colors.mode_normal
						return { fg = fg_color, bg = "NONE", gui = "bold" }
					end,
					padding = { left = 1, right = 1 },
				},
			},

			-- LEFT-CENTER: Git branch and diff stats (using dimmed colors)
			lualine_b = {
				separator(),
				{
					custom_branch,
					color = { fg = colors.fg_muted, bg = "NONE" }, -- Dimmed text
					padding = { left = 0, right = 1 },
				},
				{
					"diff",
					colored = true,
					diff_color = {
						added = { fg = colors.secondary, bg = "NONE" }, -- Green but will be dimmed by context
						modified = { fg = colors.tertiary, bg = "NONE" }, -- Blue
						removed = { fg = colors.error, bg = "NONE" }, -- Red
					},
					symbols = { added = "+", modified = "~", removed = "-" },
					padding = { left = 0, right = 0 },
				},
			},

			-- CENTER: File info (dimmed)
			lualine_c = {
				separator(),
				{
					"filetype",
					icon_only = true,
					colored = false, -- Don't color the icon
					color = { fg = colors.fg, bg = "NONE" },
					padding = { left = 0, right = 1 },
				},
				{
					"filename",
					file_status = true,
					path = 0, -- Just filename
					shorting_target = 20,
					symbols = {
						modified = "[+]",
						readonly = "[-]",
						unnamed = "[?]",
						newfile = "[!]",
					},
					color = { fg = colors.fg_muted, bg = "NONE" }, -- Dimmed text
					padding = { left = 0, right = 0 },
				},
			},

			-- RIGHT-CENTER: Active LSP clients
			lualine_x = {
				{
					lsp_clients,
					color = { fg = colors.fg_muted, bg = "NONE" }, -- Dimmed text
					padding = { left = 0, right = 0 },
				},
			},

			-- RIGHT: Diagnostics (only show if count > 0, using proper colors)
			lualine_y = {
				separator(),
				{
					"diagnostics",
					sources = { "nvim_diagnostic", "coc" },
					sections = { "error", "warn", "info", "hint" },
					diagnostics_color = {
						error = { fg = colors.error, bg = "NONE" }, -- Red
						warn = { fg = "#fab387", bg = "NONE" }, -- Orange
						info = { fg = colors.tertiary, bg = "NONE" }, -- Blue
						hint = { fg = colors.secondary_fixed, bg = "NONE" }, -- Teal
					},
					symbols = {
						error = "󰅚 ",
						warn = "󰀪 ",
						info = "󰋽 ",
						hint = "󰌶 ",
					},
					colored = true,
					update_in_insert = false,
					always_visible = false, -- KEY: Only show when there are actual diagnostics
					padding = { left = 0, right = 0 },
				},
			},

			-- FAR RIGHT: Position in file (dimmed)
			lualine_z = {
				separator(),
				{
					"progress",
					color = { fg = colors.fg_muted, bg = "NONE" }, -- Dimmed text
					padding = { left = 0, right = 1 },
				},
			},
		}

		return opts
	end,
}
