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

---@param name string
function M.get_plugin(name)
    return require("lazy.core.config").spec.plugins[name]
end

---@param plugin string
function M.has(plugin)
    return M.get_plugin(plugin) ~= nil
end

return M
