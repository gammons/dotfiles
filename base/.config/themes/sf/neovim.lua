-- Generated from colors.toml (SparkFabrik Design System).
-- The upstream theme ships no neovim config, so this maps the Spark palette
-- onto base16 via RRethy/nvim-base16, which init.lua already installs.
return {
	{ "RRethy/nvim-base16" },
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = function()
				require("base16-colorscheme").setup({
					base00 = "#031527", -- background (Spark Black)
					base01 = "#02101d", -- dark_background
					base02 = "#0c335a", -- selection (Spark Blue)
					base03 = "#4b7ba3", -- comments (derived: lightened Spark Blue for legibility)
					base04 = "#40c6cf", -- dark foreground (Spark Aquamarine)
					base05 = "#ffffff", -- foreground (Spark White)
					base06 = "#ffffff",
					base07 = "#ffffff",
					base08 = "#eb0000", -- variables (Spark Red)
					base09 = "#f36931", -- numbers (Spark Orange)
					base0A = "#f7ad2c", -- classes (Spark Yellow)
					base0B = "#68d366", -- strings (Spark Lime)
					base0C = "#40c6cf", -- support (Spark Aquamarine)
					base0D = "#027aca", -- functions (Spark Light Blue)
					base0E = "#cd0089", -- keywords (Spark Purple)
					base0F = "#7c5716", -- deprecated (brown)
				})
				-- base16-colorscheme.setup does not set this itself
				vim.g.colors_name = "base16-sf"
			end,
		},
	},
}
