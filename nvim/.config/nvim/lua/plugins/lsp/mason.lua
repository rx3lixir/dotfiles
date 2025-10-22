return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
				border = "rounded",
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"ts_ls",
				"svelte",
				"pyright",
				"html",
				"cssls",
				"lua_ls",
				"emmet_ls",
				"tailwindcss",
				"gopls",
				"sqls",
				"htmx",
				"yamlls",
			},
			-- auto-install configured servers (with lspconfig)
			automatic_installation = true, -- not the same as ensure_installed
		})

		mason_tool_installer.setup({
			-- Linters and formatters basicly
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"eslint_d", -- js linter
				"sqlfmt", -- sql formatter

				"gofumpt", -- Strict Go formatter
				"goimports-reviser", -- Go Imports formatter
				"golines", -- Lines Go shortener

				"yamllint", -- Linter for yaml
				"yamlfmt", -- Formatter for yaml

				"black", -- Formatter for python
			},
		})
	end,
}
