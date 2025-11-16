require("which-key").setup({
	plugins = {
		marks = true,
		registers = true,
		spelling = {
			enabled = true,
			suggestions = 20,
		},
		presets = {
			operators = true,
			motions = true,
			text_objects = true,
			windows = true,
			nav = true,
			z = true,
			g = true,
		},
	},
	win = {
		border = "single",
		padding = { 1, 2 },
	},
	layout = {
		spacing = 3,
	},
	show_help = true,
	show_keys = true,
	triggers = "auto",
})
