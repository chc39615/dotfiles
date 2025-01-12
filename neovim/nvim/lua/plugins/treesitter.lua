return {
	{ "tpope/vim-repeat" },
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		event = { "LazyFile", "VeryLazy" },
		lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
		init = function(plugin)
			-- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
			-- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
			-- no longer trigger the **nvim-treesitter** module to be loaded in time.
			-- Luckily, the only things that those plugins need are the custom queries, which we make available
			-- during startup.
			require("lazy.core.loader").add_to_rtp(plugin)
			require("nvim-treesitter.query_predicates")
		end,
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		keys = {
			{ "<c-space>", desc = "Increment Selection" },
			{ "<bs>", desc = "Decrement Selection", mode = "x" },
		},
		opts_extend = { "ensure_installed" },
		---@type TSConfig
		---@diagnostic disable-next-line: missing-fields
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			ensure_installed = {
				"bash",
				"diff",
				"html",
				"lua",
				"luadoc",
				"python",
				"vim",
				"vimdoc",
				"yaml",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			textobjects = {
				select = {
					enable = true,

					-- Automatically jump forward to textobj, similar to targets.vim
					lookahead = true,
					keymaps = {
						--- you can use the capture groups defined in textobjects.scm
						["af"] = { query = "@function.outer", desc = "Select outer part of a function" },
						["if"] = { query = "@function.inner", desc = "Select inner part of a function" },
						["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
						["ic"] = { query = "@class.inner", dsec = "Select inner part of a class" },
						["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
					},
					-- You can choose the select mode (default is charwise 'v')
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * method: eg 'v' or 'o'
					-- and should return the mode ('v', 'V', or '<c-v>') or a table
					-- mapping query_strings to modes
					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "V", -- line wise
						["@class.outer"] = "<c-v>", -- blockwise
					},

					-- If you set this to `true` (default is `false`) then any textobject is
					-- extended to include preceding or succeeding whitespace. Succeeding
					-- whitespace has priority in order to act similarly to eg the built-in
					-- `ap`
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * selection_mode: eg 'v'
					-- and should return true or false
					include_surrounding_whitespace = false,
				},
				swap = {
					enable = false,
					swap_next = {
						["<leader>a"] = "@parameter.inner",
					},
					swap_previous = {
						["<leader>A"] = "@parameter.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
					goto_next_start = {
						["]f"] = { query = "@function.outer", desc = "Next function start" },
						["]c"] = { query = "@class.outer", desc = "Next class start" },
						["]a"] = { query = "@parameter.inner", desc = "Next parameter start" },
					},
					goto_next_end = {
						["]F"] = { query = "@function.outer", desc = "Next function end" },
						["]C"] = { query = "@class.outer", desc = "Next class end" },
						["]A"] = { query = "@parameter.inner", desc = "Next parameter end" },
					},
					goto_previous_start = {
						["[f"] = { query = "@function.outer", desc = "Previous function start" },
						["[c"] = { query = "@class.outer", desc = "Previous class start" },
						["[a"] = { query = "@parameter.inner", desc = "Previous parameter start" },
					},
					goto_previous_end = {
						["]F"] = { query = "@function.outer", desc = "Previous function end" },
						["]C"] = { query = "@class.outer", desc = "Previous class end" },
						["]A"] = { query = "@parameter.inner", desc = "Previous parameter end" },
					},
					-- Below will go to either the start or the end, whichever is closer.
					-- Use if you want more granular movements
					-- Make if even more gradual by adding multiple queries and regex.
					-- goto_next = {
					--     ["]d"] = "@conditional.outer",
					-- },
					-- goto_previous = {
					--     ["[d"] = "@conditional.outer",
					-- },
				},
			},
		},
		---@param opts TSConfig
		config = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				opts.ensure_installed = Myutil.dedup(opts.ensure_installed)
			end
			require("nvim-treesitter.configs").setup(opts)
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = "VeryLazy",
		enabled = true,
		config = function()
			-- If treesitter is already loaded, we need to run config again for textobjects
			if Myutil.is_loaded("nvim-treesitter") then
				local opts = Myutil.opts("nvim-treesitter")
				require("nvim-treesitter.configs").setup({ textobjects = opts.textobjects })
			end

			-- When in diff mode, we want to use the default
			-- vim text objects c & C instead of the treesitter ones.
			if vim.wo.diff then
				local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
				local configs = require("nvim-treesitter.configs")
				for name, fn in pairs(move) do
					if name:find("goto") == 1 then
						move[name] = function(q, ...)
							local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
							for key, query in pairs(config or {}) do
								if q == query and key:find("[%]%[][cC]") then
									vim.cmd("normal! " .. key)
									return
								end
							end
							return fn(q, ...)
						end
					end
				end
			end

			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
			-- Repaet movement with ; and ,
			-- ensure ; goes forward and , goes back ward regardless of the last direction
			-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
			-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
			-- vim way: ; goes to the direction you were moving
			vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
			vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

			--Optionally, make builtin f, F, t, T also repeatable with ; and ,
			vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
			vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
		end,
	},
}
