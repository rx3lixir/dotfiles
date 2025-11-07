return {
	"catppuccin/nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			background = {
				light = "latte",
				dark = "mocha",
			},
			transparent_background = true, -- transparent background
			show_end_of_buffer = false,
			term_colors = true,
			dim_inactive = {
				enabled = false,
				shade = "dark",
				percentage = 0.15,
			},
			no_italic = false,
			no_bold = false,
			no_underline = false,
			styles = {
				comments = { "italic" },
				conditionals = { "italic" },
				loops = {},
				functions = {},
				keywords = {},
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
				operators = {},
			},

			custom_highlights = function(colors)
				return {
					-- Telescope borderless styling
					TelescopeNormal = { bg = colors.none },
					TelescopeBorder = { bg = colors.none, fg = colors.surface1 },
					-- Telescope Prompt
					TelescopePromptNormal = { bg = colors.none },
					TelescopePromptBorder = { bg = colors.none, fg = colors.surface1 },
					TelescopePromptTitle = { bg = colors.mauve, fg = colors.base, bold = true },
					TelescopePromptPrefix = { bg = colors.none, fg = colors.mauve },
					-- Telescope Results
					TelescopeResultsNormal = { bg = colors.none },
					TelescopeResultsBorder = { bg = colors.none, fg = colors.none },
					TelescopeResultsTitle = { bg = colors.blue, fg = colors.base, bold = true },
					-- Telescope Preview
					TelescopePreviewNormal = { bg = colors.none },
					TelescopePreviewBorder = { bg = colors.none, fg = colors.surface1 },
					TelescopePreviewTitle = { bg = colors.green, fg = colors.base, bold = true },
					-- Telescope Selection
					TelescopeSelection = { bg = colors.none, fg = colors.lavender, bold = true },
					TelescopeSelectionCaret = { bg = colors.none, fg = colors.green, bold = true },
					TelescopeMatching = { bg = colors.none, fg = colors.blue },

					-- LSP floating windows with borders
					NormalFloat = { bg = colors.none },
					FloatBorder = { bg = colors.none, fg = colors.surface1 },
					FloatTitle = { bg = colors.none, fg = colors.lavender, bold = true },

					-- Blink.cmp completion menu with borders
					BlinkCmpMenu = { bg = colors.none },
					BlinkCmpMenuBorder = { bg = colors.none, fg = colors.surface1 },
					BlinkCmpMenuSelection = { bg = colors.surface0, bold = true },
					BlinkCmpDoc = { bg = colors.none },
					BlinkCmpDocBorder = { bg = colors.none, fg = colors.surface1 },
					BlinkCmpSignatureHelp = { bg = colors.none },
					BlinkCmpSignatureHelpBorder = { bg = colors.none, fg = colors.surface1 },

					-- Neo-tree borderless
					NeoTreeNormal = { bg = colors.none },
					NeoTreeNormalNC = { bg = colors.none },
					NeoTreeWinSeparator = { bg = colors.none, fg = colors.none },
					NeoTreeBorder = { bg = colors.none, fg = colors.none },
					NeoTreeEndOfBuffer = { bg = colors.none },

					-- Mason with borders
					MasonNormal = { bg = colors.base },
					MasonHeader = { bg = colors.mauve, fg = colors.base, bold = true },
					MasonHeaderSecondary = { bg = colors.blue, fg = colors.base, bold = true },
					MasonHighlight = { fg = colors.blue },
					MasonHighlightBlock = { bg = colors.blue, fg = colors.base },
					MasonHighlightBlockBold = { bg = colors.blue, fg = colors.base, bold = true },
					MasonMuted = { fg = colors.overlay0 },
					MasonMutedBlock = { bg = colors.surface0 },

					-- Lazy
					LazyNormal = { bg = colors.mantle },

					-- Selection in visual mode
					Visual = { bg = colors.surface0, fg = colors.none },
					VisualNOS = { bg = colors.surface0, fg = colors.none },
				}
			end,

			-- Integration settings
			integrations = {
				cmp = false, -- We use blink.cmp
				gitsigns = true,
				nvimtree = false, -- We use neo-tree
				neotree = true,
				treesitter = true,
				notify = false,
				indent_blankline = {
					enabled = true,
					scope_color = "overlay1",
					colored_indent_levels = true,
				},
				mini = {
					enabled = true,
					indentscope_color = "",
				},
				telescope = {
					enabled = true,
				},
				native_lsp = {
					enabled = true,
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
					},
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
					inlay_hints = {
						background = true,
					},
				},
				mason = true,
				which_key = false,
			},
		})

		-- Apply the colorscheme
		vim.cmd.colorscheme("catppuccin")
	end,
}
