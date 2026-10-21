vim.o.guifont = "JetBrainsMono Nerd Font:h16"

-- Option key acts as Alt so <A-j>/<A-k>/<A-v>/<A-s> keymaps work
vim.g.neovide_input_macos_option_key_is_meta = "both"

-- zoom keys
vim.g.neovide_scale_factor = 1.0
local function zoom(d)
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * d
end
-- Cmd on Mac, Ctrl on Windows
local mod = Myutil.is_win() and "C" or "D"
vim.keymap.set({ "n", "v", "i" }, "<" .. mod .. "-=>", function()
	zoom(1.1)
end)

vim.keymap.set({ "n", "v", "i" }, "<" .. mod .. "-->", function()
	zoom(1 / 1.1)
end)

vim.keymap.set({ "n", "v", "i" }, "<" .. mod .. "-0>", function()
	vim.g.neovide_scale_factor = 1.0
end)

-- right click pastes in the command line (in the TUI the terminal does this; Neovide has no terminal)
-- <C-r><C-r> inserts the clipboard literally instead of as typed keys
vim.keymap.set("c", "<RightMouse>", "<C-r><C-r>+", { desc = "Paste clipboard" })

-- bookmark folders: pick one -> cd into it -> find files there
-- stored per machine (not in dotfiles), one folder per line; edit it by hand if you like
local bookmark_file = vim.fn.stdpath("data") .. "/bookmarks.txt"
local function read_bookmarks()
	if vim.fn.filereadable(bookmark_file) == 0 then
		return { vim.fn.fnamemodify(vim.fn.stdpath("config"), ":~") }
	end
	return vim.tbl_filter(function(l)
		return l ~= ""
	end, vim.fn.readfile(bookmark_file))
end
local function write_bookmarks(list)
	vim.fn.writefile(list, bookmark_file)
end

-- add a folder (defaults to cwd; edit the path before Enter)
vim.keymap.set("n", "<leader>fa", function()
	vim.ui.input({ prompt = "Add bookmark: ", default = vim.fn.fnamemodify(vim.fn.getcwd(), ":~"), completion = "dir" }, function(dir)
		if not dir or dir == "" then
			return
		end
		dir = vim.fn.fnamemodify(vim.fn.expand(dir), ":~"):gsub("[/\\]$", "")
		local list = read_bookmarks()
		if vim.tbl_contains(list, dir) then
			return Myutil.info("Already bookmarked: " .. dir)
		end
		table.insert(list, dir)
		write_bookmarks(list)
		Myutil.info("Bookmarked: " .. dir)
	end)
end, { desc = "Add bookmark folder" })

local open_start -- defined below; ctrl-o in any picker opened from the start menu goes back to it
local back = {
	["ctrl-o"] = function()
		open_start()
	end,
}

local function pick_bookmark()
	local fzf = require("fzf-lua")
	local existing = vim.tbl_filter(function(d)
		return vim.uv.fs_stat(vim.fn.expand(d)) ~= nil
	end, read_bookmarks())
	fzf.fzf_exec(existing, {
		prompt = "Bookmarks> ",
		header = "alt-d: remove  ctrl-o: back",
		actions = {
			default = function(selected)
				local dir = vim.fn.expand(selected[1])
				vim.cmd.cd(dir)
				fzf.files({ cwd = dir, actions = back })
			end,
			-- remove the selected bookmark, then reopen the list
			["alt-d"] = function(selected)
				write_bookmarks(vim.tbl_filter(function(d)
					return d ~= selected[1]
				end, read_bookmarks()))
				Myutil.info("Removed bookmark: " .. selected[1])
				pick_bookmark()
			end,
			["ctrl-o"] = back["ctrl-o"],
		},
	})
end
vim.keymap.set("n", "<leader>fp", pick_bookmark, { desc = "Bookmark folders" })

-- start page: launched with no file (e.g. from the Dock) -> choose recent files or bookmarks
-- ponytail: fzf menu as the start page; switch to mini.starter if you want a static page
local start_menu = {
	["Recent files"] = function()
		require("fzf-lua").oldfiles({ actions = back })
	end,
	["Bookmarks"] = pick_bookmark,
}
open_start = function()
	require("fzf-lua").fzf_exec({ "Recent files", "Bookmarks" }, {
		prompt = "Start> ",
		actions = {
			default = function(selected)
				start_menu[selected[1]]()
			end,
		},
	})
end
vim.keymap.set("n", "<leader>fs", open_start, { desc = "Start menu" })

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		if vim.fn.argc(-1) == 0 and vim.api.nvim_buf_get_name(0) == "" then
			vim.schedule(open_start)
		end
	end,
})
