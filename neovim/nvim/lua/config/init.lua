_G.Myutil = require("myutil")
local LazyUtil = require("lazy.core.util")

local M = {}

Myutil.config = M

local defaults = {
	defaults = {
		autocmds = true,
		keymaps = true,
	},
	icons = {
		dap = {
			Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
			Breakpoint = " ",
			BreakpointCondition = " ",
			BreakpointRejected = { " ", "DiagnosticError" },
			LogPoint = ".>",
		},
	},
	kind_filter = {
		default = {
			"Class",
			"Constructor",
			"Enum",
			"Field",
			"Function",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			"Packages",
			"Property",
			"Struct",
			"Trait",
		},
		markdown = false,
		help = false,
		lua = {
			"Class",
			"Constructor",
			"Enum",
			"Field",
			"Function",
			"Interface",
			"Method",
			"Namespace",
			"Property",
			"Struct",
			"Trait",
		},
	},
}

---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
	local function _load(mod)
		if require("lazy.core.cache").find(mod)[1] then
			LazyUtil.try(function()
				require(mod)
			end, { msg = "Failed loading " .. mod })
		end
	end
	_load("config." .. name)
	if vim.bo.filetype == "lazy" then
		-- HACK: LazyVim may have overwritten options of the Lazy ui, so reset this here
		vim.cmd([[do VimResized]])
	end

	local pattern = "Config" .. name:sub(1, 1):upper() .. name:sub(2)
	vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

local function set_g_clipboard()
	local is_ssh = (os.getenv("SSH_CONNECTION") ~= nil or os.getenv("SSH_TTY") ~= nil)
	local has_display = (os.getenv("DISPLAY") ~= nil)

	if is_ssh and has_display and vim.fn.has("mac") then
		vim.g.clipboard = {
			name = "xclip",
			copy = {
				["+"] = "xclip -selection clipboard",
				["*"] = "xclip -selection primary",
			},
			paste = {
				["+"] = "xclip -selection clipboard -o",
				["*"] = "xclip -selection primary -o",
			},
			cache_enabled = 1,
		}
	else
		-- let system choose the clipboard provider
		vim.g.clipboard = nil
	end
end

local options
local Lazy_clipboard
function M.setup(opts)
	options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

	-- autocmds can be loaded lazily when not opening a file
	local lazy_autocmds = vim.fn.argc(-1) == 0
	if not lazy_autocmds then
		M.load("autocmds")
	end

	local group = vim.api.nvim_create_augroup("LazyVim", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "VeryLazy",
		callback = function()
			-- reload the clipbaord setting
			if Lazy_clipboard ~= nil then
				vim.opt.clipboard = Lazy_clipboard
			end

			if lazy_autocmds then
				M.load("autocmds")
			end
			M.load("keymaps")

			local format = require("myutil.format")
			format.setup()

			-- local health  = require("myutil.health")
			-- vim.list_extend(health.valid, {
			-- 	"recommended",
			-- 	"desc",
			-- 	"vscode",
			-- })
		end,
	})
end

-- This will be called in plugins/init.lua
-- for loading plugins first
M.did_init = false
function M.init()
	if M.did_init then
		return
	end

	M.did_init = true
	M.load("options")

	-- defer built-in clipboard handling: "xsel" and "pbcopy" can be slow
	-- the clipboard will load at config.setup()
	-- 20251120 tested doesn't make significant different (with xclip)
	Lazy_clipboard = vim.opt.clipboard
	vim.opt.clipboard = ""

	-- the global clipboard needs to be set early
	set_g_clipboard()

	-- The lazy file will apply syntax earlier
	Myutil.lazyfile.setup()
end

setmetatable(M, {
	__index = function(_, key)
		if options == nil then
			return vim.deepcopy(defaults)[key]
		end
		return options[key]
	end,
})

return M
