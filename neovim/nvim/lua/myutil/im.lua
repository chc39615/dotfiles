-- Auto switch input method: English outside insert mode, restore the previous IM on InsertEnter.
--
-- Backends (no extra install; binaries are vendored in nvim/bin):
--   Windows  bin/win/im-select.exe  (daipeihust/im-select, MIT) - switches keyboard layout, needs en-US (1033)
--   macOS    bin/mac/macism         (laishulu/macism, MIT)      - Apple Silicon build
--   Linux    fcitx5-remote / fcitx-remote / ibus from the system IM framework
-- Disabled in SSH sessions: the IME lives on the client, not on the machine running nvim.
--
-- Options (set before VeryLazy, e.g. in options.lua):
--   vim.g.im_select = false            disable entirely
--   vim.g.im_select_english = "..."    override the English IM id for this machine
--   vim.g.im_select_restore = false    stay English on InsertEnter instead of restoring
local M = {}

local bin = vim.fn.stdpath("config") .. "/bin"

---@class ImBackend
---@field name string
---@field english string
---@field get string[]
---@field set fun(id: string, to_english: boolean): string[]

---@return ImBackend?
local function detect()
	if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
		return nil
	end
	local ex = function(p)
		return vim.fn.executable(p) == 1
	end

	if Myutil.is_win() then
		local exe = bin .. "/win/im-select.exe"
		if ex(exe) then
			return {
				name = "im-select",
				english = "1033",
				get = { exe },
				set = function(id)
					return { exe, id }
				end,
			}
		end
	elseif vim.fn.has("mac") == 1 then
		local exe = bin .. "/mac/macism"
		if ex(exe) then
			return {
				name = "macism",
				english = "com.apple.keylayout.ABC",
				get = { exe },
				-- switching to a non-CJK source doesn't need macism's workaround ("0" = skip it, faster)
				set = function(id, to_english)
					return to_english and { exe, id, "0" } or { exe, id }
				end,
			}
		end
	else
		for _, r in ipairs({ "fcitx5-remote", "fcitx-remote" }) do
			if ex(r) then
				-- query prints 1 = inactive (English), 2 = active; -c deactivates, -o activates
				return {
					name = r,
					english = "1",
					get = { r },
					set = function(id)
						return { r, id == "1" and "-c" or "-o" }
					end,
				}
			end
		end
		if ex("ibus") then
			return {
				name = "ibus",
				english = "xkb:us::eng",
				get = { "ibus", "engine" },
				set = function(id)
					return { "ibus", "engine", id }
				end,
			}
		end
	end
	return nil
end

---@type ImBackend?
M.backend = nil
local saved ---@type string? IM in use when insert mode was last left
local seq = 0 -- bumped on every event so a slow query can't act on a stale state

-- async, never blocks editing; a missing/broken binary just disables the feature
local function run(cmd, cb)
	local ok = pcall(vim.system, cmd, { text = true }, cb and function(o)
		vim.schedule(function()
			cb(o)
		end)
	end)
	if not ok then
		M.backend = nil
	end
end

--- Switch to English. With `remember`, keep the current IM so enter() can restore it.
---@param remember? boolean
function M.leave(remember)
	local b = M.backend
	if not b then
		return
	end
	seq = seq + 1
	local my = seq
	run(b.get, function(o)
		if my ~= seq or o.code ~= 0 then
			return
		end
		local cur = vim.trim(o.stdout or "")
		if remember then
			saved = cur
		end
		if cur ~= b.english then
			run(b.set(b.english, true))
		end
	end)
end

--- Restore the IM that was active when insert mode was last left.
function M.enter()
	local b = M.backend
	if not b then
		return
	end
	seq = seq + 1
	if vim.g.im_select_restore ~= false and saved and saved ~= "" and saved ~= b.english then
		run(b.set(saved, false))
	end
end

---@param group integer augroup id
function M.setup(group)
	if vim.g.im_select == false then
		return
	end
	M.backend = detect()
	if not M.backend then
		return
	end
	if vim.g.im_select_english then
		M.backend.english = vim.g.im_select_english
	end

	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = function()
			M.leave(true)
		end,
	})
	vim.api.nvim_create_autocmd("InsertEnter", { group = group, callback = M.enter })
	-- coming back from another app while in normal mode: make sure keys are commands, not IME input
	vim.api.nvim_create_autocmd("FocusGained", {
		group = group,
		callback = function()
			if not vim.fn.mode():find("^[iR]") then
				M.leave(false)
			end
		end,
	})
end

return M
