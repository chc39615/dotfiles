local function check_activate()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
		if ft == "neo-tree" then
			vim.cmd("Neotree close")
			return true
		end
	end
	return false
end

-- 先用一陣子, 看看有沒有需要把整個 git_files 換成 files
local function is_git_repo()
	-- Run a git command to check if the current directory is a git repository
	local handle = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null")
	if handle == nil then
		return false -- Return false if popen fails (e.g., git not installed)
	end
	local result = handle:read("*a")
	handle:close()
	return result:match("true") ~= nil
end

return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{
				"<leader>fe",
				function()
					-- Check if any Neo-tree window is open
					if check_activate() then
						vim.cmd("Neotree close")
					else
						-- If not open, open the filesystem view (or your preferred default)
						require("neo-tree.command").execute({ toggle = true, dir = Myutil.root() })
					end
				end,
				desc = "Explorer NeoTree (Root dir)",
			},
			{
				"<leader>fE",
				function()
					-- Check if any Neo-tree window is open
					if check_activate() then
						vim.cmd("Neotree close")
					else
						-- If not open, open the filesystem view (or your preferred default)
						-- require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
						require("neo-tree.command").execute({ toggle = true, dir = Myutil.root.buffolder() })
					end
				end,
				desc = "Explorer NeoTree (cwd)",
			},
			{ "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root dir)", remap = true },
			{ "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
			{
				"<leader>ge",
				function()
					require("neo-tree.command").execute({ source = "git_status", toggle = true })
				end,
				desc = "Git Explorer",
			},
			{
				"<leader>be",
				function()
					require("neo-tree.command").execute({ source = "buffers", toggle = true })
				end,
				desc = "Buffer Explorer",
			},
		},
		deactivate = function()
			vim.cmd([[Neotree close]])
		end,
		init = function()
			-- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
			-- because `cwd` is not set up properly.
			-- This autocmd will open Neotree when open a folder
			vim.api.nvim_create_autocmd("BufEnter", {
				group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
				desc = "Start Neo-tree with directory",
				once = true,
				callback = function()
					if package.loaded["neo-tree"] then
						return
					else
						local stats = vim.uv.fs_stat(vim.fn.argv(0))
						if stats and stats.type == "directory" then
							-- open neo-tree
							require("neo-tree")

							vim.defer_fn(function()
								-- open fzf-lua if the plugin installed
								if Myutil.has("fzf-lua") then
									if is_git_repo() then
										require("fzf-lua").git_files({ cwd = vim.fn.argv(0) })
									else
										require("fzf-lua").files({ cwd = vim.fn.argv(0) })
									end
								end

								-- Close the initial empty buffer
								-- hijack_netrw_behavior: "open_default" will open a empty buffer,
								-- use this autocmd to close it.
								-- hijack_netrw_behavior: "open_current" doesn't have empty buffer,
								-- can comment out this autocmd
								-- for _, buf in ipairs(vim.api.nvim_list_bufs()) do
								-- 	print("bufnr: " .. buf)
								-- 	if
								-- 		vim.fn.bufname(buf) == ""
								-- 		and vim.api.nvim_get_option_value("buftype", { buf = buf }) == ""
								-- 	then
								-- 		vim.api.nvim_buf_delete(buf, { force = true })
								-- 	end
								-- end

								-- enable close_if_last_window
								-- 不知道有什麼用, 暫時comment out
								-- vim.api.nvim_create_autocmd("BufReadPost", {
								-- 	once = true, -- only execute this once
								-- 	callback = function()
								-- 		require("neo-tree").config.close_if_last_window = true
								-- 	end,
								-- })
							end, 30)
						end
					end
				end,
			})
		end,
		opts = {
			enable_git_status = true,
			enable_diagnostics = false,
			sources = { "filesystem", "buffers", "git_status" },
			open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
			event_handlers = {
				{
					event = "file_opened",
					handler = function()
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
				{
					event = "neo_tree_window_after_close",
					handler = function(args)
						if args.position == "left" or args.position == "right" then
							vim.cmd("wincmd =")
						end
					end,
				},
				{
					event = "neo_tree_window_after_open",
					handler = function(args)
						if args.position == "left" or args.position == "right" then
							vim.cmd("wincmd =")
						end
					end,
				},
			},
			filesystem = {
				bind_to_cwd = false,
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
				hijack_netrw_behavior = "open_current",
				-- open_current: use current buffer to open neo-tree
				-- open_default: use a new buffer(side) to open neo-tree
				window = {
					position = "left",
					mappings = {
						["h"] = function(state)
							local node = state.tree:get_node()
							if node.type == "directory" and node:is_expanded() then
								require("neo-tree.sources.filesystem").toggle_directory(state, node)
							else
								require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
							end
						end,
						["l"] = function(state)
							local node = state.tree:get_node()
							if node.type == "directory" then
								if not node:is_expanded() then
									require("neo-tree.sources.filesystem").toggle_directory(state, node)
								elseif node:has_children() then
									require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
								end
							end
						end,
						["<space>"] = "none",
						["Y"] = {
							function(state)
								local node = state.tree:get_node()
								local path = node:get_id()
								vim.fn.setreg("+", path, "c")
							end,
							desc = "Copy Path to Clipboard",
						},
						["O"] = {
							function(state)
								require("lazy.util").open(state.tree:get_node().path, { system = true })
							end,
							desc = "Open with System Application",
						},
						["P"] = { "toggle_preview", config = { use_float = false } },
						["F"] = "clear_filter",
						-- ["/"] = "none",
						["<c-s>"] = "open_split",
						["<c-v>"] = "open_vsplit",
						["<c-f>"] = "none",
						["<c-b>"] = "none",
						["<esc>"] = "none",
					},
				},
			},
			default_component_configs = {
				indent = {
					with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
				git_status = {
					symbols = {
						deleted = " ",
						unstaged = "󰄱",
						staged = "󰱒",
					},
				},
			},
		},
		config = function(_, opts)
			local function on_move(data)
				Myutil.lsp.on_rename(data.source, data.destination)
			end

			local events = require("neo-tree.events")
			opts.event_handlers = opts.event_handlers or {}
			vim.list_extend(opts.event_handlers, {
				{ event = events.FILE_MOVED, handler = on_move },
				{ event = events.FILE_RENAMED, handler = on_move },
			})
			require("neo-tree").setup(opts)
			vim.api.nvim_create_autocmd("TermClose", {
				pattern = "*lazygit",
				callback = function()
					if package.loaded["neo-tree.sources.git_status"] then
						require("neo-tree.sources.git_status").refresh()
					end
				end,
			})
		end,
	},
}
