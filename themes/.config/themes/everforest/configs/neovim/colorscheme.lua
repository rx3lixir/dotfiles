return {
	"neanias/everforest-nvim",
	version = false,
	lazy = false,
	priority = 1000,
	config = function()
		require("everforest").setup({
			background = "medium",
			transparent_background_level = 2,
			italics = false,
			disable_italic_comments = false,
			sign_column_background = "none",
			ui_contrast = "low",
			dim_inactive_windows = false,
			diagnostic_text_highlight = false,
			diagnostic_virtual_text = "coloured",
			diagnostic_line_highlight = false,
			spell_foreground = false,
			show_eob = true,
			float_style = "bright",
			inlay_hints_background = "dimmed",

			-- Custom highlights
			on_highlights = function(hl, palette)
				-- Telescope borderless styling
				hl.TelescopeNormal = { bg = palette.none }
				hl.TelescopeBorder = { bg = palette.none, fg = palette.bg1 }
				-- Telescope Prompt
				hl.TelescopePromptNormal = { bg = palette.none }
				hl.TelescopePromptBorder = { bg = palette.none, fg = palette.bg3 }
				hl.TelescopePromptTitle = { bg = palette.purple, fg = palette.bg0, bold = true }
				hl.TelescopePromptPrefix = { bg = palette.none, fg = palette.purple }
				-- Telescope Results
				hl.TelescopeResultsNormal = { bg = palette.none }
				hl.TelescopeResultsBorder = { bg = palette.none, fg = palette.none }
				hl.TelescopeResultsTitle = { bg = palette.blue, fg = palette.bg0, bold = true }
				-- Telescope Preview
				hl.TelescopePreviewNormal = { bg = palette.none }
				hl.TelescopePreviewBorder = { bg = palette.none, fg = palette.bg1 }
				hl.TelescopePreviewTitle = { bg = palette.green, fg = palette.bg0, bold = true }
				-- Telescope Selection
				hl.TelescopeSelection = { bg = palette.bg1, fg = palette.green, bold = true }
				hl.TelescopeSelectionCaret = { bg = palette.bg1, fg = palette.green, bold = true }

				-- LSP floating windows with borders
				hl.NormalFloat = { bg = palette.none }
				hl.FloatBorder = { bg = palette.none, fg = palette.bg4 }
				hl.FloatTitle = { bg = palette.none, fg = palette.aqua, bold = true }

				-- Blink.cmp completion menu with borders
				hl.BlinkCmpMenu = { bg = palette.none, fg = palette.none }
				hl.BlinkCmpMenuBorder = { bg = palette.none, fg = palette.bg4 }
				hl.BlinkCmpMenuSelection = { bg = palette.bg3, bold = true }
				hl.BlinkCmpDoc = { bg = palette.none }
				hl.BlinkCmpDocBorder = { bg = palette.none, fg = palette.bg4 }
				hl.BlinkCmpSignatureHelp = { bg = palette.none }
				hl.BlinkCmpSignatureHelpBorder = { bg = palette.none, fg = palette.bg4 }

				-- Neo-tree borderless
				hl.NeoTreeNormal = { bg = palette.none }
				hl.NeoTreeNormalNC = { bg = palette.none }
				hl.NeoTreeWinSeparator = { bg = palette.none, fg = palette.none }
				hl.NeoTreeBorder = { bg = palette.none, fg = palette.none }
				hl.NeoTreeEndOfBuffer = { bg = palette.none }

				-- Plugins window
				hl.MasonNormal = { bg = palette.none, fg = palette.bg1 }
				hl.LazyNormal = { bg = palette.none, fg = palette.bg1 }

				-- Statusline
				hl.StatusLine = { bg = palette.none }
				hl.StatusLineNC = { bg = palette.none }

				-- Selection in visual mode
				hl.Visual = { bg = palette.bg1, fg = palette.none }
				hl.VisualNOS = { bg = palette.bg1, fg = palette.none }
			end,
		})

		vim.cmd.colorscheme("everforest")
	end,
}
