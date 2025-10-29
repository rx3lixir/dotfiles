return {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		local auto = require("lualine.themes.auto")

		-- Matugen color palette
		local colors = {
			-- Primary accent - main highlight color
			accent = "#a3c9fe",
			accent_fixed = "#d3e3ff",
			-- Secondary accent - supporting highlight
			secondary = "#bcc7db",
			secondary_fixed = "#d8e3f8",
			-- Tertiary accent - subtle emphasis
			tertiary = "#d9bde3",
			tertiary_fixed = "#f5d9ff",
			-- Background layers
			bg0 = "#111318",
			bg1 = "#1d2024",
			bg2 = "#191c20",
			bg_bright = "#37393e",
			bg_dim = "#111318",
			-- Error colors
			error = "#ffb4ab",
			on_error = "#690005",
			-- Text colors
			fg = "#c3c6cf",
			fg_strong = "#e1e2e8",
			fg_muted = "#c3c6cf",
			-- Borders
			border = "#43474e",
			border_strong = "#8d9199",
			border_dim = "#2e3035",
			-- Overlays / shadows
			overlay = "#000000",
			scrim = "#000000",
		}

		local function separator()
			return {
				function()
					return "│"
				end,
				color = { fg = colors.border, bg = "NONE", gui = "bold" },
				padding = { left = 1, right = 1 },
			}
		end

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

		local modes = { "normal", "insert", "visual", "replace", "command", "inactive", "terminal" }
		for _, mode in ipairs(modes) do
			if auto[mode] and auto[mode].c then
				auto[mode].c.bg = "NONE"
			end
		end

		opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
			theme = auto,
			component_separators = "",
			section_separators = "",
			globalstatus = true,
			disabled_filetypes = { statusline = {}, winbar = {} },
		})

		opts.sections = {
			lualine_a = {
				{
					"mode",
					fmt = function(str)
						return str:sub(1, 1)
					end,
					color = function()
						local mode = vim.fn.mode()
						if mode == "\22" then
							return { fg = "none", bg = colors.accent, gui = "bold" }
						elseif mode == "V" then
							return { fg = colors.accent, bg = "none", gui = "underline,bold" }
						else
							return { fg = colors.accent, bg = "none", gui = "bold" }
						end
					end,
					padding = { left = 0, right = 0 },
				},
			},
			lualine_b = {
				separator(),
				{
					custom_branch,
					color = { fg = colors.secondary, bg = "none", gui = "bold" },
					padding = { left = 0, right = 0 },
				},
				{
					"diff",
					colored = true,
					diff_color = {
						added = { fg = colors.secondary, bg = "none", gui = "bold" },
						modified = { fg = colors.tertiary, bg = "none", gui = "bold" },
						removed = { fg = colors.error, bg = "none", gui = "bold" },
					},
					symbols = { added = "+", modified = "~", removed = "-" },
					source = nil,
					padding = { left = 1, right = 0 },
				},
			},
			lualine_c = {
				separator(),
				{
					"filetype",
					icon_only = true,
					colored = false,
					color = { fg = colors.accent, bg = "none", gui = "bold" },
					padding = { left = 0, right = 1 },
				},
				{
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
					color = { fg = colors.accent, bg = "none", gui = "bold" },
					padding = { left = 0, right = 0 },
				},
			},
			lualine_x = {
				{
					function()
						local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
						if size < 0 then
							return "-"
						else
							if size < 1024 then
								return size .. "B"
							elseif size < 1024 * 1024 then
								return string.format("%.1fK", size / 1024)
							elseif size < 1024 * 1024 * 1024 then
								return string.format("%.1fM", size / (1024 * 1024))
							else
								return string.format("%.1fG", size / (1024 * 1024 * 1024))
							end
						end
					end,
					color = { fg = colors.accent, bg = "none", gui = "bold" },
					padding = { left = 0, right = 0 },
				},
			},
			lualine_y = {
				separator(),
				{
					"diagnostics",
					sources = { "nvim_diagnostic", "coc" },
					sections = { "error", "warn", "info", "hint" },
					diagnostics_color = {
						error = function()
							local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
							return { fg = (count == 0) and colors.secondary or colors.error, bg = "none", gui = "bold" }
						end,
						warn = function()
							local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
							return {
								fg = (count == 0) and colors.secondary or colors.tertiary,
								bg = "none",
								gui = "bold",
							}
						end,
						info = function()
							local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
							return { fg = (count == 0) and colors.secondary or colors.accent, bg = "none", gui = "bold" }
						end,
						hint = function()
							local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
							return {
								fg = (count == 0) and colors.secondary or colors.secondary_fixed,
								bg = "none",
								gui = "bold",
							}
						end,
					},
					symbols = {
						error = "󰅚 ",
						warn = "󰀪 ",
						info = "󰋽 ",
						hint = "󰌶 ",
					},
					colored = true,
					update_in_insert = false,
					always_visible = true,
					padding = { left = 0, right = 0 },
				},
			},
			lualine_z = {
				separator(),
				{
					"progress",
					color = { fg = colors.accent, bg = "none", gui = "bold" },
					padding = { left = 0, right = 0 },
				},
			},
		}

		return opts
	end,
}
