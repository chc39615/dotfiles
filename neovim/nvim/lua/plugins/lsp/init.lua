local function setup_lsp_servers(opts)
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
        require("lspconfig")[server].setup(server_opts)
    end


    -- get all the servers that are available through mason-lspconfig
    local have_mason, mlsp = pcall(require, "mason-lspconfig")
    local all_mslp_servers = {}
    if have_mason then
        all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
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

return {

    {
        "neovim/nvim-lspconfig",
        event = "LazyFile",
        dependencies = {
            "williamboman/mason.nvim",
            { "williamboman/mason-lspconfig.nvim" },
        },
        opts = {
            diagnostics = {
                underline = true,
                update_in_insert = false,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●",
                    -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
                    -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
                    -- prefix = "icons",
                },
                severity_sort = true,
                -- signs = {
                --     text = {
                --         [vim.diagnostic.severity.ERROR] = Myutil.config.icons.diagnostics.Error,
                --         [vim.diagnostic.severity.WARN] = Myutil.config.icons.diagnostics.Warn,
                --         [vim.diagnostic.severity.HINT] = Myutil.config.icons.diagnostics.Hint,
                --         [vim.diagnostic.severity.INFO] = Myutil.config.icons.diagnostics.Info,
                --     },
                -- },
            },
            -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the inlay hints.
            inlay_hints = {
                enabled = true,
                exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
            },
            -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the code lenses.
            codelens = {
                enabled = false,
            },
            -- add any global capabilities here
            capabilities = {
                workspace = {
                    fileOperations = {
                        didRename = true,
                        willRename = true,
                    },
                },
            },
            -- options for vim.lsp.buf.format
            -- `bufnr` and `filter` is handled by the LazyVim formatter,
            -- but can be also overridden when specified
            format = {
                formatting_options = nil,
                timeout_ms = nil,
            },
            -- you can do any additional lsp server setup here
            -- return true if you don't want this server to be setup with lspconfig
            ---@type table<string, fun(server:string, opts):boolean?>
            setup = {
                -- example to setup with typescript.nvim
                -- tsserver = function(_, opts)
                --   require("typescript").setup({ server = opts })
                --   return true
                -- end,
                -- Specify * to use this function as a fallback for any server
                -- ["*"] = function(server, opts) end,
            },
        },
        config = function(_, opts)
            -- setup autoformat
            Myutil.format.register(Myutil.lsp.formatter())

            -- setup keymaps
            Myutil.lsp.on_attach(function(client, buffer)
                require("plugins.lsp.keymaps").on_attach(client, buffer)
            end)

            -- setu lsp servers
            setup_lsp_servers(opts)
        end,
    },

    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        opts_extend = { "ensure_installed" },
        opts = {
            ui = {
                border = "single",
            },
            ensure_installed = {
                "lua-language-server",
            },
        },
        ---@param opts MasonSettings | {ensure_installed: string[]}
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require("mason-registry")
            mr:on("package:install:success", function()
                vim.defer_fn(function()
                    -- trigger FileType event to possibly load this newly installed LSP server
                    require("lazy.core.handler.event").trigger({
                        event = "FileType",
                        buf = vim.api.nvim_get_current_buf(),
                    })
                end, 100)
            end)
            mr.refresh(function()
                for _, tool in ipairs(opts.ensure_installed) do
                    local p = mr.get_package(tool)
                    if not p:is_installed() then
                        p:install()
                    end
                end
            end)
        end,
    },
}
