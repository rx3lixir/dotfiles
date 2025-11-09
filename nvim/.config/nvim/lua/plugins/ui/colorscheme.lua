return {
	"nuvic/flexoki-nvim",
	name = "flexoki",
	lazy = false,
	priority = 1000,
	config = function()
		require("flexoki").setup({
			-- ============================================================
			-- BASIC SETTINGS
			-- ============================================================
			variant = "moon", -- auto, moon, or dawn
			dim_inactive_windows = false,
			extend_background_behind_borders = true,
			transparent = true, -- Enable transparency like kanagawa

			-- ============================================================
			-- TERMINAL
			-- ============================================================
			enable = {
				terminal = true,
			},

			-- ============================================================
			-- STYLES
			-- ============================================================
			styles = {
				bold = true,
				italic = true, -- Enable italics for comments/keywords
				transparency = true, -- Additional transparency flag
			},

			-- ============================================================
			-- SEMANTIC GROUPS (FLEXOKI SPECIFIC)
			-- ============================================================
			groups = {
				-- UI Elements
				border = "muted",
				panel = "surface",
				link = "purple_two",

				-- Diagnostics
				error = "red_one",
				hint = "purple_one",
				info = "cyan_one",
				ok = "green_one",
				warn = "orange_one",
				note = "blue_one",
				todo = "magenta_one",

				-- Git
				git_add = "green_one",
				git_change = "yellow_one",
				git_delete = "red_one",
				git_dirty = "yellow_one",
				git_ignore = "muted",
				git_merge = "purple_one",
				git_rename = "blue_one",
				git_stage = "purple_one",
				git_text = "magenta_one",
				git_untracked = "subtle",

				-- Markdown Headings
				h1 = "purple_two",
				h2 = "cyan_two",
				h3 = "magenta_two",
				h4 = "orange_two",
				h5 = "blue_two",
				h6 = "cyan_two",
			},

			-- ============================================================
			-- HIGHLIGHT OVERRIDES
			-- ============================================================
			highlight_groups = {
				-- ------------------------------------------------
				-- BASIC TRANSPARENCY
				-- ------------------------------------------------
				Normal = { bg = "none" },
				NormalFloat = { bg = "none" },
				FloatBorder = { bg = "none" },
				FloatTitle = { bg = "none" },
				SignColumn = { bg = "none" },

				-- ------------------------------------------------
				-- SYNTAX STYLES
				-- ------------------------------------------------
				Comment = { fg = "subtle", italic = true },
				Keyword = { italic = true },
				Statement = { bold = true },
				Function = {},
				Type = {},

				-- ------------------------------------------------
				-- UI ELEMENTS
				-- ------------------------------------------------
				VertSplit = { fg = "muted", bg = "none" },
				StatusLine = { bg = "none" },
				StatusLineNC = { bg = "none" },
				Visual = { bg = "surface" },
				VisualNOS = { bg = "surface" },

				-- ------------------------------------------------
				-- PLUGIN WINDOWS (TELESCOPE)
				-- ------------------------------------------------
				TelescopeNormal = { bg = "none" },
				TelescopeBorder = { bg = "none", fg = "muted" },
				TelescopeSelection = { bg = "none", fg = "cyan_one", bold = true },
				TelescopeSelectionCaret = { bg = "none", fg = "purple_one", bold = true },

				-- ------------------------------------------------
				-- PLUGIN WINDOWS (LAZY & MASON)
				-- ------------------------------------------------
				LazyNormal = { bg = "none" },
				MasonNormal = { bg = "none" },

				-- ------------------------------------------------
				-- COMPLETION (BLINK.CMP / NVIM-CMP)
				-- ------------------------------------------------
				-- Blink.cmp
				BlinkCmpMenu = { bg = "none" },
				BlinkCmpMenuBorder = { bg = "none", fg = "muted" },
				BlinkCmpMenuSelection = { bg = "surface" },
				BlinkCmpDoc = { bg = "none" },
				BlinkCmpDocBorder = { bg = "none", fg = "muted" },
				BlinkCmpSignatureHelp = { bg = "none" },
				BlinkCmpSignatureHelpBorder = { bg = "none", fg = "muted" },

				-- Nvim-cmp (fallback)
				Pmenu = { bg = "none" },
				PmenuSel = { bg = "surface" },
				PmenuBorder = { bg = "none", fg = "muted" },

				-- ------------------------------------------------
				-- DIAGNOSTICS
				-- ------------------------------------------------
				DiagnosticVirtualTextHint = { fg = "purple_one", bg = "none" },
				DiagnosticVirtualTextInfo = { fg = "cyan_one", bg = "none" },
				DiagnosticVirtualTextWarn = { fg = "orange_one", bg = "none" },
				DiagnosticVirtualTextError = { fg = "red_one", bg = "none" },

				-- ------------------------------------------------
				-- LINE NUMBERS
				-- ------------------------------------------------
				LineNr = { bg = "none" },
				CursorLineNr = { bg = "none" },
			},

			-- ============================================================
			-- BEFORE HIGHLIGHT HOOK (ADVANCED CUSTOMIZATION)
			-- ============================================================
			before_highlight = function(group, highlight, palette)
				-- Disable all undercurls if you prefer
				-- if highlight.undercurl then
				--     highlight.undercurl = false
				-- end

				-- Change specific palette colors globally
				-- if highlight.fg == palette.blue_two then
				--     highlight.fg = palette.cyan_two
				-- end

				-- Force transparency on backgrounds
				if highlight.bg and highlight.bg ~= "none" then
					-- Uncomment to force all backgrounds to be transparent
					-- highlight.bg = "none"
				end
			end,
		})

		-- ============================================================
		-- APPLY THE COLORSCHEME
		-- ============================================================
		vim.cmd.colorscheme("flexoki")
	end,
}
