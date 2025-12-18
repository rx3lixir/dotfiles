return {
	"rebelot/kanagawa.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("kanagawa").setup({
			-- ============================================================
			-- BASIC SETTINGS
			-- ============================================================
			compile = false,
			undercurl = true,
			transparent = true,
			dimInactive = false,
			terminalColors = true,

			-- ============================================================
			-- STYLES
			-- ============================================================
			commentStyle = { italic = true },
			functionStyle = {},
			keywordStyle = { italic = false },
			statementStyle = { bold = true },
			typeStyle = {},

			-- ============================================================
			-- COLORS
			-- ============================================================
			colors = {
				palette = {},
				theme = {
					wave = {},
					lotus = {},
					dragon = {},
					all = {
						ui = {
							bg_gutter = "none",
						},
					},
				},
			},

			-- ============================================================
			-- HIGHLIGHT OVERRIDES
			-- ============================================================
			overrides = function(colors)
				local theme = colors.theme

				-- Helper function for diagnostic colors
				local function makeDiagnosticColor(color)
					local c = require("kanagawa.lib.color")
					return {
						fg = color,
						bg = c(color):blend(theme.ui.bg, 0.95):to_hex(),
					}
				end

				return {
					-- ------------------------------------------------
					-- FLOATING WINDOWS
					-- ------------------------------------------------
					NormalFloat = { bg = "none" },
					FloatBorder = { bg = "none" },
					FloatTitle = { bg = "none" },
					NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

					-- ------------------------------------------------
					-- PLUGIN WINDOWS
					-- ------------------------------------------------
					LazyNormal = { bg = theme.ui.bg_p1, fg = theme.ui.fg_dim },
					MasonNormal = { bg = "none", fg = theme.ui.fg_dim },

					TelescopeSelection = { bg = theme.ui.none, fg = theme.diag.info, bold = true },
					TelescopeSelectionCaret = { bg = theme.ui.none, fg = theme.ui.special, bold = true },
					--TelescopeMatching = { bg = theme.ui.none, fg = colors.blue },

					-- ------------------------------------------------
					-- DIAGNOSTICS
					-- ------------------------------------------------
					DiagnosticVirtualTextHint = makeDiagnosticColor(theme.diag.hint),
					DiagnosticVirtualTextInfo = makeDiagnosticColor(theme.diag.info),
					DiagnosticVirtualTextWarn = makeDiagnosticColor(theme.diag.warning),
					DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),

					-- ------------------------------------------------
					-- BLINK.CMP (COMPLETION)
					-- ------------------------------------------------
					BlinkCmpMenu = { bg = theme.ui.none, fg = theme.ui.fg_dim },
					BlinkCmpMenuBorder = { bg = "none", fg = theme.ui.bg_p2 },
					BlinkCmpMenuSelection = { bg = theme.ui.bg_p2 },
					BlinkCmpDoc = { bg = "none" },
					BlinkCmpDocBorder = { bg = "none", fg = theme.ui.bg_p1 },
					BlinkCmpSignatureHelp = { bg = "none" },
					BlinkCmpSignatureHelpBorder = { bg = "none", fg = theme.ui.bg_p1 },

					Visual = { bg = theme.ui.bg_p2, fg = theme.ui.none },
					VisualNOS = { bg = theme.ui.bg_p2, fg = theme.ui.none },

					-- ------------------------------------------------
					-- STATUSLINE (LUALINE TRANSPARENCY)
					-- ------------------------------------------------
					StatusLine = { bg = "none" },
					StatusLineNC = { bg = "none" },
				}
			end,

			-- ============================================================
			-- THEME SELECTION
			-- ============================================================
			theme = "wave",
			background = {
				dark = "wave",
				light = "lotus",
			},
		})

		-- Apply the colorscheme
		vim.cmd.colorscheme("kanagawa")
	end,
}
