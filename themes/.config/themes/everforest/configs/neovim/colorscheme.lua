return {
	"neanias/everforest-nvim",
	version = false,
	lazy = false,
	priority = 1000,
	config = function()
		vim.o.background = "dark"
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

			-- Custom highlights - this is where the magic happens
			on_highlights = function(hl, palette)
				-- Telescope borderless styling
				hl.TelescopeNormal = { bg = palette.bg1 }
				hl.TelescopeBorder = { bg = palette.bg1, fg = palette.bg1 }
				-- Telescope Prompt
				hl.TelescopePromptNormal = { bg = palette.bg3 }
				hl.TelescopePromptBorder = { bg = palette.bg3, fg = palette.bg3 }
				hl.TelescopePromptTitle = { bg = palette.purple, fg = palette.bg0, bold = true }
				hl.TelescopePromptPrefix = { bg = palette.bg3, fg = palette.purple }
				-- Telescope Results
				hl.TelescopeResultsNormal = { bg = palette.none }
				hl.TelescopeResultsBorder = { bg = palette.none, fg = palette.none }
				hl.TelescopeResultsTitle = { bg = palette.blue, fg = palette.bg0, bold = true }
				-- Telescope Preview
				hl.TelescopePreviewNormal = { bg = palette.bg1 }
				hl.TelescopePreviewBorder = { bg = palette.bg1, fg = palette.bg1 }
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

				-- Mason with borders
				hl.MasonNormal = { bg = palette.bg0 }
				hl.MasonHeader = { bg = palette.purple, fg = palette.bg0, bold = true }
				hl.MasonHeaderSecondary = { bg = palette.blue, fg = palette.bg0, bold = true }
				hl.MasonHighlight = { fg = palette.blue }
				hl.MasonHighlightBlock = { bg = palette.blue, fg = palette.bg0 }
				hl.MasonHighlightBlockBold = { bg = palette.blue, fg = palette.bg0, bold = true }
				hl.MasonMuted = { fg = palette.grey1 }
				hl.MasonMutedBlock = { bg = palette.bg3 }
			end,
		})

		vim.cmd.colorscheme("everforest")
	end,
}
