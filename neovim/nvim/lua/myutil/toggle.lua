local M = {}

function M.diagnostics()
    if vim.diagnostic.is_enabled then
        enabled = vim.diagnostic.is_enabled()
    end
    enabled = not enabled

    if enabled then
        vim.diagnostic.enable()
        Myutil.info("Enabled diagnostics", { title = "Diagnostics" })
    else
        vim.diagnostic.enable(false)
        Myutil.warn("Disabled diagnostics", { title = "Diagnostics" })
    end
end

function M.option(option, silent, values)
    if values then
        if vim.opt_local[option]:get() == values[1] then
            vim.opt_local[option] = values[2]
        else
            vim.opt_local[option] = values[1]
        end
        return Myutil.info("Set " .. option .. " to " .. vim.opt_local[option]:get(), { title = "Option" })
    end

    vim.opt_local[option] = not vim.opt_local[option]:get()
    if not silent then
        if vim.opt_local[option]:get() then
            Myutil.info("Enabled " .. option, { title = "Option" })
        else
            Myutil.info("Disabled " .. option, { title = "Option" })
        end
    end
end

M._maximized = nil
--- Zoom in, out the windows.
--- it will redistribution each window equally, if there is no
--- window has winwigth, winheigh, winminwidth, winminheight
--- check the neovim help :wincmd =
---@param state boolean?
function M.maximize(state)
    if state == (M._maximized ~= nil) then
        return
    end
    if M._maximized then
        for _, opt in ipairs(M._maximized) do
            vim.o[opt.k] = opt.v
        end
        M._maximized = nil
        vim.cmd("wincmd =")
    else
        M._maximized = {}
        local function set(k, v)
            table.insert(M._maximized, 1, { k = k, v = vim.o[k] })
            vim.o[k] = v
        end
        set("winwidth", 999)
        set("winheight", 999)
        set("winminwidth", 10)
        set("winminheight", 4)
        vim.cmd("wincmd =")
    end
    -- `QuitPre` seems to be executed even if we quit a normal window, so we don't want that
    -- `VimLeavePre` might be another consideration? Not sure about differences between the 2
    vim.api.nvim_create_autocmd("ExitPre", {
        once = true,
        group = vim.api.nvim_create_augroup("lazyvim_restore_max_exit_pre", { clear = true }),
        desc = "Restore width/height when close Neovim while maximized",
        callback = function()
            M.maximize(false)
        end,
    })
end

setmetatable(M, {
    __call = function(m, ...)
        return m.option(...)
    end,
})

return M
