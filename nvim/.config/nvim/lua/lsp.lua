local keymap = vim.keymap
local severity = vim.diagnostic.severity

vim.o.winborder = "rounded"

-- ============================================================================
-- DIAGNOSTIC CONFIGURATION - Configure borders for diagnostic floats
-- ============================================================================
vim.diagnostic.config({
	signs = {
		text = {
			[severity.ERROR] = " ",
			[severity.WARN] = " ",
			[severity.HINT] = "󰠠 ",
			[severity.INFO] = " ",
		},
	},
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
		focusable = false,
	},
	virtual_text = true,
	update_in_insert = false,
	underline = true,
	severity_sort = true,
})

-- ============================================================================
-- LSP ATTACH - Keymaps and additional config when LSP attaches
-- ============================================================================
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local opts = { buffer = ev.buf, silent = true }

		-- LSP Actions
		opts.desc = "See available code actions"
		keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

		-- Diagnostics
		opts.desc = "Show buffer diagnostics"
		keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

		opts.desc = "Show line diagnostics"
		keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

		-- Documentation
		opts.desc = "Show documentation for what is under cursor"
		keymap.set("n", "K", vim.lsp.buf.hover, opts)

		-- LSP Control
		opts.desc = "Restart LSP"
		keymap.set("n", "<leader>rt", ":LspRestart<CR>", opts)
	end,
})
