local ft = {
    "rust",
    "c",
    "cpp",
    "sh",
    "bash",
    "typescript",
    "typescriptreact",
    "javascript",
    "javascriptreact",
    "python"
}

return {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    ft = ft,
    after = "mfussenegger/nvim-dap",
    dependencies = {
        {
            "mfussenegger/nvim-dap",
            ft = ft,
            config = function()
                require("abdellatifdev.dap-config").setup()
            end,
        },
        "nvim-neotest/nvim-nio",
    },
    keys = {
        { "<leader>dd", function() require("dapui").toggle() end,           desc = "Open dapui" },
        { "<leader>dn", function() require("dap").continue() end,           desc = "Continue Debugging" },
        { "<leader>do", function() require("dap").step_over() end,          desc = "Step Over" },
        { "<leader>di", function() require("dap").step_into() end,          desc = "Step Into" },
        { "<leader>dr", function() require("dap").restart() end,            desc = "Restart" },
        { "<leader>du", function() require("dap").step_out() end,           desc = "Step Out" },
        { "<leader>db", function() require("dap").toggle_breakpoint() end,  desc = "Toggle Breakpoint" },
        { "<leader>dB", function() require("dap").set_breakpoint() end,     desc = "Set Breakpoint" },
        { "<leader>dl", function() require("dap").run_last() end,           desc = "Run Last Debug Session" },
        { "<leader>dt", function() require("dap").terminate() end,          desc = "Terminate Debug Session" },
        { "<leader>dh", function() require("dap.ui.widgets").hover() end,   desc = "DAP Hover",              { "n", "v" }, },
        { "<leader>dp", function() require("dap.ui.widgets").preview() end, desc = "DAP Preview",            { "n", "v" }, },
    },
    opts = {},
}
