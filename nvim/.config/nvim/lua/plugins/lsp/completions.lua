return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },
	version = "1.*",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = "default",
			["<C-Z>"] = { "accept", "fallback" },
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		completion = {
			menu = {
				border = "rounded",
				winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
			},
			documentation = {
				auto_show = false,
				window = {
					border = "rounded",
					winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder",
				},
			},
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},

		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},
	},
	opts_extend = { "sources.default" },
}
