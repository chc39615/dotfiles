vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- use swap file
opt.swapfile = true
-- swap file location
opt.dir = "/tmp"

opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }

-- line number settings
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.wrap = false

-- last window always has status line
opt.laststatus = 2
--
-- show current mode
opt.showmode = false

-- search options
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- keep 3 lines below
opt.scrolloff = 3
-- keep 10 spaces
opt.sidescrolloff = 10

-- allow <BS> <DEL> CTRL-W CTRL-U in insert mode to delete
opt.backspace = "indent,eol,start"

-- auto indent
-- opt.autoindent = true
-- opt.smartindent = true

-- a <Tab> in front of a line inserts blanks
opt.smarttab = true

-- use spaces to insert a <Tab>
opt.expandtab = true

-- (auto)indent spaces
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 0
opt.shiftround = true

-- clipboard
opt.clipboard = "unnamed,unnamedplus"
-- opt.clipboard:append("unnamedples")

-- mouse
opt.mouse = "a"

-- listchars
opt.listchars = { eol = "↵", tab = "<->", extends = "»", precedes = "«", space = "␣" }

-- autocomplete
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3 -- Hide * markup for bold and italic
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- if os is Windows, set shell=powershell
-- if jit.os == "Windows" then
--     Myutil.terminal.setup("pwsh")
-- end

-- check and setup provider.python (checkhealth python)
-- vim.g.python3_host_prog = Myutil.providers.venv_python
-- if not Myutil.providers.check_pynvim() then
--     Myutil.providers.setup_pynvim()
-- end

vim.opt.path:append({ "**" }) -- Finding files - Search down into subfolders
vim.opt.wildignore:append({ "*/node_modules/*" })
