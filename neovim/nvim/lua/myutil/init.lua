local LazyUtil = require("lazy.core.util")
local M = {}

setmetatable(M, {
	__index = function(t, k)
		if LazyUtil[k] then
			return LazyUtil[k]
		end
		t[k] = require("myutil." .. k)
		return t[k]
	end,
})

function M.is_win()
	return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
	buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
	local ft = vim.bo[buf].filetype
	if M.kind_filter == false then
		return
	end
	if M.kind_filter[ft] == false then
		return
	end
	if type(M.kind_filter[ft]) == "table" then
		return M.kind_filter[ft]
	end
	---@diagnostic disable-next-line: return-type-mismatch
	return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

---@param name string
function M.opts(name)
	local plugin = M.get_plugin(name)
	if not plugin then
		return {}
	end
	local Plugin = require("lazy.core.plugin")
	return Plugin.values(plugin, "opts", false)
end

function M.map(mode, lhs, rhs, desc, opts)
	local keys = require("lazy.core.handler").handlers.keys
	---@cast keys LazyKeysHandler
	-- do not create the keymap if a lazy keys handler exists
	local options = { silent = true, noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end

	if desc ~= nil then
		if type(desc) == "string" then
			options.desc = desc
		else
			options = vim.tbl_extend("keep", options, desc)
		end
	end

	-- opts = opts or { silent = true, noremap = true }
	if not keys.active[keys.parse({ lhs, mode = mode }).id] then
		options.silent = options.silent ~= false
		vim.keymap.set(mode, lhs, rhs, options)
	end
end

---@generic T
---@param list T[]
---@return T[]
function M.dedup(list)
	local ret = {}
	local seen = {}
	for _, v in ipairs(list) do
		if not seen[v] then
			table.insert(ret, v)
			seen[v] = true
		end
	end
	return ret
end

function M.is_loaded(name)
	local Config = require("lazy.core.config")
	return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
function M.get_plugin(name)
	return require("lazy.core.config").spec.plugins[name]
end

---@param plugin string
function M.has(plugin)
	return M.get_plugin(plugin) ~= nil
end

---@param fn fun()
function M.on_very_lazy(fn)
	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		callback = function()
			fn()
		end,
	})
end

return M
