local ft = require("abdellatifdev.dap-config").js_based_languages
return {
    "mxsdev/nvim-dap-vscode-js",
    ft = ft,
    lazy = true,
    config = function()
        ---@diagnostic disable-next-line: missing-fields
        require("dap-vscode-js").setup({
            debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),
            adapters = {
                "chrome",
                "pwa-node",
                "pwa-chrome",
                "pwa-msedge",
                "pwa-extensionHost",
                "node-terminal",
            },
        })
    end,
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "mfussenegger/nvim-dap",
        {
            "Joakker/lua-json5",
            build = "./install.sh",
        },
        {
            "microsoft/vscode-js-debug",
            -- After install, build it and rename the dist directory to out
            build =
            "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
            version = "1.*",
        },
    }

}
