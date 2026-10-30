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

-- Is the terminal we're drawing on remote right now?
-- Inside tmux, ask tmux: SSH_CONNECTION in the *session* environment is refreshed on every
-- attach (update-environment), shown as "-SSH_CONNECTION" when the current client is local.
-- This stays correct in a long-lived pane that was detached and re-attached from elsewhere.
local function is_remote_now()
	if vim.env.TMUX then
		local out = vim.fn.system({ "tmux", "show-environment", "SSH_CONNECTION" })
		return vim.v.shell_error == 0 and not out:match("^%-")
	end
	return vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil
end

-- read the local system clipboard (used when the attached client is this machine)
local function local_paste()
	local cmd
	if vim.fn.has("mac") == 1 then
		cmd = { "pbpaste" }
	elseif vim.env.WAYLAND_DISPLAY and vim.fn.executable("wl-paste") == 1 then
		cmd = { "wl-paste", "--no-newline" }
	elseif vim.env.DISPLAY and vim.fn.executable("xclip") == 1 then
		cmd = { "xclip", "-selection", "clipboard", "-o" }
	end
	if not cmd then
		return nil
	end
	local text = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		return nil
	end
	local lines = vim.split(text, "\n", { plain = true })
	local regtype = "v"
	if #lines > 1 and lines[#lines] == "" then
		table.remove(lines)
		regtype = "V"
	end
	return { lines, regtype }
end

local function set_g_clipboard()
	if not (vim.env.TMUX or vim.env.SSH_CONNECTION or vim.env.SSH_TTY) then
		-- plain local terminal: let nvim pick pbcopy / wl-copy / xclip itself
		vim.g.clipboard = nil
		return
	end

	-- Copy: always OSC 52 -> tmux -> attached terminal (WezTerm) -> that machine's clipboard.
	-- Paste: WezTerm doesn't answer OSC 52 read requests, so
	--   local client  -> read the system clipboard (pbpaste ...)
	--   remote client -> fall back to the last yank; paste client text with the terminal's paste key
	local osc52 = require("vim.ui.clipboard.osc52")
	local function paste()
		if not is_remote_now() then
			local res = local_paste()
			if res then
				return res
			end
		end
		return { vim.split(vim.fn.getreg('"'), "\n", { plain = true }), vim.fn.getregtype('"') }
	end
	vim.g.clipboard = {
		name = "OSC 52",
		copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
		paste = { ["+"] = paste, ["*"] = paste },
	}
end

-- Clipboard diagnostics: if this session showed any "clipboard:" message, append it and
-- the provider state to <stdpath("state")>/clipboard-diag.log when nvim exits.
local function setup_clipboard_diag()
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = vim.api.nvim_create_augroup("ClipboardDiag", { clear = true }),
		callback = function()
			local ok, res = pcall(vim.api.nvim_exec2, "messages", { output = true })
			local msgs = ok and res.output or ""
			local hits = {}
			for line in msgs:gmatch("[^\n]+") do
				if line:lower():find("clipboard", 1, true) then
					table.insert(hits, line)
				end
			end
			if #hits == 0 then
				return
			end
			local tool = vim.g.loaded_clipboard_provider == 2
					and vim.fn["provider#clipboard#Executable"]()
				or "(none)"
			local v = vim.version()
			local cb = vim.g.clipboard
			local info = {
				os.date("%Y-%m-%d %H:%M:%S") .. "  pid " .. vim.fn.getpid(),
				("  nvim %d.%d.%d  %s  mac=%d"):format(v.major, v.minor, v.patch, vim.v.progpath, vim.fn.has("mac")),
				"  TMUX=" .. tostring(vim.env.TMUX) .. "  SSH_CONNECTION=" .. tostring(vim.env.SSH_CONNECTION),
				"  TERM=" .. tostring(vim.env.TERM) .. "  TERM_PROGRAM=" .. tostring(vim.env.TERM_PROGRAM),
				"  g:clipboard=" .. (type(cb) == "table" and tostring(cb.name) or tostring(cb))
					.. "  loaded_clipboard_provider=" .. tostring(vim.g.loaded_clipboard_provider)
					.. "  tool=" .. tostring(tool) .. "  &clipboard=" .. vim.o.clipboard,
			}
			for _, h in ipairs(hits) do
				table.insert(info, "  msg: " .. h)
			end
			table.insert(info, "")
			pcall(vim.fn.writefile, info, vim.fn.stdpath("state") .. "/clipboard-diag.log", "a")
		end,
	})
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
	-- configs for neovide
	if vim.g.neovide then
		M.load("gui")
	end

	-- defer built-in clipboard handling: "xsel" and "pbcopy" can be slow
	-- the clipboard will load at config.setup()
	-- 20251120 tested doesn't make significant different (with xclip)
	Lazy_clipboard = vim.opt.clipboard
	vim.opt.clipboard = ""

	-- the global clipboard needs to be set early
	set_g_clipboard()
	setup_clipboard_diag()

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
