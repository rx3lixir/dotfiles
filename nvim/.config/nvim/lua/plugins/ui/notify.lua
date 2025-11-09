return {
	"rcarriga/nvim-notify",
	lazy = false,
	config = function()
		local notify = require("notify")

		vim.notify = notify

		-- Optional: configure how it looks and behaves
		notify.setup({
			-- Animation style (fade_in_slide_out, fade, slide, static)
			stages = "fade_in_slide_out",

			-- How long notifications stay on screen (in ms)
			timeout = 2000,

			-- Max width of notification window
			max_width = 30,

			-- Where notifications appear
			-- top_left, top_right, bottom_left, bottom_right
			-- or just top, bottom, left, right
			render = "default",
		})
	end,
}
