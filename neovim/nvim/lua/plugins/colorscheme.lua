return {
    {
        "folke/tokyonight.nvim",
        lazy = true,
        opts = {
            transparent = true,
            styles = {
                sidebars = "transparent",
                floats = "transparent",
            },
        },
        init = function()
            require("tokyonight").setup({
                style = "storm",
            })
            vim.cmd.colorscheme("tokyonight")
            vim.cmd([[highlight WinSeparator guifg=orange]])
        end,
    },
}
