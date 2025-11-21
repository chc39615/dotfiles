--class myutil.debug
local M = {}

function M.get_loc()
	local me = debug.getinfo(1, "S")
	local level = 2
	local info = debug.getinfo(level, "S")
	while info and (info.source == me.source or info.source == "@" .. vim.env.MYVIMRC or info.what ~= "Lua") do
		level = level + 1
		info = debug.getinfo(level, "S")
	end
	info = info or me
	local source = info.source:sub(2)
	source = vim.loop.fs_realpath(source) or source
	return source .. ":" .. info.linedefined
end
---
---@param value any
---@param opts? {loc:string}
function M._dump(value, opts)
	opts = opts or {}
	opts.loc = opts.loc or M.get_loc()
	if vim.in_fast_event() then
		return vim.schedule(function()
			M._dump(value, opts)
		end)
	end
	opts.loc = vim.fn.fnamemodify(opts.loc, ":~:.")
	local msg = vim.inspect(value)
	vim.notify(msg, vim.log.levels.INFO, {
		title = "Debug: " .. opts.loc,
		on_open = function(win)
			vim.wo[win].conceallevel = 3
			vim.wo[win].concealcursor = ""
			vim.wo[win].spell = false
			local buf = vim.api.nvim_win_get_buf(win)
			if not pcall(vim.treesitter.start, buf, "lua") then
				vim.bo[buf].filetype = "lua"
			end
		end,
	})
end

function M.dump(...)
	local n = select("#", ...) -- Get the total number of arguments passed
	local inspected_values = {}

	-- Iterate from 1 up to the total count (n)
	for i = 1, n do
		local value = select(i, ...) -- Fetch the argument at the current index i

		local display_value
		if value == nil then
			display_value = "<NIL_VALUE>" -- Custom string for nil
		elseif type(value) == "string" and value == "" then
			display_value = "<EMPTY_STRING>" -- Custom string for ""
		else
			display_value = value
		end

		table.insert(inspected_values, display_value)
	end

	-- Rest of your original logic for M.dump...
	local value
	if vim.tbl_isempty(inspected_values) then
		value = nil
	else
		value = vim.islist(inspected_values) and vim.tbl_count(inspected_values) <= 1 and inspected_values[1]
			or inspected_values
	end
	M._dump(value)
end

-- function M.dump(...)
-- 	local value = { ... }
-- 	if vim.tbl_isempty(value) then
-- 		value = nil
-- 	else
-- 		value = vim.islist(value) and vim.tbl_count(value) <= 1 and value[1] or value
-- 	end
-- 	M._dump(value)
-- end

return M
