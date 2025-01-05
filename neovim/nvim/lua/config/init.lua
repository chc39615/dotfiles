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

local options
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
			if lazy_autocmds then
				M.load("autocmds")
			end
			M.load("keymaps")

			-- local format = require("myutil.format")
			-- format.setup()

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

    -- The lazy file will apply syntax earlier
    Myutil.lazyfile.setup()
end


return M


