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
            local ret = vim.tbl_filter(
                function(client) return client.supports_method("textDocument/formatting") or client.supports_method("textDocument/rangeFormatting") end, clients)

            return vim.tbl_map(function(client)
                return client.name
            end, ret)
        end
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

return M
