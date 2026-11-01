return {

    {
        "saghen/blink.cmp",
        -- optional: provides snippets for the snippet source
        dependencies = "rafamadriz/friendly-snippets",

        -- use a release tag to download pre-built binaries
        version = "*",
        -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = 'cargo build --release',
        -- If you use nix, you can build from source using latest nightly rust with:
        -- build = 'nix run .#build-plugin',

        ---@module 'blink.cmp'
        ---@type function|blink.cmp.Config
        opts = function(_, opts)
            opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
                default = { "lsp", "path", "snippets", "buffer" },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority
                        score_offset = 100,
                    },
                },
            })

            opts.keymap = {
                preset = "default",
                ["<up>"] = { "select_prev", "fallback" },
                ["<down>"] = { "select_next", "fallback" },
                ["<cr>"] = { "accept", "fallback" },

                -- ["<C-e>"] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
            }

            opts.completion = {
                list = {
                    selection = {
                        preselect = false,
                        auto_insert = function(ctx)
                            return ctx.mode == "cmdline"
                        end,
                    },
                },

                ghost_text = {
                    enabled = true,
                },
            }

            opts.appearance = {
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                use_nvim_cmp_as_default = true,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
            }

            -- cmdline completion: only up/down navigate the list; Enter selects without executing
            opts.cmdline = vim.tbl_deep_extend("force", opts.cmdline or {}, {
                keymap = {
                    preset = "cmdline",
                    ["<Up>"] = { "select_prev", "fallback" },
                    ["<Down>"] = { "select_next", "fallback" },
                    ["<Tab>"] = { "select_and_accept", "fallback" },
                    ["<S-Tab>"] = {
                        function(cmp)
                            if cmp.is_menu_visible() then
                                cmp.select_prev()
                                cmp.accept()
                                return true
                            end
                        end,
                        "fallback",
                    },
                    ["<Right>"] = { "fallback" },
                    ["<Left>"] = { "fallback" },
                    ["<Esc>"] = {
                        function(cmp)
                            if cmp.is_menu_visible() then
                                cmp.hide()
                                return true
                            end
                        end,
                        "fallback",
                    },
                },
                completion = {
                    list = {
                        selection = {
                            preselect = true,
                            auto_insert = false,
                        },
                    },
                    menu = {
                        auto_show = true,
                    },
                },
            })

            return opts
        end,

        opts_extend = { "sources.default" },
    },
}
