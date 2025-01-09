return {
    {
        "neovim/nvim-lspconfig",
        event = "LazyFile",
        dependencies = {
			{ "williamboman/mason-lspconfig.nvim" },
            {
                "folke/lazydev.nvim",
                ft = "lua", -- only load on lua files
                opts = {
                    library = {
                        -- See the configuration section for more details
                        -- Load luvit types when the `vim.uv` word is found
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            }
        },
        opts = {},
        config = function(_, opts)

            -- local servers = opts.servers
            --
            -- local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            --
            -- local capabilities = vim.tbl_deep_extend("force",
            --     {},
            --     vim.lsp.protocol.make_client_capabilities(),
            --     has_cmp and cmp_nvim_lsp.default_capabilities() or {},
            --     opts.capabilities or {}
            -- )
            --
            -- local function setup(server)
            --     local server_opts = vim.tbl_deep_extend("force", {
            --         capabilities = vim.deepcopy(capabilities),
            --     }, servers[server] or {})
            --
            --     if opts.setup[server] then
            --         if opts.setup[server](server, server_opts) then
            --             return
            --         end
            --     end
            --     require("lspconfig")[server].setup(server_opts)
            -- end
            -- local have_mason, mlsp = pcall(require, "mason-lspconfig")
            -- local all_mslp_servers = {}
            -- if have_mason then
            --     all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
            -- end
            --
            -- local ensure_installed = {}
            -- for server, server_opts in pairs(servers) do
            --     if server_opts then
            --         server_opts = server_opts == true and {} or server_opts
            --         if server_opts.enabled ~= false then
            --             -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
            --             if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
            --                 setup(server)
            --             else
            --                 ensure_installed[#ensure_installed+1] = server
            --             end
            --         end
            --     end
            -- end
            --

            require("mason-lspconfig").setup_handlers({
                require("lspconfig").lua_ls.setup({})
            })

            -- require("lspconfig").lua_ls.setup({})
            -- require("lspconfig").stylua.setup({})
        end,

    },

    {
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts_extend = { "ensure_installed" },
		opts = {
            ui = {
                border = "single"
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
	}
}
