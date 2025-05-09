return {
	-- toggleterm
	{
		"akinsho/toggleterm.nvim",
		keys = {
			{ "<C-Bslash>", "<cmd>lua Toggle_horizontal()<cr>", mode = "n", desc = "ToggleTerm" },
			{ "<leader>gg", "<cmd>lua Toggle_lazygit()<cr>", mode = "n", desc = "Lazygit" },
			{ "<leader>gy", "<cmd>lua Toggle_yazi()<cr>", mode = "n", desc = "Yazi" },
			{ "<leader>ft", "<cmd>lua Toggle_float()<cr>", mode = "n", desc = "FloatTerm" },
		},
		-- config = true,
		config = function()
			-- execute toggleterm
			require("toggleterm").setup()

			local Terminal = require("toggleterm.terminal").Terminal

			local lazygit = Terminal:new({
				cmd = "lazygit",
				direction = "float",
				hidden = true,
				close_on_exit = true,
			})

			function Toggle_lazygit()
				local has_lazygit = vim.fn.executable("lazygit") == 1
				if has_lazygit then
					lazygit:toggle()
				else
					Myutil.info("lazygit is not installed or not found in PATH.")
				end
			end

			local yazi = Terminal:new({
				cmd = "yazi",
				direction = "float",
				hidden = true,
				close_on_exit = true,
			})

			function Toggle_yazi()
				local has_yazi = vim.fn.executable("yazi") == 1
				if has_yazi then
					yazi:toggle()
				else
					Myutil.info("Yazi is not installed or not found in PATH.")
				end
			end

			local horizontal = Terminal:new({
				direction = "horizontal",
				size = 20,
				on_open = function(term)
					local noremap = { noremap = true, silent = true }
					local buf_keymap = vim.api.nvim_buf_set_keymap
					-- change terminal mode to normal
					buf_keymap(term.bufnr, "t", "<esc>", [[<c-\><c-n>]], noremap)
					buf_keymap(term.bufnr, "t", "<c-h>", [[<c-\><c-n><c-w>h]], noremap)
					buf_keymap(term.bufnr, "t", "<c-j>", [[<c-\><c-n><c-w>j]], noremap)
					buf_keymap(term.bufnr, "t", "<c-k>", [[<c-\><c-n><c-w>k]], noremap)
					buf_keymap(term.bufnr, "t", "<c-l>", [[<c-\><c-n><c-w>l]], noremap)
					buf_keymap(term.bufnr, "t", "<C-Bslash>", "<cmd>ToggleTerm<cr>", noremap)

					if Myutil.has("nvim-dap") and Myutil.has("nvim-dap-ui") then
						vim.api.nvim_create_autocmd("WinClosed", {
							buffer = term.bufnr,
							callback = function()
								vim.schedule(function()
									local filetype = vim.bo[term.bufnr].filetype
									if filetype == "toggleterm" then
										local dap, dapui = require("dap"), require("dapui")
										if dap.session() then
											-- print('dapui reset')
											dapui.open({ reset = true })
										end
									end
								end)
							end,
						})
					end
				end,
			})
			function Toggle_horizontal()
				horizontal:toggle()
			end

			local floatterm = Terminal:new({
				direction = "float",
				hidden = true,
				close_on_exist = true,
				on_open = function(term)
					local noremap = { noremap = true, silent = true }
					local buf_keymap = vim.api.nvim_buf_set_keymap
					-- change terminal mode to normal
					buf_keymap(term.bufnr, "t", "<esc>", [[<c-\><c-n>]], noremap)
				end,
			})
			function Toggle_float()
				floatterm:toggle()
			end
		end,
	},
}
