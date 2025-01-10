if vim.loader then
    vim.loader.enable()
end

-- _G.dd = function(...)
--     require("myutil.debug").dump(...)
-- end
-- vim.print = _G.dd

require("config.lazy")

require("config").setup()
