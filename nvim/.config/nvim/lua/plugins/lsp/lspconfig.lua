-- LSP Configuration
return {
	"neovim/nvim-lspconfig",
	-- Загружать плагин только когда открывается файл
	event = { "BufReadPre", "BufNewFile" },
	-- Зависимости, необходимые для работы LSP
	dependencies = {
		-- Интеграция с nvim-cmp для автодополнения
		"hrsh7th/cmp-nvim-lsp",
		-- Плагин для операций с файлами через LSP
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		----------------------------------------------------------------------
		-- БАЗОВАЯ НАСТРОЙКА
		----------------------------------------------------------------------
		-- Импорт основных модулей
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local util = require("lspconfig/util")
		local keymap = vim.keymap -- Для краткости

		----------------------------------------------------------------------
		-- НАСТРОЙКА ДИАГНОСТИКИ
		----------------------------------------------------------------------
		-- Настройка значков для диагностических сообщений в gutter
		local x = vim.diagnostic.severity
		vim.diagnostic.config({
			virtual_text = { prefix = " " },
			signs = {
				text = {
					[x.ERROR] = " ",
					[x.WARN] = " ",
					[x.HINT] = "󰠠 ",
					[x.INFO] = " ",
				},
			},
		})

		----------------------------------------------------------------------
		-- ОБРАБОТЧИК ПОДКЛЮЧЕНИЯ И СОЧЕТАНИЯ КЛАВИШ
		----------------------------------------------------------------------
		local opts = { noremap = true, silent = true }

		-- Функция, вызываемая при подключении LSP сервера к буферу
		local on_attach = function(client, bufnr)
			opts.buffer = bufnr

			-- НАВИГАЦИЯ ПО КОДУ
			-- Показать ссылки на текущий символ
			opts.desc = "Показать использования символа"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

			-- Перейти к объявлению
			opts.desc = "Перейти к объявлению"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			-- Показать определения
			opts.desc = "Показать определения"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

			-- Показать реализации интерфейса
			opts.desc = "Показать реализации"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

			-- Показать определения типов
			opts.desc = "Показать определения типов"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

			-- ДЕЙСТВИЯ С КОДОМ
			-- Показать доступные действия с кодом
			opts.desc = "Доступные действия с кодом"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

			-- Умное переименование символа
			opts.desc = "Переименовать символ"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			-- ДИАГНОСТИКА
			-- Показать диагностику для файла
			opts.desc = "Показать диагностику буфера"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

			-- Показать диагностику для текущей строки
			opts.desc = "Показать диагностику строки"
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

			-- ДОКУМЕНТАЦИЯ И УПРАВЛЕНИЕ
			-- Показать документацию для элемента под курсором
			opts.desc = "Показать документацию"
			keymap.set("n", "K", vim.lsp.buf.hover, opts)

			-- Перезапуск LSP сервера
			opts.desc = "Перезапустить LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
		end

		----------------------------------------------------------------------
		-- ОБЩИЕ НАСТРОЙКИ ДЛЯ ВСЕХ СЕРВЕРОВ
		----------------------------------------------------------------------
		-- Настройка возможностей автодополнения (будет применяться к каждому серверу)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		----------------------------------------------------------------------
		-- ФУНКЦИЯ ДЛЯ НАСТРОЙКИ СЕРВЕРОВ С ДЕФОЛТНЫМИ ЗНАЧЕНИЯМИ
		----------------------------------------------------------------------
		-- Функция для установки базовой конфигурации LSP с стандартными параметрами
		local function setup_server(server_name, custom_opts)
			-- Объединяем стандартные параметры с пользовательскими
			local opts = {
				capabilities = capabilities,
				on_attach = on_attach,
			}

			-- Если есть пользовательские параметры, объединяем их с дефолтными
			if custom_opts then
				for k, v in pairs(custom_opts) do
					opts[k] = v
				end
			end

			-- Устанавливаем конфигурацию сервера
			lspconfig[server_name].setup(opts)
		end

		----------------------------------------------------------------------
		-- НАСТРОЙКА ЯЗЫКОВЫХ СЕРВЕРОВ
		----------------------------------------------------------------------

		-- Список серверов с базовой конфигурацией
		local servers = {
			"html", -- HTML сервер
			"yamlls", -- YAML сервер
			"templ", -- Templ сервер (для шаблонов Go)
			"sqls", -- SQL сервер
			"ts_ls", -- TypeScript сервер
			"cssls", -- CSS сервер
			"protols", -- PROTOBUF сервер
			"qmlls", -- Qml сервер
		}

		-- Настраиваем все стандартные серверы
		for _, server in ipairs(servers) do
			setup_server(server)
		end

		-- TypeScript/JavaScript сервер (tsserver, используется как 'ts_ls')
		-- с расширенными настройками для Next.js и TypeScript проектов.
		setup_server("ts_ls", {
			filetypes = {
				"typescript",
				"typescriptreact", -- Для .tsx файлов
				"typescript.tsx", -- Некоторые конфигурации могут ожидать это
				"javascript",
				"javascriptreact", -- Для .jsx файлов
				"javascript.jsx", -- Некоторые конфигурации могут ожидать это
			},
			-- Определение корневого каталога проекта. Это важно для tsserver
			root_dir = util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".next", ".git"),
		})

		setup_server("qmlls", {
			cmd_env = {
				QML_IMPORT_PATH = "/usr/lib/qt6/qml",
				QML2_IMPORT_PATH = "/usr/lib/qt6/qml",
			},
			filetypes = { "qml" },
			handlers = {
				["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
					-- Filter out the annoying diagnostics before processing
					if result and result.diagnostics then
						result.diagnostics = vim.tbl_filter(function(diagnostic)
							-- Keep only diagnostics that aren't about lineNumber
							if diagnostic.message:match("lineNumber") then
								return false
							end
							if diagnostic.message:match("Warnings occurred while importing") then
								return false
							end
							return true
						end, result.diagnostics)
					end

					-- Call the default handler with filtered diagnostics
					vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
				end,
			},
			on_attach = on_attach,
		})

		-- SVELTE сервер с особой обработкой изменений TS/JS файлов
		setup_server("svelte", {
			on_attach = function(client, bufnr)
				-- Сначала применяем общие настройки
				on_attach(client, bufnr)

				-- Добавляем специальную обработку для .js и .ts файлов в проектах Svelte
				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx)
						if client.name == "svelte" then
							-- Уведомляем Svelte сервер об изменениях в TS/JS файлах
							client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
						end
					end,
				})
			end,
		})

		setup_server("pyright", {
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "workspace",
						typeCheckingMode = "basic",
					},
				},
			},
		})

		-- GO сервер (gopls) с дополнительными настройками
		setup_server("gopls", {
			cmd = { "gopls" },
			filetypes = { "go", "gomod", "gowork", "gotmpl" },
			-- Определение корневого каталога проекта
			root_dir = util.root_pattern("go.work", "go.mod", ".git"),
			settings = {
				gopls = {
					-- Автоматически добавлять импорты при автодополнении
					completeUnimported = true,
					-- Использовать плейсхолдеры в сниппетах
					usePlaceholders = true,
					analyses = {
						-- Находить неиспользуемые параметры
						unusedparams = true,
					},
				},
			},
		})

		-- Emmet сервер для HTML/CSS сокращений с указанием поддерживаемых типов файлов
		setup_server("emmet_ls", {
			-- Список типов файлов, для которых активировать Emmet
			filetypes = {
				"html",
				"typescriptreact",
				"javascriptreact",
				"css",
				"sass",
				"scss",
				"less",
				"svelte",
			},
		})

		-- Lua сервер с особыми настройками для Neovim
		setup_server("lua_ls", {
			settings = {
				Lua = {
					-- Распознавать глобальную переменную "vim"
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						-- Включить runtime-файлы Neovim
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		})
	end,
}
