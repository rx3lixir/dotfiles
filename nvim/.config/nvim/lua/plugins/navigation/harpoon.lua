return {
	"ThePrimeagen/harpoon",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local ui = require("harpoon.ui")
		local mark = require("harpoon.mark")

		vim.keymap.set("n", "<leader>a", mark.add_file)

		vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

		vim.keymap.set("n", "<C-q>", function()
			ui.nav_file(1)
		end)

		vim.keymap.set("n", "<C-s>", function()
			ui.nav_file(2)
		end)

		vim.keymap.set("n", "<C-r>", function()
			ui.nav_file(3)
		end)

		vim.keymap.set("n", "<C-t>", function()
			ui.nav_file(4)
		end)
	end,
}
