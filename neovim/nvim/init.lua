-- check if the vim.loader module exist
-- if yes enable.
-- The vim.loader involved in compilling and caching Lua files for faster loading
-- ## How the Neovim loader works:
-- - Compilation and caching: Neovim's loader compiles Lua files into a cache (often
--   in ~/.cache/nvim/) to speed up startup times, as Lua is faster to load after the
--   initial compilation
-- - Script loading: It's the system that runs startup scripts and plugins, including
--   Lua scripts placed in the plugin/ directory or managed by a plugin manager.
-- - Peroformance: The caching mechanism helps overcome the performance limitations of
--   the original Vimscript, making Lua an attractive scripting alternative for Neovim.
-- ## Potential Issue:
-- - Filename length: A known issue is that the compiled filenames can get too long,
--   especially when paths are long and encrypted, leading to errors.
-- - Plugin compatibility: As the loader is a core part of Neovim's Lua intergration,
--   issues can sometimes arise with specific plugins or their configurations, especially
--   in edge cases.
if vim.loader then
	vim.loader.enable()
end

-- set debug tool
_G.dd = function(...)
	require("myutil.debug").dump(...)
end
vim.print = _G.dd

-- load Lazy.nvim plugin manager
require("config.lazy")

require("config").setup()

-- current setup sequence
--
--1. init.lua
--   └── require("config.lazy")           ← loads lazy.nvim + plugin specs (call lazy.setup())
--     ↓ only continues when lazy.nvim has:
--     • Scans lua/plugins/ directory
--     • Sources plugins/init.lua
--        └── require("config").init()   ← loads vim.opt in options.lua
--     • Sources all other plugins/*.lua files (alphabetically)
--     • Collects every table you return (in the plugins/*.lua)
--     • installed missing plugins (if any)
--     • loads only the plugins that have `lazy = false`
--     • lazy.setup() returns ← STILL VERY EARLY
--
--
--   └── require("config").setup()        ← runs now, but does almost nothing
--       └── creates autocmd for "VeryLazy" ← just registers a callback
--       └── if not lazy_autocmds: M.load("autocmds") ← only if opening file
--
--2. Much later…
--   ├─ Neovim finishes startup
--   ├─ UIEnter fires
--   └─ VeryLazy event fires
--     └── VeryLazy wrapped runs:
--         • M.load("autocmds")   ← safe now
--         • M.load("keymaps")    ← safe now
--         • restore clipboard    ← safe now
--         • format.setup()       ← safe now
--       → only now are the remaining 95% of plugins loaded
--       → only now is it safe to call telescope.setup(), lspconfig setup, formatters, keymaps, etc.
--
