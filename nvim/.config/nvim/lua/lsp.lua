local keymap = vim.keymap
local severity = vim.diagnostic.severity

-- ============================================================================
-- LSP HANDLERS - Configure borders for hover and signature help
-- ============================================================================
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
	focusable = false,
	max_width = 80,
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "rounded",
	focusable = false,
})

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
		source = "always", -- Shows the source of the diagnostic
		header = "",
		prefix = "",
		focusable = false,
	},
	virtual_text = true, -- Keep inline diagnostics
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

		-- LSP Navigation
		opts.desc = "Show LSP references"
		keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

		opts.desc = "Go to declaration"
		keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

		opts.desc = "Show LSP definition"
		keymap.set("n", "gd", vim.lsp.buf.definition, opts)

		opts.desc = "Show LSP implementations"
		keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

		opts.desc = "Show LSP type definitions"
		keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

		-- LSP Actions
		opts.desc = "See available code actions"
		keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

		opts.desc = "Smart rename"
		keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

		-- Diagnostics
		opts.desc = "Show buffer diagnostics"
		keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

		opts.desc = "Show line diagnostics"
		keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

		opts.desc = "Go to previous diagnostic"
		keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, opts)

		opts.desc = "Go to next diagnostic"
		keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, opts)

		-- Documentation
		opts.desc = "Show documentation for what is under cursor"
		keymap.set("n", "K", vim.lsp.buf.hover, opts)

		-- LSP Control
		opts.desc = "Restart LSP"
		keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
	end,
})
