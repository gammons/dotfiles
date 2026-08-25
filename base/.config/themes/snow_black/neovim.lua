-- Upstream shipped four large commented-out alternatives in this file.
-- init.lua scrapes plugin paths out of the raw file text, so those comments
-- caused packer to install monokai-pro, vague, rainbow12 and koda as well.
-- Only the active theme is kept here.
return {
	{
		"metalelf0/black-metal-theme-neovim",
		lazy = false,
		priority = 1000,
		config = function()
			require("black-metal").setup({
				-- variations: bathory, burzum, dark-funeral, darkthrone, emperor,
				-- gorgoroth, immortal, impaled-nazarene, khold, marduk, mayhem,
				-- nile, taake, thyrfing, venom, windir
				theme = "bathory",
				variant = "dark",
			})
			require("black-metal").load()
		end,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = function()
				require("black-metal").setup({ theme = "bathory", variant = "dark" })
				require("black-metal").load()
			end,
		},
	},
}
