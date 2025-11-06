return {
	"AlexvZyl/nordic.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("nordic").setup({
			-- This callback can be used to override the colors used in the base palette.
			on_palette = function(palette) end,
			-- This callback can be used to override the colors used in the extended palette.
			after_palette = function(palette) end,
			-- This callback can be used to override hl before they are applied.
			on_highlight = function(hl, palette)
				-- Telescope borderless styling
				hl.TelescopeNormal = { bg = palette.none }
				hl.TelescopeBorder = { bg = palette.none, fg = palette.gray4 }
				-- Telescope Prompt
				hl.TelescopePromptNormal = { bg = palette.none }
				hl.TelescopePromptBorder = { bg = palette.none, fg = palette.gray4 }
				hl.TelescopePromptTitle = { bg = palette.magenta.base, fg = palette.black0, bold = true }
				hl.TelescopePromptPrefix = { bg = palette.none, fg = palette.magenta.base }
				-- Telescope Results
				hl.TelescopeResultsNormal = { bg = palette.none }
				hl.TelescopeResultsBorder = { bg = palette.none, fg = palette.none }
				hl.TelescopeResultsTitle = { bg = palette.blue1, fg = palette.black0, bold = true }
				-- Telescope Preview
				hl.TelescopePreviewNormal = { bg = palette.none }
				hl.TelescopePreviewBorder = { bg = palette.none, fg = palette.gray4 }
				hl.TelescopePreviewTitle = { bg = palette.green.base, fg = palette.black0, bold = true }
				-- Telescope Selection
				hl.TelescopeSelection = { bg = palette.gray2, fg = palette.green.base, bold = true }
				hl.TelescopeSelectionCaret = { bg = palette.gray2, fg = palette.green.base, bold = true }

				-- LSP floating windows with borders
				hl.NormalFloat = { bg = palette.none }
				hl.FloatBorder = { bg = palette.none, fg = palette.gray4 }
				hl.FloatTitle = { bg = palette.none, fg = palette.cyan.base, bold = true }

				-- Blink.cmp completion menu with borders
				hl.BlinkCmpMenu = { bg = palette.none }
				hl.BlinkCmpMenuBorder = { bg = palette.none, fg = palette.gray4 }
				hl.BlinkCmpMenuSelection = { bg = palette.gray4, bold = true }
				hl.BlinkCmpDoc = { bg = palette.none }
				hl.BlinkCmpDocBorder = { bg = palette.none, fg = palette.gray4 }
				hl.BlinkCmpSignatureHelp = { bg = palette.none }
				hl.BlinkCmpSignatureHelpBorder = { bg = palette.none, fg = palette.gray4 }

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
				hl.Visual = { bg = palette.gray2, fg = palette.none }
				hl.VisualNOS = { bg = palette.gray2, fg = palette.none }
			end,
			-- Enable bold keywords.
			bold_keywords = false,
			-- Enable italic comments.
			italic_comments = true,
			-- Enable editor background transparency.
			transparent = {
				bg = true,
				float = true,
			},
			-- Enable brighter float border.
			bright_border = false,
			-- Reduce the overall amount of blue in the theme (diverges from base Nord).
			reduced_blue = true,
			-- Swap the dark background with the normal one.
			swap_backgrounds = false,
			-- Cursorline options.  Also includes visual/selection.
			cursorline = {
				-- Bold font in cursorline.
				bold = false,
				-- Bold cursorline number.
				bold_number = true,
				-- Available styles: 'dark', 'light'.
				theme = "dark",
				-- Blending the cursorline bg with the buffer bg.
				blend = 0.85,
			},
			noice = {
				-- Available styles: `classic`, `flat`.
				style = "classic",
			},
			telescope = {
				-- Available styles: `classic`, `flat`.
				style = "flat",
			},
			leap = {
				dim_backdrop = false,
			},
			ts_context = {
				-- Enables dark background for treesitter-context window
				dark_background = true,
			},
		})
		vim.cmd.colorscheme("nordic")
	end,
}
