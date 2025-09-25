return {
	{
		-- for fzf in the quickfix list
		"junegunn/fzf",
		build = "./install --bin",
		dependencies = {
			"junegunn/fzf.vim",
		},
	},
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf", -- load only for quick fix buffers
		opts = {
			auto_enable = true, -- Automatically enable nvim-bqf in quickfix windows
			auto_resize_height = true, -- Resize quickfix window height dynamically
			preview = {
				auto_preview = true, -- Automatically show preview for the selected entry
				winblend = 10, -- Opaque preview window (0 = fully, opaque, 100 = fully transparent)
				win_height = 15, -- Default height for preview window
				wrap = false, -- Don't wrap long lines in preview
			},
			-- func_map = {
			--     -- Keep your existing <Space>
			-- }
		},
		config = function(_, opts)
			require("bqf").setup(opts)
		end,
	},
}
