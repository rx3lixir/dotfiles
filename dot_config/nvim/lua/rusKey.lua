local function escape(str)
	local escape_chars = [[;,."|\]]
	return vim.fn.escape(str, escape_chars)
end

-- Наборы символов, введенных с зажатым шрифтом
local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]

-- Наборы символов, введенных как есть
local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm]]
local ru = [[ёйцукенгшщзхъфывапролджэячсмить]]

vim.opt.langmap = vim.fn.join({
	--  ; - разделитель, который не нужно экранировать
	--  |
	escape(ru_shift)
		.. ";"
		.. escape(en_shift),
	escape(ru) .. ";" .. escape(en),
}, ",")

local function map_translated_ctrls()
	-- Маппинг Ctlr+ регистронезависимый, поэтому убираем заглавные буквы
	local en_list = vim.split(en:gsub("%u", ""), "")
	local modes = { "n", "o", "i", "c", "t", "v" }

	for _, char in ipairs(en_list) do
		local keycode = "<C-" .. char .. ">"
		local tr_char = vim.fn.tr(char, en, ru)
		local tr_keycode = "<C-" .. tr_char .. ">"

		-- Предотвращаем рекурсию, если символ содержится в обеих раскладках
		if not en:find(tr_char, 1, true) then
			local term_keycodes = vim.api.nvim_replace_termcodes(keycode, true, true, true)
			vim.keymap.set(modes, tr_keycode, function()
				vim.api.nvim_feedkeys(term_keycodes, "m", true)
			end)
		end
	end
end

map_translated_ctrls()
