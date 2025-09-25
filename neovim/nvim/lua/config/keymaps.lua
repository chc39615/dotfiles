local map = Myutil.map

-- better up/down
map("n", "j", "v:count == 0 ? 'gj' : 'j'", nil, { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", nil, { expr = true, silent = true })

-- force navigate
-- map("n", "j", "<c-d>")
-- map("n", "k", "<c-u>")
-- map("n", "h", "10zh")
-- map("n", "l", "10zl")

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- split window
map("n", "<A-v>", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<A-s>", "<cmd>split<cr>", { desc = "Horizontal split" })

-- zoom window
map("n", "<leader>uwi", "<c-w>_<c-w>|", { desc = "Zoom in current window" })
map("n", "<leader>uwo", "<c-w>=", { desc = "Zoom out current window" })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- buffers
if Myutil.has("bufferline.nvim") then
	-- map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
	-- map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
	map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
	map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
else
	-- map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
	-- map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
	map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
	map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
end
map("n", "<leader>bb", "<cmd>b#<cr>", { desc = "Switch to Other Buffer" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Clear search, diff update and redraw
-- take from runtime/lua/_editor.lua
map(
	"n",
	"<leader>ur",
	"<cmd>nohlsearch<bar>diffupdate<bar>normal! <C-L><cr>",
	{ desc = "redraw /clear helsearch / diff update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map({ "n", "x", "o" }, "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map({ "n", "x", "o" }, "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ":", ":<c-g>u")

-- save file
-- map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

if not Myutil.has("trouble.nvim") then
	map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
	map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })
end

-- toggle options
-- map("n", "<leader>uf", require("lsp.format").toggle, { desc = "Toggle format on Save" })
map("n", "<leader>us", function()
	Myutil.toggle("spell")
end, { desc = "Toggle Spelling" })
map("n", "<leader>up", function()
	Myutil.toggle("wrap")
end, { desc = "Toggle Word Wrap" })
map("n", "<leader>ul", function()
	Myutil.toggle("list")
end, { desc = "Toggle list" })
map("n", "<leader>ud", Myutil.toggle.diagnostics, { desc = "Toggle Diagnostics" })
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map("n", "<leader>uc", function()
	Myutil.toggle("conceallevel", false, { 0, conceallevel })
end, { desc = "Toggle Conceal" })

-- highlights under cursor
-- if vim.fn.has("nvim-0.9.0") == 1 then
--     map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
-- end

-- scroll screen horizontal
map("n", "zl", "10zl", { desc = "Move screen right" })
map("n", "zh", "10zh", { desc = "Move screen left" })

-- scrolling remap
-- map("n", "<c-d>", "<c-d>zz")
-- map("n", "<c-u>", "<c-u>zz")

-- insert tab
map("i", "<S-Tab>", "<c-v><Tab>", { desc = "insert Tab" })

-- go to the last character of the previously yanked text
map("v", "y", "y`]", { desc = "better yank" })

-- change directory
-- map('n', '<leader>cd', ":lcd %:p:h<cr>:pwd<cr>", { desc = "change directory to current file path" })

-- diagnostic
local diagnostic_goto = function(next, severity)
	-- local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	local go = next and vim.diagnostic.get_next or vim.diagnostic.get_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end

local function open_diagnostic_and_focus()
	local _, winid = vim.diagnostic.open_float()
	-- print("winid: " .. winid)
	if winid and vim.api.nvim_win_is_valid(winid) then
		vim.api.nvim_set_current_win(winid)
	end
end
-- map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>cd", open_diagnostic_and_focus, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- quickfix list
local function quickfix_is_open()
	local quickfix_open = false
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype == "quickfix" then
			quickfix_open = true
			break
		end
	end
	return quickfix_open
end
map("n", "<leader>qo", function()
	local quickfix_open = quickfix_is_open()
	if not quickfix_open then
		vim.cmd("copen")
		-- Jump back to the original window
		-- vim.cmd("wincmd p")
	end
end, { desc = "open quickfix", noremap = true, silent = true })
map("n", "<leader>qc", function()
	local quickfix_open = quickfix_is_open()
	if quickfix_open then
		vim.cmd("cclose")
	end
end, { desc = "close quickfix", noremap = true, silent = true })
map("n", "<leader>qa", function()
	-- check if current buffer is quickfix
	if vim.bo.buftype == "quickfix" then
		return
	end
	-- Send current line to quickfix
	local line = vim.api.nvim_get_current_line()
	local fname = vim.api.nvim_buf_get_name(0)
	local lnum = vim.api.nvim_win_get_cursor(0)[1]
	vim.fn.setqflist({ { filename = fname, lnum = lnum, text = line } }, "a")

	local quickfix_open = quickfix_is_open()
	if not quickfix_open then
		-- Open quickfix window
		vim.cmd("copen")
		-- Jump back to the original window
		vim.cmd("wincmd p")
	end
end, { desc = "add current line to quickfix", noremap = true, silent = true })
map("n", "<leader>qs", function()
	-- get the current quickfix list
	local qf_list = vim.fn.getqflist()
	if #qf_list == 0 then
		Myutil.warn("Quickfix list is empty")
		return
	end

	-- Sort by filename and line number as secondary key for same filenames
	table.sort(qf_list, function(a, b)
		local fname_a = vim.fn.bufname(a.bufnr) or ""
		local fname_b = vim.fn.bufname(b.bufnr) or ""
		if fname_a == fname_b then
			return a.lnum < b.lnum
		end
		return fname_a < fname_b
	end)
	-- alternative: Sort by text (uncomment to use)
	-- table.sort(qf_list, function(a, b)
	--     return a.text < b.text
	-- end)

	-- Update the quickfix list
	vim.fn.setqflist(qf_list, "r")

	-- Refresh the quickfix window if open
	if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
		vim.cmd("copen")
		vim.cmd("wincmd p") -- Return to previous window
	end
end, { desc = "sort quickfix", noremap = true, silent = true })
