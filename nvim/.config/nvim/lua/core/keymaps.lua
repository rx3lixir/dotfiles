local keymap = vim.keymap

-- Перемещение выделенных строк вниз (J) и вверх (K) в визуальном режимe
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Настройка Ctrl+d и Ctrl+u для прокрутки с центрированием курсора
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- Копирование в системный буфер обмена
keymap.set({ "n", "v" }, "<leader>y", [["+y]])
keymap.set("n", "<leader>Y", [["+Y]])

-- Выход из режима вставки по нажатию jk
keymap.set("i", "jk", "<Esc>")

vim.keymap.set("n", "<leader>rr", function()
	vim.cmd("source $MYVIMRC")
	print("Neovim config reloaded!")
end, { desc = "Reload config" })

-- Отключает клавишу Q (которая по умолчанию входит в Ex режим)
keymap.set("n", "Q", "<nop>")

-- Быстрая замена слова под курсором во всём файле
keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Делает текущий файл исполняемым (chod +x)
keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Oil.nvim
keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open Parent Directory" })
