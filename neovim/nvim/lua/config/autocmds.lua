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

-- Auto switch input method to english
-- vim.api.nvim_create_autocmd({ "InsertLeave" }, {
-- 	group = augroup("switch_im"),
-- 	callback = function()
-- 		local sysname = vim.loop.os_uname().sysname
-- 		local is_windows = string.find(sysname:lower(), "windows")
-- 		if is_windows then
-- 			local has_im_select = vim.fn.executable("im-select.exe") == 1
-- 			if has_im_select then
-- 				vim.fn.system("im-select.exe 1033")
-- 			end
-- 		end
-- 	end,
-- })
