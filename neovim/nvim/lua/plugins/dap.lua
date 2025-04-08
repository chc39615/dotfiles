local function get_args(config)
	local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
	local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

	config = vim.deepcopy(config)
	---@cast args string[]
	config.args = function()
		local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
		if config.type and config.type == "java" then
			---@diagnostic disable-next-line: return-type-mismatch
			return new_args
		end
		return require("dap.utils").splitstr(new_args)
	end
	return config
end

return {
	{
		"mfussenegger/nvim-dap",
		recommended = true,
		desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

		dependencies = {
			"rcarriga/nvim-dap-ui",
			-- virtual text for the debugger
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},
		},

    -- stylua: ignore
    keys = {
      -- start / stop
      { "<F5>", function() require("dap").continue() end, desc = "Run/Continue" },
      { "<s-F5>", function() require("dap").terminate() end, desc = "Terminate" },
      { "<sc-F5>", function() require("dap").restart() end, desc = "Restart" },
      -- { "\27[15;6~", function() require("dap").restart() end, desc = "Restart" },
      -- set breakpoints
      { "<s-F9>", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      -- step
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<s-F11>", function() require("dap").step_out() end, desc = "Step Out" },
      -- { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
      -- { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      -- { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      -- { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      -- { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
      -- { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      -- { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "DAP Widgets" },
    },

		config = function()
			-- load mason-nvim-dap here, after all adapters have been setup
			if Myutil.has("mason-nvim-dap.nvim") then
				require("mason-nvim-dap").setup(Myutil.opts("mason-nvim-dap.nvim"))
			end

			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

			for name, sign in pairs(Myutil.config.icons.dap) do
				sign = type(sign) == "table" and sign or { sign }
				vim.fn.sign_define(
					"Dap" .. name,
					{ text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
				)
			end

			-- setup dap config by VsCode launch.json file
			local vscode = require("dap.ext.vscode")
			local json = require("plenary.json")
			vscode.json_decode = function(str)
				return vim.json.decode(json.json_strip_comments(str))
			end
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "nvim-neotest/nvim-nio" },
        -- stylua: ignore
        keys = {
            { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
            { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
        },
		opts = {
			-- controls = { enabled = false },
			-- expand_lines = false,
			-- layouts = {
			-- 	{
			-- 		elements = {
			-- 			{ id = "scopes", size = 0.25 },
			-- 			{ id = "breakpoints", size = 0.25 },
			-- 			{ id = "stacks", size = 0.25 },
			-- 			{ id = "watches", size = 0.25 },
			-- 		},
			-- 		size = 40,
			-- 		position = "left",
			-- 	},
			-- 	{
			-- 		elements = {
			-- 			{ id = "repl", size = 0.5 },
			-- 			{ id = "console", size = 0.5 },
			-- 		},
			-- 		size = 10,
			-- 		position = "bottom",
			-- 	},
			-- },
		},
		config = function(_, opts)
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup(opts)
			dap.listeners.after.event_initialized["dapui_config"] = function()
				-- vim.defer_fn(function()
				-- 	dapui.open()
				-- end, 100) -- delay in ms
				dapui.open({})
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close({})
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close({})
			end

			-- vim.api.nvim_create_autocmd("TermOpen", {
			-- 	callback = function(args)
			-- 		local bufnr = args.buf
			-- 		local buf_name = vim.api.nvim_buf_get_name(bufnr)
			-- 		if buf_name:match("dap%-repl") then
			-- 			local noremap = { noremap = true, silent = true }
			-- 			local buf_keymap = vim.api.nvim_buf_set_keymap
			-- 			buf_keymap(bufnr, "t", "<esc>", [[<c-\><c-n>]], noremap)
			-- 			buf_keymap(bufnr, "t", "<c-h>", [[<c-\><c-n><c-w>h]], noremap)
			-- 			buf_keymap(bufnr, "t", "<c-j>", [[<c-\><c-n><c-w>j]], noremap)
			-- 			buf_keymap(bufnr, "t", "<c-k>", [[<c-\><c-n><c-w>k]], noremap)
			-- 			buf_keymap(bufnr, "t", "<c-l>", [[<c-\><c-n><c-w>l]], noremap)
			-- 		end
			-- 	end,
			-- })

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "dapui_console", "dap-repl" },
				callback = function()
					local map_opts = { noremap = true, silent = true }

					-- In terminal mode (used in dap-repl)
					vim.keymap.set("t", "<esc>", [[<c-\><c-n>]], map_opts)
					vim.keymap.set("t", "<c-h>", [[<c-\><c-n><c-w>h]], opts)
					vim.keymap.set("t", "<c-j>", [[<c-\><c-n><c-w>j]], opts)
					vim.keymap.set("t", "<c-k>", [[<c-\><c-n><c-w>k]], opts)
					vim.keymap.set("t", "<c-l>", [[<c-\><c-n><c-w>l]], opts)
				end,
			})

			-- dap.listeners.after.event_stopped["dap_fix_cursor_jump"] = function()
			-- 	vim.defer_fn(function()
			-- 		local session = dap.session()
			-- 		if not session then
			-- 			return
			-- 		end
			--
			-- 		local frame = session.current_frame
			-- 		if not frame then
			-- 			return
			-- 		end
			--
			-- 		local path = frame.source and frame.source.path
			-- 		local line = frame.line or 1
			--
			-- 		if not path then
			-- 			return
			-- 		end
			--
			-- 		local bufnr = vim.fn.bufnr(path)
			-- 		if bufnr == -1 then
			-- 			vim.cmd("edit " .. vim.fn.fnameescape(path))
			-- 			bufnr = vim.fn.bufnr(path)
			-- 		end
			--
			-- 		if vim.api.nvim_buf_is_loaded(bufnr) then
			-- 			vim.api.nvim_set_current_buf(bufnr)
			-- 			local line_count = vim.api.nvim_buf_line_count(bufnr)
			-- 			local jump_line = math.min(line, line_count)
			-- 			vim.api.nvim_win_set_cursor(0, { jump_line, 0 })
			-- 		else
			-- 			vim.notify("Buffer not loaded for " .. path, vim.log.levels.ERROR)
			-- 		end
			-- 	end, 100) -- delay to allow DAP internals to catch up
			-- end

			-- dap.listeners.after.event_stopped["auto_focus_frame"] = function()
			-- 	vim.schedule(function()
			-- 		local frame = dap.session() and dap.session():current_frame()
			-- 		if not frame or not frame.source or not frame.line then
			-- 			return
			-- 		end
			--
			-- 		local path = frame.source.path
			-- 		local line = frame.line
			--
			-- 		if path and vim.fn.filereadable(path) == 1 then
			-- 			vim.cmd("edit " .. vim.fn.fnameescape(path))
			-- 			vim.api.nvim_win_set_cursor(0, { line, 0 })
			-- 			vim.cmd("normal! zz")
			-- 		end
			-- 	end)
			-- end

			-- dap.listeners.after.event_stopped["auto_focus"] = function(session, body)
			-- 	vim.schedule(function()
			-- 		local frame = body and body.frame
			-- 		if not frame then
			-- 			return
			-- 		end
			--
			-- 		local path = frame.source and frame.source.path
			-- 		local line = frame.line
			--
			-- 		if path and line then
			-- 			vim.cmd("edit " .. path)
			-- 			local bufnr = vim.fn.bufnr(path)
			-- 			local line_count = vim.api.nvim_buf_line_count(bufnr)
			--
			-- 			if line <= line_count then
			-- 				vim.api.nvim_win_set_buf(0, bufnr)
			-- 				vim.api.nvim_win_set_cursor(0, { line, 0 })
			-- 			else
			-- 				vim.notify(
			-- 					string.format("Cannot jump to line %d in %s (only %d lines)", line, path, line_count),
			-- 					vim.log.levels.WARN
			-- 				)
			-- 			end
			-- 		end
			-- 	end)
			-- end
		end,
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = "mason.nvim",
		cmd = { "DapInstall", "DapUninstall" },
		opts = {
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_installation = true,

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			handlers = {
				function(config)
					-- Apply default setup for all DAPs unless overridden
					require("mason-nvim-dap").default_setup(config)
				end,
				python = function(config)
					-- Add a custom configuration with justMyCode = false
					config.configurations = {
						{
							type = "python",
							request = "launch",
							name = "Launch file (My Code Only)",
							program = "${file}",
							justMyCode = true,
							console = "integratedTerminal",
							pythonPath = function()
								return os.getenv("VIRTUAL_ENV") and (os.getenv("VIRTUAL_ENV") .. "/bin/python")
									or "python3"
							end,
						},
						{
							type = "python",
							request = "launch",
							name = "Launch file (All Code)",
							program = "${file}",
							justMyCode = false,
							console = "integratedTerminal",
							pythonPath = function()
								return os.getenv("VIRTUAL_ENV") and (os.getenv("VIRTUAL_ENV") .. "/bin/python")
									or "python3"
							end,
						},
					}

					require("mason-nvim-dap").default_setup(config)
				end,
			},

			-- You'll need to check that you have the required things installed
			-- online, please don't ask me how to install them :)
			ensure_installed = {
				-- Update this to ensure that you have the debuggers for the langs you want
				"python",
			},
		},
		-- mason-nvim-dap is loaded when nvim-dap loads
		config = function() end,
	},
}
