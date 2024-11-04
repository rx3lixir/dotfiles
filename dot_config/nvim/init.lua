-- Setting up LazyVim options
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Setting up vim options
require("vim-options")

-- Setting up LazyVim plugin manager
require("lazy").setup({ { import = "plugins" }, { import = "plugins.lsp" } })

-- Setting up russian keys in vim
require("rusKey")
