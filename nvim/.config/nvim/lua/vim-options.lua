local opt = vim.opt

-- Устанавливает клавишу <Space> как leader-key, для кастомок
vim.g.mapleader = " "

-- Нумерация + относительная нумерация на постоянной основе
opt.nu = true
opt.relativenumber = true

-- Настройки табуляции:
opt.tabstop = 2 -- Ширина таба в пробелах
opt.softtabstop = 2 -- Количество пробелов при нажатии Tab
opt.shiftwidth = 2 -- Количество пробелов для отступа при использовании >> | <<
opt.expandtab = true -- Заменяет табы на пробелы

-- Умные отступы: вкл
opt.smartindent = true

-- Перенос строк: откл
opt.wrap = false

-- Отключает создание свап-файла
opt.swapfile = false

-- Отключает бэкапы
opt.backup = false

-- Настройки для функции постоянной отмены (persistent undo):
opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- Директория для хранения undo-истории
opt.undofile = true -- Включает сохранение undo-истории между сессиями

-- Отключает подсветку всех результатов поиска
opt.hlsearch = false

-- Включает инкрементальный поиск (по мере ввода)
opt.incsearch = true

-- Включает поддержку 24-битных цветов в терминале
opt.termguicolors = true

-- Устанавливает минимум 8 строк видимости сверху/снизу при скроллинге
opt.scrolloff = 8

-- Включает колонку знаков слева от номеров строк (для LSP, git и т.д.)
opt.signcolumn = "yes"

-- Устанавливает время обновления в мс (влияет на скорость реакции)
opt.updatetime = 50

-- Отключает вертикальную линию ограничения длины строки
opt.colorcolumn = "0"
