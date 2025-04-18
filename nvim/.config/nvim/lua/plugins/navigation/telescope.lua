return {
	-- Основной плагин Telescope
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x", -- Используем стабильную ветку 0.1.x

	-- Зависимости
	dependencies = {
		"nvim-lua/plenary.nvim", -- Библиотека утилит для Lua в Neovim
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- Быстрый нативный алгоритм поиска fzf
		"nvim-tree/nvim-web-devicons", -- Иконки для файлов
		"nvim-telescope/telescope-file-browser.nvim", -- Файловый браузер
		"nvim-telescope/telescope-ui-select.nvim", -- Замена vim.ui.select
	},

	-- Функция конфигурации, запускается после загрузки плагина
	config = function()
		-- Импортируем необходимые модули
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		-- Настройка Telescope
		telescope.setup({
			defaults = {
				-- Настройки внешнего вида
				border = {}, -- Пустой аргумент border использует стиль по умолчанию
				borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }, -- Символы для рамки
				path_display = { "truncate" }, -- Обрезает длинные пути для лучшей читаемости
				color_devicons = true, -- Цветные иконки файлов

				-- Настройки окружения
				set_env = { ["COLORTERM"] = "truecolor" }, -- Обеспечивает поддержку true color

				-- Улучшенный предпросмотр файлов
				file_previewer = require("telescope.previewers").vim_buffer_cat.new,
				grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,

				-- Игнорирование некоторых файлов при поиске
				file_ignore_patterns = {
					"node_modules",
					".git",
					"target",
					"build",
					"dist",
				},

				-- Выбор сортировки для результатов
				sorting_strategy = "ascending", -- Показывать результаты сверху вниз
				layout_strategy = "horizontal", -- Горизонтальное расположение
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},
				-- Горячие клавиши для режима ввода (insert mode)
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- Переход к предыдущему результату
						["<C-j>"] = actions.move_selection_next, -- Переход к следующему результату
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- Отправить выбранные файлы в quickfix и открыть его
					},
				},
			},
		})

		-- Загружаем расширения
		telescope.load_extension("fzf") -- Быстрый поиск с fzf
		telescope.load_extension("file_browser") -- Файловый браузер
		telescope.load_extension("ui-select") -- Улучшенное UI для выбора

		-- Настройка горячих клавиш для быстрого доступа к функциям Telescope
		local keymap = vim.keymap -- Для краткости

		-- Поиск файлов
		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" }) -- Поиск файлов в текущей директории

		-- Поиск недавно открытых файлов
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" }) -- Поиск среди недавно открытых файлов

		-- Поиск текста в файлах
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" }) -- Поиск строки во всех файлах директории (требует ripgrep)

		-- Поиск слова под курсором
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" }) -- Поиск слова под курсором

		-- Поиск буферов
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find open buffers" })

		-- Поиск в справке Vim
		keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help" })

		-- Показать диагностику текущего файла
		keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Document diagnostics" })

		-- Показать диагностику всего проекта
		keymap.set("n", "<leader>fD", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace diagnostics" })

		-- Открыть файловый браузер
		keymap.set("n", "<leader>fe", "<cmd>Telescope file_browser<cr>", { desc = "Open file browser" })
	end,
}
