local M = {}

---@param on_attach fun(client:vim.lsp.Client, buffer)
---@param name? string
function M.on_attach(on_attach, name)
	return vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local buffer = args.buf ---@type number
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			-- print(args.data.client_id .. " " .. client.name)
			if client and (not name or client.name == name) then
				return on_attach(client, buffer)
			end
		end,
	})
end

function M.get_clients(opts)
	local ret = {} ---@type vim.lsp.Client[]
	ret = vim.lsp.get_clients(opts)
	return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

function M.formatter(opts)
	opts = opts or {}
	local filter = opts.filter or {}
	filter = type(filter) == "string" and { name = filter } or filter
	local ret = {
		name = "LSP",
		primary = true,
		priority = 1,
		format = function(buf)
			M.format(Myutil.merge({}, filter, { bufnr = buf }))
		end,
		sources = function(buf)
			local clients = M.get_clients(Myutil.merge({}, filter, { bufnr = buf }))
			local ret = vim.tbl_filter(function(client)
				return client.supports_method("textDocument/formatting")
					or client.supports_method("textDocument/rangeFormatting")
			end, clients)

			return vim.tbl_map(function(client)
				return client.name
			end, ret)
		end,
	}

	return Myutil.merge(ret, opts)
end

function M.format(opts)
	opts = vim.tbl_deep_extend(
		"force",
		{},
		opts or {},
		Myutil.opts("nvim-lspconfig").format or {},
		Myutil.opts("conform.nvim").format or {}
	)
	local ok, conform = pcall(require, "conform")
	if ok then
		opts.formatters = {}
		conform.format(opts)
	else
		vim.lsp.buf.format(opts)
	end
end

---@param from string
---@param to string
---@param rename? fun()
function M.on_rename(from, to, rename)
	local changes = { files = { {
		oldUri = vim.uri_from_fname(from),
		newUri = vim.uri_from_fname(to),
	} } }

	local clients = M.get_clients()
	for _, client in ipairs(clients) do
		if client.supports_method("workspace/willRenameFiles") then
			print("support workspace/willRenameFiles")
			local resp = client.request_sync("workspace/willRenameFiles", changes, 1000, 0)
			if resp and resp.result ~= nil then
				vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
			end
		elseif client.supports_method("workspace/fileOperations/willRename") then
			print("support workspace/fileOperations/willRename")
			local resp = client.request_sync("workspace/fileOperations/willRename", changes, 1000, 0)
			if resp and resp.result ~= nil then
				vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
			end
		else
			print("not support willRename")
		end
	end

	if rename then
		rename()
	end

	for _, client in ipairs(clients) do
		if client.supports_method("workspace/didRenameFiles") then
			print("support workspace/didRenameFiles")
			client.notify("workspace/didRenameFiles", changes)
		elseif client.supports_method("workspace/fileOperations/didRename") then
			print("support workspace/fileOperations/didRename")
			client.notify("workspace/fileOperations/didRename")
		else
			print("not support didRename")
		end
	end
end

function M.get_server_config(server_name)
	local success, config = pcall(require, "plugins.lsp.servers." .. server_name)
	if not success then
		return {} -- Return empty table if the server config doesn't exist
	end
	return config
end

function M.setup_lsp_servers(opts)
	-- setup lsp servers
	local function load_server_configs()
		local servers = {}
		local config_path = vim.fn.stdpath("config") .. "/lua/plugins/lsp/servers"
		local config_files = vim.fn.globpath(config_path, "*.lua", false, true)

		for _, file in ipairs(config_files) do
			local server_name = vim.fn.fnamemodify(file, ":t:r") -- Extract filename without extension
			servers[server_name] = require("plugins.lsp.servers." .. server_name)
		end

		return servers
	end

	local servers = load_server_configs()

	local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
	local has_blink, blink = pcall(require, "blink.cmp")
	local capabilities = vim.tbl_deep_extend(
		"force",
		{},
		vim.lsp.protocol.make_client_capabilities(),
		has_cmp and cmp_nvim_lsp.default_capabilities() or {},
		has_blink and blink.get_lsp_capabilities() or {},
		opts.capabilities or {}
	)

	local function setup(server)
		local server_opts = vim.tbl_deep_extend("force", {
			capabilities = vim.deepcopy(capabilities),
		}, servers[server] or {})

		if opts.setup[server] then
			if opts.setup[server](server, server_opts) then
				return
			end
		elseif opts.setup["*"] then
			if opts.setup["*"](server, server_opts) then
				return
			end
		end
		-- require("lspconfig")[server].setup(server_opts)
		vim.lsp.config[server] = server_opts
	end

	-- get all the servers that are available through mason-lspconfig
	local have_mason, mlsp = pcall(require, "mason-lspconfig")
	local all_mslp_servers = {}
	if have_mason then
		-- all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
		all_mslp_servers = require("mason-lspconfig").get_mappings().lspconfig_to_package
	end

	local ensure_installed = {} ---@type string[]
	for server, server_opts in pairs(servers) do
		if server_opts then
			server_opts = server_opts == true and {} or server_opts
			if server_opts.enabled ~= false then
				-- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
				if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
					setup(server)
				else
					ensure_installed[#ensure_installed + 1] = server
				end
			end
		end
	end

	if have_mason then
		mlsp.setup({
			ensure_installed = vim.tbl_deep_extend(
				"force",
				ensure_installed,
				Myutil.opts("mason-lspconfig.nvim").ensure_installed or {}
			),
			handlers = { setup },
			automatic_installation = true,
		})
	end
end

M._supports_method = {}

function M.setup()
	local register_capability = vim.lsp.handlers["client/registerCapability"]
	vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
		local ret = register_capability(err, res, ctx)
		local client = vim.lsp.get_client_by_id(ctx.client_id)
		if client then
			for buffer in pairs(client.attached_buffers) do
				vim.api.nvim_exec_autocmds("User", {
					pattern = "LspDynamicCapability",
					data = { client_id = client.id, buffer = buffer },
				})
			end
		end
		return ret
	end
	M.on_attach(M._check_methods)
	M.on_dynamic_capability(M._check_methods)
end

function M._check_methods(client, buffer)
	if not vim.api.nvim_buf_is_valid(buffer) then
		return
	end

	-- don't trigger on non-listed buffers
	if not vim.bo[buffer].buflisted then
		return
	end

	-- don't trigger on nofile buffers
	if vim.bo[buffer].buftype == "nofile" then
		return
	end

	for method, clients in pairs(M._supports_method) do
		clients[client] = clients[client] or {}
		if not clients[client][buffer] then
			if client.supports_method and client.supports_method(method, { bufnr = buffer }) then
				clients[client][buffer] = true
				vim.api.nvim_exec_autocmds("User", {
					pattern = "LspSupportsMethod",
					data = { client_id = client.id, buffer = buffer, method = method },
				})
			end
		end
	end
end

function M.on_dynamic_capability(fn, opts)
	return vim.api.nvim_create_autocmd("User", {
		pattern = "LspDynamicCapability",
		group = opts and opts.group or nil,
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			local buffer = args.data.buffer ---@type number
			if client then
				return fn(client, buffer)
			end
		end,
	})
end

return M
