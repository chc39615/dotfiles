return {
	-- {
	-- 	"echasnovski/mini.comment",
	-- 	version = "*",
	-- 	enabled = false,
	-- 	event = "VeryLazy",
	-- 	dependencies = {
	-- 		"JoosepAlviste/nvim-ts-context-commentstring",
	-- 	},
	-- 	opts = {
	-- 		custom_commentstring = function()
	-- 			print("custom_commentstring")
	-- 			return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
	-- 		end,
	-- 	},
	-- },
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		event = "VeryLazy",
		opts = {
			enable_autocmd = false,
		},
		config = function(_, opts)
			require("ts_context_commentstring").setup(opts)
			local get_option = vim.filetype.get_option
			vim.filetype.get_option = function(filetype, option)
				return option == "commentstring"
						and require("ts_context_commentstring.internal").calculate_commentstring()
					or get_option(filetype, option)
			end
		end,
	},
}
