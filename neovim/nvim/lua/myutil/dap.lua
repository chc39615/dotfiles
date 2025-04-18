--class myutil.debug
local M = {}

-- rewrite the DapEval
local api = vim.api

function M.bufread_eval()
	local bufnr = api.nvim_get_current_buf()
	local fname = api.nvim_buf_get_name(bufnr)
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].buftype = "acwrite"
	vim.bo[bufnr].bufhidden = "wipe"
	local ft = fname:match("dap%-eval://(%w+)(.*)")
	if ft and ft ~= "" then
		vim.bo[bufnr].filetype = ft
	else
		local altbuf = vim.fn.bufnr("#", false)
		if altbuf then
			vim.bo[bufnr].filetype = vim.bo[altbuf].filetype
		end
	end
	api.nvim_create_autocmd("BufWriteCmd", {
		buffer = bufnr,
		callback = function(args)
			vim.bo[args.buf].modified = false
			local repl = require("dap.repl")
			local lines = api.nvim_buf_get_lines(args.buf, 0, -1, true)
			repl.execute(table.concat(lines, "\n"))

			-- Check if a DAP REPL buffer already exists
			local repl_exists = false
			for _, buf in ipairs(api.nvim_list_bufs()) do
				if api.nvim_buf_is_loaded(buf) then
					local buf_name = api.nvim_buf_get_name(buf)
					local buf_filetype = vim.bo[buf].filetype
					if buf_name:match("DAP REPL") or buf_filetype == "dap-repl" then
						repl_exists = true
						break
					end
				end
			end

			-- Open REPL only if it doesn't exist
			if not repl_exists then
				repl.open()
			end
		end,
	})
end

-- Create a new dap-readcmds augroup and register the new BufReadCmd autocommand
api.nvim_create_autocmd("BufReadCmd", {
	group = api.nvim_create_augroup("dap-readcmds", { clear = true }),
	pattern = "dap-eval://*",
	callback = function()
		M.bufread_eval()
	end,
})

-- toggle dap-eval
function M.toggle_eval_buffer(opts)
	opts = opts or { smods = { vertical = false, tab = 0 }, range = 0, bang = false }

	-- Find a dap-eval://* buffer
	local eval_buf = nil
	for _, buf in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_is_loaded(buf) then
			local buf_name = api.nvim_buf_get_name(buf)
			if buf_name:match("^dap%-eval://") then
				eval_buf = buf
				break
			end
		end
	end

	if eval_buf then
		-- Buffer exists, check if it's visible
		local is_visible = false
		local eval_win = nil
		for _, win in ipairs(api.nvim_list_wins()) do
			if api.nvim_win_get_buf(win) == eval_buf then
				is_visible = true
				eval_win = win
				break
			end
		end

		if is_visible then
			-- Buffer is visible, hide it by closing its window
			api.nvim_win_close(eval_win, false)
		else
			-- Buffer is hidden, show it with the specified modifiers
			local buf_name = api.nvim_buf_get_name(eval_buf)
			if opts.smods.vertical then
				vim.cmd.vsplit(buf_name)
			elseif opts.smods.tab == 1 then
				vim.cmd.tabedit(buf_name)
			else
				local size = opts.smods.split or math.max(5, math.floor(vim.o.lines * 1 / 5))
				vim.cmd.split({ args = { buf_name }, range = { size } })
			end
		end
	else
		-- No dap-eval buffer exists, create a new one using dap._cmds.eval
		require("dap._cmds").eval(opts)
	end
end

-- Create a user command to toggle or create the dap-eval buffer, passing opts directly
api.nvim_create_user_command("DapEvalToggle", function(opts)
	M.toggle_eval_buffer(opts)
end, {
	nargs = 0,
	range = true,
	bang = true,
	bar = true,
	desc = "Toggle visibility of the dap-eval buffer or create a new one with optional range and modifiers",
})

-- Updated eval_selection to use DapEval-style dedentation
function M.eval_selection(opts)
	opts = opts or { range = 0, line1 = vim.fn.line("."), line2 = vim.fn.line(".") }

	-- Get the selected lines based on range
	local line1 = opts.line1 or vim.fn.line(".")
	local line2 = opts.line2 or vim.fn.line(".")
	if opts.range == 0 then
		-- No range, use current line
		line1 = vim.fn.line(".")
		line2 = line1
	end
	local lines = api.nvim_buf_get_lines(0, line1 - 1, line2, true)

	-- Dedent the lines (DapEval-style)
	local indent = math.huge
	for _, line in ipairs(lines) do
		indent = math.min(line:find("[^ ]") or math.huge, indent)
	end
	if indent ~= math.huge and indent > 0 then
		for i, line in ipairs(lines) do
			lines[i] = line:sub(indent)
		end
	end
	local text = table.concat(lines, "\n")

	-- Send to REPL
	local repl = require("dap.repl")
	repl.execute(text)

	-- Find the REPL buffer
	local repl_buf = nil
	for _, buf in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_is_loaded(buf) then
			local buf_name = api.nvim_buf_get_name(buf)
			local buf_filetype = vim.bo[buf].filetype
			if buf_name:match("DAP REPL") or buf_filetype == "dap-repl" then
				repl_buf = buf
				break
			end
		end
	end

	-- Open REPL if it doesn't exist
	if not repl_buf then
		repl.open()
		-- Find the newly opened REPL buffer
		for _, buf in ipairs(api.nvim_list_bufs()) do
			if api.nvim_buf_is_loaded(buf) then
				local buf_name = api.nvim_buf_get_name(buf)
				local buf_filetype = vim.bo[buf].filetype
				if buf_name:match("DAP REPL") or buf_filetype == "dap-repl" then
					repl_buf = buf
					break
				end
			end
		end
	end
end

-- Create user command for sending selection to DAP REPL
api.nvim_create_user_command("DapEvalSelection", function(opts)
	M.eval_selection(opts)
end, {
	nargs = 0,
	range = true,
	desc = "Send selected lines to DAP REPL and auto-indent",
})

return M
