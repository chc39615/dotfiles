local M = {}

M._keys = nil

function M.get()
	if M._keys then
		return M._keys
	end

	local myutil = require("myutil")

	-- Define a wrapper
	local function lsp_jump(method)
		local allowed_methods = {
			definition = true,
			implementation = true,
			references = true,
			declaration = true,
			type_definition = true,
		}
		-- Validate method before returning the function
		if not allowed_methods[method] then
			vim.notify("Unsupported method: " .. method, vim.log.levels.ERROR)
			return
		end
		return function()
			local lsp_methods
			if myutil.has("fzf-lua") then
				local fzf = require("fzf-lua")
				lsp_methods = {
					definition = fzf.lsp_definitions,
					implementation = fzf.lsp_implementations,
					references = fzf.lsp_references,
					declaration = fzf.lsp_declarations,
					type_definition = fzf.lsp_typedefs,
				}
			else
				lsp_methods = {
					definition = vim.lsp.buf.definition,
					implementation = vim.lsp.buf.implementation,
					references = vim.lsp.buf.references,
					declaration = vim.lsp.buf.declaration,
					type_definition = vim.lsp.buf.type_definition,
				}
			end
			lsp_methods[method]()
		end
	end

	M._keys = {
		{ "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
		{ "gd", lsp_jump("definition"), desc = "Goto Definition", has = "definition" },
		{ "gr", lsp_jump("references"), desc = "References", nowait = true },
		{ "gI", lsp_jump("implementation"), desc = "Goto Implementation" },
		{ "gy", lsp_jump("type_definition"), desc = "Goto T[y]pe Definition" },
		{ "gD", lsp_jump("declaration"), desc = "Goto Declaration" },
		-- { "gd",         vim.lsp.buf.definition,      desc = "Goto Definition",            has = "definition" },
		-- { "gr",         vim.lsp.buf.references,      desc = "References",                 nowait = true },
		-- { "gI",         vim.lsp.buf.implementation,  desc = "Goto Implementation" },
		-- { "gy",         vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
		-- { "gD",         vim.lsp.buf.declaration,     desc = "Goto Declaration" },
		{ "K", vim.lsp.buf.hover, desc = "Hover" },
		{ "gK", vim.lsp.buf.signature_help, desc = "Signature Help", has = "signatureHelp" },
		{
			"<c-k>",
			vim.lsp.buf.signature_help,
			mode = "i",
			desc = "Signature Help",
			has = "signatureHelp",
		},
		{
			"<leader>ca",
			vim.lsp.buf.code_action,
			desc = "Code Action",
			mode = { "n", "v" },
			has = "codeAction",
		},
		{
			"<leader>cc",
			vim.lsp.codelens.run,
			desc = "Run Codelens",
			mode = { "n", "v" },
			has = "codeLens",
		},
		{
			"<leader>cC",
			vim.lsp.codelens.refresh,
			desc = "Refresh & Display Codelens",
			mode = { "n" },
			has = "codeLens",
		},
		-- { "<leader>cR", Myutil.lsp.rename_file,      desc = "Rename File",                mode = { "n" },          has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
		{ "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
		{ "<F2>", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
		-- { "<leader>cA", Myutil.lsp.action.source,    desc = "Source Action",              has = "codeAction" },
		-- {
		--     "]]",
		--     function() Myutil.lsp.words.jump(vim.v.count1) end,
		--     has = "documentHighlight",
		--     desc = "Next Reference",
		--     cond = function() return Myutil.lsp.words.enabled end
		-- },
		-- {
		--     "[[",
		--     function() Myutil.lsp.words.jump(-vim.v.count1) end,
		--     has = "documentHighlight",
		--     desc = "Prev Reference",
		--     cond = function() return Myutil.lsp.words.enabled end
		-- },
		-- {
		--     "<a-n>",
		--     function() Myutil.lsp.words.jump(vim.v.count1, true) end,
		--     has = "documentHighlight",
		--     desc = "Next Reference",
		--     cond = function() return Myutil.lsp.words.enabled end
		-- },
		-- {
		--     "<a-p>",
		--     function() Myutil.lsp.words.jump(-vim.v.count1, true) end,
		--     has = "documentHighlight",
		--     desc = "Prev Reference",
		--     cond = function() return Myutil.lsp.words.enabled end
		-- },
	}

	return M._keys
end

function M.resolve(buffer)
	local Keys = require("lazy.core.handler.keys")
	if not Keys.resolve then
		return {}
	end
	local spec = M.get()
	local clients = Myutil.lsp.get_clients({ bufnr = buffer })
	for _, client in ipairs(clients) do
		local server_config = Myutil.lsp.get_server_config(client.name)
		local maps = server_config.keys or {}
		vim.list_extend(spec, maps)
	end
	return Keys.resolve(spec)
end

function M.has(buffer, method)
	if type(method) == "table" then
		for _, m in ipairs(method) do
			if M.has(buffer, m) then
				return true
			end
		end
		return false
	end
	method = method:find("/") and method or "textDocument/" .. method
	local clients = Myutil.lsp.get_clients({ bufnr = buffer })
	for _, client in ipairs(clients) do
		if client.supports_method(method) then
			return true
		end
	end
	return false
end

function M.on_attach(_, buffer)
	local Keys = require("lazy.core.handler.keys")
	local keymaps = M.resolve(buffer)

	for _, keys in pairs(keymaps) do
		local has = not keys.has or M.has(buffer, keys.has)
		local cond = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))

		if has and cond then
			local opts = Keys.opts(keys)
			opts.cond = nil
			opts.has = nil
			opts.silent = opts.silent ~= false
			opts.buffer = buffer
			vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
		end
	end
end

return M
