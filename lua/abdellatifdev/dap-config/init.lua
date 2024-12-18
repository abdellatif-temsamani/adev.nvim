local js_based_languages = {
    "typescript",
    "javascript",
    "typescriptreact",
    "javascriptreact",
    "vue",
}


local function setup()
    local dap = require("dap")

    if vim.fn.filereadable(".vscode/launch.json") then
        local dap_vscode = require("dap.ext.vscode")
        dap_vscode.load_launchjs(nil, {
            ["pwa-node"] = js_based_languages,
            ["chrome"] = js_based_languages,
            ["pwa-chrome"] = js_based_languages,
        })
    end

    require("abdellatifdev.dap-config.adapters.c_cpp_rust").setup(dap)
    require("abdellatifdev.dap-config.adapters.bash").setup(dap)
    require("abdellatifdev.dap-config.adapters.node").setup(dap)
end

return { setup = setup, js_based_languages = js_based_languages }
