return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        cmd = "Neotree",
        keys = {
            {
                "<leader>fe",
                function()
                    require("neo-tree.command").execute({ toggle = true, dir = Myutil.root() })
                end,
                desc = "Explorer NeoTree (Root Dir)",
            },
            {
                "<leader>fE",
                function()
                    require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
                end,
                desc = "Explorer NeoTree (cwd)",
            },
            { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
            { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)",      remap = true },
            {
                "<leader>ge",
                function()
                    require("neo-tree.command").execute({ source = "git_status", toggle = true })
                end,
                desc = "Git Explorer",
            },
            {
                "<leader>be",
                function()
                    require("neo-tree.command").execute({ source = "buffers", toggle = true })
                end,
                desc = "Buffer Explorer",
            },
        },
        deactivate = function()
            vim.cmd([[Neotree close]])
        end,
        -- init = function()
        --     -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
        --     -- because `cwd` is not set up properly.
        --     -- This autocmd will open Neotree when open a folder
        --     vim.api.nvim_create_autocmd("BufEnter", {
        --         group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
        --         desc = "Start Neo-tree with directory",
        --         once = true,
        --         callback = function()
        --             if package.loaded["neo-tree"] then
        --                 return
        --             else
        --                 local stats = vim.uv.fs_stat(vim.fn.argv(0))
        --                 if stats and stats.type == "directory" then
        --                     require("neo-tree")
        --                 end
        --             end
        --         end,
        --     })
        -- end,
        opts = {
            enable_git_status = true,
            enable_diagnostics = false,
            sources = { "filesystem", "buffers", "git_status" },
            open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
            event_handlers = {
                {
                    event = "file_opened",
                    handler = function()
                        require("neo-tree.command").execute({ action = "close" })
                    end,
                },
                {
                    event = "neo_tree_window_after_close",
                    handler = function(args)
                        if args.position == "left" or args.position == "right" then
                            vim.cmd("wincmd =")
                        end
                    end,
                },
                {
                    event = "neo_tree_window_after_open",
                    handler = function(args)
                        if args.position == "left" or args.position == "right" then
                            vim.cmd("wincmd =")
                        end
                    end,
                },
            },
            filesystem = {
                bind_to_cwd = false,
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
                window = {
                    position = "left",
                    mappings = {
                        ["h"] = function(state)
                            local node = state.tree:get_node()
                            if node.type == "directory" and node:is_expanded() then
                                require("neo-tree.sources.filesystem").toggle_directory(state, node)
                            else
                                require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
                            end
                        end,
                        ["l"] = function(state)
                            local node = state.tree:get_node()
                            if node.type == "directory" then
                                if not node:is_expanded() then
                                    require("neo-tree.sources.filesystem").toggle_directory(state, node)
                                elseif node:has_children() then
                                    require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
                                end
                            end
                        end,
                        ["<space>"] = "none",
                        ["Y"] = {
                            function(state)
                                local node = state.tree:get_node()
                                local path = node:get_id()
                                vim.fn.setreg("+", path, "c")
                            end,
                            desc = "Copy Path to Clipboard",
                        },
                        ["O"] = {
                            function(state)
                                require("lazy.util").open(state.tree:get_node().path, { system = true })
                            end,
                            desc = "Open with System Application",
                        },
                        ["P"] = { "toggle_preview", config = { use_float = false } },
                        ["F"] = "clear_filter",
                        -- ["/"] = "none",
                        ["s"] = "open_split",
                        ["v"] = "open_vsplit",
                        ["<c-f>"] = "none",
                        ["<c-b>"] = "none",
                        ["<esc>"] = "none",
                    },
                },
            },
            default_component_configs = {
                indent = {
                    with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
                git_status = {
                    symbols = {
                        deleted = " ",
                        unstaged = "󰄱",
                        staged = "󰱒",
                    },
                },
            },
        },
        config = function(_, opts)
            local function on_move(data)
                Myutil.lsp.on_rename(data.source, data.destination)
            end

            local events = require("neo-tree.events")
            opts.event_handlers = opts.event_handlers or {}
            vim.list_extend(opts.event_handlers, {
                { event = events.FILE_MOVED,   handler = on_move },
                { event = events.FILE_RENAMED, handler = on_move },
            })
            require("neo-tree").setup(opts)
            vim.api.nvim_create_autocmd("TermClose", {
                pattern = "*lazygit",
                callback = function()
                    if package.loaded["neo-tree.sources.git_status"] then
                        require("neo-tree.sources.git_status").refresh()
                    end
                end,
            })
        end,
    }
}
