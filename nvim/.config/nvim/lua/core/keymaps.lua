local keymap = vim.keymap

-- Moving highlighted stuff up and down
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- For quick scrolling with centering
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- Yank to system clipboard
keymap.set("n", "<leader>y", '"+y')
keymap.set("v", "<leader>y", '"+y')
keymap.set("n", "<leader>Y", '"+Y')

-- Skill issue
keymap.set("i", "jk", "<Esc>")

-- Turns off Q key bc it's annoying
keymap.set("n", "Q", "<nop>")

-- Mass replace string in file
keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Makes file executable (chmod +x)
keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Oil.nvim
keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open Parent Directory" })

keymap.set("n", "<leader>h", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)
