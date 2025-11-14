return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"neovim/nvim-lspconfig",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		-- Enable mason and configure icons
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
			-- List of LSP servers for mason to install
			ensure_installed = {
				"ts_ls",
				"svelte",
				"html",
				"cssls",
				"lua_ls",
				"emmet_ls",
				"tailwindcss",
				"gopls",
				"rust_analyzer",
				"yamlls",
			},
			-- Auto-install configured servers (with lspconfig)
			automatic_installation = true, -- not the same as ensure_installed
		})

		mason_tool_installer.setup({
			-- Linters and formatters basicly
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"eslint_d", -- js linter

				"gofumpt", -- Strict Go formatter
				"goimports-reviser", -- Go Imports formatter
				"golines", -- Lines Go shortener

				"yamllint", -- Linter for yaml
				"yamlfmt", -- Formatter for yaml
			},
		})
	end,
}
