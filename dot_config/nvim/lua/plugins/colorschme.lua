return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("tokyonight").setup({
			style = "night",
			transparent = true,
			terminal_colors = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
			lualine_bold = true,
		})
		vim.cmd([[colorscheme tokyonight]])
	end,
}
