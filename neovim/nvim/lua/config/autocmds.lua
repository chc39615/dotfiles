local function augroup(name)
	return vim.api.nvim_create_augroup("mygroup_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- auto change working directory
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup("AutoChdir"),
	desc = "Set working directory to the folder opened with Neovim",
	callback = function()
		local argv = vim.fn.argv(0) -- Get the first argument passed to nvim
		local stats = vim.uv.fs_stat(argv)
		if stats and stats.type == "directory" then
			vim.cmd("lcd " .. argv)
		end
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"checkhealth",
		"dap-float",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.loop.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Auto switch input method: English outside insert mode, restore on InsertEnter
-- (Windows/macOS/Linux, disabled over SSH; see lua/myutil/im.lua)
Myutil.im.setup(augroup("switch_im"))

-- Ask to convert Big5 (cp950) files to UTF-8; only the buffer's fileencoding changes, nothing is written until :w
local function ask_big5_to_utf8(buf)
	local bo = vim.bo[buf]
	if bo.fileencoding ~= "cp950" or bo.buftype ~= "" or not bo.modifiable or vim.b[buf].big5_asked then
		return
	end
	vim.b[buf].big5_asked = true -- don't ask again on :e for this buffer
	-- during startup (e.g. `nvim file.txt`) wait for VeryLazy: the UI is ready (Neovide showed only the
	-- first line of the built-in inputlist) and vim.ui.select has been replaced by fzf-lua by then
	local later = vim.v.vim_did_enter == 1 and vim.schedule or function(fn)
		Myutil.on_very_lazy(function()
			vim.schedule(fn)
		end)
	end
	later(function()
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
		vim.ui.select({ "Convert to UTF-8", "Convert to UTF-8 with BOM", "Keep Big5 (cp950)" }, {
			prompt = name .. " is Big5 (cp950): ",
		}, function(_, idx)
			if not idx or idx == 3 then
				return
			end
			vim.bo[buf].fileencoding = "utf-8"
			vim.bo[buf].bomb = idx == 2
			Myutil.info("Will be saved as UTF-8" .. (idx == 2 and " with BOM" or "") .. " on :w")
		end)
	end)
end
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("big5_to_utf8"),
	callback = function(ev)
		ask_big5_to_utf8(ev.buf)
	end,
})
-- autocmds may load after the first file was read (e.g. `nvim file.txt`), so check loaded buffers too
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
	if vim.api.nvim_buf_is_loaded(buf) then
		ask_big5_to_utf8(buf)
	end
end
