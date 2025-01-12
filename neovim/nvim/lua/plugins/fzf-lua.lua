local function symbols_filter(entry, ctx)
	if ctx.symbols_filter == nil then
		ctx.symbols_filter = Myutil.config.get_kind_filter(ctx.bufnr) or false
	end
	if ctx.symbols_filter == false then
		return true
	end
	return vim.tbl_contains(ctx.symbols_filter, entry.kind)
end

return {
	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		-- or if using mini.icons/mini.nvim
		-- dependencies = { "echasnovski/mini.icons" },
		opts = function()
			local fzf = require("fzf-lua")
			local config = fzf.config
			local actions = fzf.actions

			-- Quickfix
			config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
			config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
			config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
			config.defaults.keymap.fzf["ctrl-x"] = "jump"
			config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
			config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
			config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
			config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

			-- Trouble
			if Myutil.has("trouble.nvim") then
				config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
			end

			-- Toggle root dir/cwd
			-- config.defaults.actions.files["ctrl-r"] = function(_, ctx)
			-- 	local o = vim.deepcopy(ctx.__call_opts)
			-- 	o.root = o.root == false
			-- 	o.cwd = nil
			-- 	o.buf = ctx.__CTX.bufnr
			-- 	Myutil.pick.open(ctx.__INFO.cmd, o)
			-- end
			-- config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]
			-- config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

			local img_previewer ---@type string[]?
			for _, v in ipairs({
				{ cmd = "ueberzug", args = {} },
				{ cmd = "chafa", args = { "{file}", "--format=symbols" } },
				{ cmd = "viu", args = { "-b" } },
			}) do
				if vim.fn.executable(v.cmd) == 1 then
					img_previewer = vim.list_extend({ v.cmd }, v.args)
					break
				end
			end

			return {
				"default-title",
				fzf_colors = true,
				fzf_opts = {
					["--no-scrollbar"] = true,
				},
				defaults = {
					-- formatter = "path.filename_first",
					formatter = "path.dirname_first",
				},
				previewers = {
					builtin = {
						extensions = {
							["png"] = img_previewer,
							["jpeg"] = img_previewer,
							["jpg"] = img_previewer,
							["gif"] = img_previewer,
							["webp"] = img_previewer,
						},
						ueberzug_scaler = "fit_contain",
					},
				},
				-- Custom lazyvim option to configure vim.ui.select
				ui_select = function(fzf_opts, items)
					return vim.tbl_deep_extend("force", fzf_opts, {
						prompt = " ",
						winopts = {
							title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
							title_pos = "center",
						},
					}, fzf_opts.kind == "codeaction" and {
						winopts = {
							layout = "vertical",
							-- height is number of items minus 15 lines for the preview, with a max of 80% screen height
							height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
							width = 0.5,
							preview = not vim.tbl_isempty(Myutil.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
								layout = "vertical",
								vertical = "down:15,border-top",
								hidden = "hidden",
							} or {
								layout = "vertical",
								vertical = "down:15,border-top",
							},
						},
					} or {
						winopts = {
							width = 0.5,
							-- height is number of items, with a max of 80% screen height
							height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
						},
					})
				end,
				winopts = {
					width = 0.8,
					height = 0.8,
					row = 0.5,
					col = 0.5,
					preview = {
						scrollchars = { "┃", "" },
					},
				},
				files = {
					cwd_prompt = false,
					actions = {
						["alt-i"] = { actions.toggle_ignore },
						["alt-h"] = { actions.toggle_hidden },
					},
				},
				grep = {
					actions = {
						["alt-i"] = { actions.toggle_ignore },
						["alt-h"] = { actions.toggle_hidden },
					},
				},
				lsp = {
					symbols = {
						symbol_hl = function(s)
							return "TroubleIcon" .. s
						end,
						symbol_fmt = function(s)
							return s:lower() .. "\t"
						end,
						child_prefix = false,
					},
					code_actions = {
						previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
					},
				},
			}
		end,
		config = function(_, opts)
			if opts[1] == "default-title" then
				-- use the same prompt for all pickers for profile 'default-title' and
				-- profiles that use 'default-title' as base profile
				local function fix(t)
					t.prompt = t.prompt ~= nil and "> " or nil
					for _, v in pairs(t) do
						if type(v) == "table" then
							fix(v)
						end
					end
					return t
				end
				opts = vim.tbl_deep_extend("force", fix(require("fzf-lua.profiles.default-title")), opts)
				opts[1] = nil
			end
			require("fzf-lua").setup(opts)
		end,
		init = function()
			Myutil.on_very_lazy(function()
				vim.ui.select = function(...)
					require("lazy").load({ plugins = { "fzf-lua" } })
					local opts = Myutil.opts("fzf-lua") or {}
					require("fzf-lua").register_ui_select(opts.ui_select or nil)
					return vim.ui.select(...)
				end
			end)

			vim.api.nvim_create_autocmd("VimEnter", {
				group = vim.api.nvim_create_augroup("start_directory", { clear = true }),
				desc = "Open a folder",
				once = true,
				callback = function()
					local stats = vim.uv.fs_stat(vim.fn.argv(0))
					if stats and stats.type == "directory" then
						-- State to track current explorer
						local current_explorer = "fzf-lua"

						-- Function to toggle between fzf-lua and neotree
						local function toggle_explorer()
							if current_explorer == "fzf-lua" then
								-- Close fzf-lua by simulating an <Esc> keypress
								vim.api.nvim_feedkeys(
									vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
									"n",
									false
								)
								vim.schedule(function()
									vim.cmd("Neotree show") -- Show Neotree
									current_explorer = "neotree"
								end)
							else
								-- Close neotree and open fzf-lua
								vim.cmd("Neotree close")
								vim.schedule(function()
									require("fzf-lua").files()
									current_explorer = "fzf-lua"
								end)
							end
						end

						-- Set keymap to toggle using "~"
						vim.keymap.set(
							"n",
							"~",
							toggle_explorer,
							{ desc = "Toggle between fzf-lua and neotree", silent = true }
						)

						-- Open fzf-lua initially
						require("fzf-lua").files()
					end
				end,
			})

			-- vim.api.nvim_create_autocmd("VimEnter", {
			-- 	group = vim.api.nvim_create_augroup("start_directory", { clear = true }),
			-- 	desc = "Open a folder",
			-- 	once = true,
			-- 	callback = function()
			-- 		local stats = vim.uv.fs_stat(vim.fn.argv(0))
			-- 		if stats and stats.type == "directory" then
			-- 			require("fzf-lua").files()
			-- 		end
			-- 	end,
			-- })
		end,

		keys = {
			{ "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
			{ "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },
			{
				"<leader>,",
				"<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",
				desc = "Switch Buffer",
			},
			-- { "<leader>/", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
			{ "<leader>/", "<cmd>FzfLua live_grep<cr>", desc = "Grep (Root Dir)" },
			{ "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
			-- { "<leader><space>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
			{ "<leader><space>", "<cmd>FzfLua files", desc = "Find Files (Root Dir)" },
			-- find
			{ "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
			-- { "<leader>fc", LazyVim.pick.config_files(), desc = "Find Config File" },
			{ "<leader>fc", "<cmd>FzfLua files cwd=~/.config<cr>", desc = "Find Config File" },
			-- { "<leader>ff", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
			{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files (Root Dir)" },
			-- { "<leader>fF", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
			{
				"<leader>fF",
				function()
					require("fzf-lua").files({ root = false })
				end,
				desc = "Find Files (cwd)",
			},
			{ "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Files (git-files)" },
			{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
			-- { "<leader>fR", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
			{
				"<leader>fR",
				function()
					require("fzf-lua").oldfiles({ cwd = vim.uv.cwd() })
				end,
				desc = "Recent (cwd)",
			},
			-- git
			{ "<leader>gc", "<cmd>FzfLua git_commits<CR>", desc = "Commits" },
			{ "<leader>gs", "<cmd>FzfLua git_status<CR>", desc = "Status" },
			-- search
			{ '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
			{ "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "Auto Commands" },
			{ "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", desc = "Buffer" },
			{ "<leader>sc", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
			{ "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
			{ "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document Diagnostics" },
			{ "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics" },
			{ "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Grep (Root Dir)" },
			-- { "<leader>sG", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
			{
				"<leader>sG",
				function()
					require("fzf-lua").live_grep({ root = false })
				end,
				desc = "Grep (cwd)",
			},
			{ "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
			{ "<leader>sH", "<cmd>FzfLua highlights<cr>", desc = "Search Highlight Groups" },
			{ "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
			{ "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
			{ "<leader>sl", "<cmd>FzfLua loclist<cr>", desc = "Location List" },
			{ "<leader>sM", "<cmd>FzfLua man_pages<cr>", desc = "Man Pages" },
			{ "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Jump to Mark" },
			{ "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume" },
			{ "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
			-- { "<leader>sw", LazyVim.pick("grep_cword"), desc = "Word (Root Dir)" },
			{ "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "Word (Root Dir)" },
			-- { "<leader>sW", LazyVim.pick("grep_cword", { root = false }), desc = "Word (cwd)" },
			{
				"<leader>sW",
				function()
					require("fzf-lua").grep_cword({ root = false })
				end,
				desc = "Word (cwd)",
			},
			-- { "<leader>sw", LazyVim.pick("grep_visual"), mode = "v", desc = "Selection (Root Dir)" },
			{ "<leader>sw", "<cmd>FzfLua grep_visual", mode = "v", desc = "Selection (Root Dir)" },
			-- { "<leader>sW", LazyVim.pick("grep_visual", { root = false }), mode = "v", desc = "Selection (cwd)" },
			{
				"<leader>sW",
				function()
					require("fzf-lua").grep_visual({ root = false })
				end,
				mode = "v",
				desc = "Selection (cwd)",
			},
			-- { "<leader>uC", LazyVim.pick("colorschemes"), desc = "Colorscheme with Preview" },
			{ "<leader>uC", "<cmd>FzfLua colorschemes<cr>", desc = "Colorscheme with Preview" },
			{
				"<leader>ss",
				function()
					require("fzf-lua").lsp_document_symbols({
						regex_filter = symbols_filter,
					})
				end,
				desc = "Goto Symbol",
			},
			{
				"<leader>sS",
				function()
					require("fzf-lua").lsp_live_workspace_symbols({
						regex_filter = symbols_filter,
					})
				end,
				desc = "Goto Symbol (Workspace)",
			},
		},
	},
}
