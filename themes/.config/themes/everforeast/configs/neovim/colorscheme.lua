return {
	"neanias/everforest-nvim",
	version = false,
	lazy = false,
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		vim.o.background = "dark"
		require("everforest").setup({
			background = "soft",
			transparent_background_level = 2,
			italics = false,
			disable_italic_comments = false,
			sign_column_background = "none",
			ui_contrast = "low",
			dim_inactive_windows = false,
			diagnostic_text_highlight = false,
			---Which colour the diagnostic text should be. Options are `"grey"` or `"coloured"` (default)
			diagnostic_virtual_text = "coloured",
			---Some plugins support highlighting error/warning/info/hint lines, but this
			---feature is disabled by default in this colour scheme.
			diagnostic_line_highlight = false,
			---By default, this color scheme won't colour the foreground of |spell|, instead
			---colored under curls will be used. If you also want to colour the foreground,
			---set this option to `true`.
			spell_foreground = false,
			---Whether to show the EndOfBuffer highlight.
			show_eob = true,
			---Style used to make floating windows stand out from other windows. `"bright"`
			---makes the background of these windows lighter than |hl-Normal|, whereas
			---`"dim"` makes it darker.
			---
			---Floating windows include for instance diagnostic pop-ups, scrollable
			---documentation windows from completion engines, overlay windows from
			---installers, etc.
			---
			---NB: This is only significant for dark backgrounds as the light palettes
			---have the same colour for both values in the switch.
			float_style = "dim",
			inlay_hints_background = "dimmed",
		})
		vim.cmd.colorscheme("everforest")
	end,
}
