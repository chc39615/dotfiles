return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 500
        end,
        opts = {
            plugins = { spelling = true },
        },
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)


            local keymaps = {


                mode = { "n", "v" },
                { "<leader>c", group = "lsp" },
                { "]", group = "next" },
                { "[", group = "prev" },
                { "<leader><tab>", group = "tabs" },
                { "<leader>s", group = "messages" },
                { "<leader>b", group = "buffers", expand = function()
                return require("which-key.extras").expand.buf() end},
                { "<leader>f", group = "file/find" },
                { "<leader>F", group = "file/find(current word)" },
                { "<leader>g", group = "surround" },
                { "<leader>x", group = "diagnostics/quickfix" },
                { "<leader>g", group = "git" },
                { "g", group = "goto" },
                { "<leader>q", group = "quit/session" },
                { "<leader>u", group = "ui" },
                { "<leader>uw", group = "windows" },

            }

            if Myutil.has("noice.nvim") then
                table.insert(keymaps, { "<leader>sn", group = "noice" })
            end

            if Myutil.has("iron.nvim") then
                table.insert(keymaps, { "<leader>r", group = "irons" })
            end

            wk.add(keymaps)

        end
    }
}
