local js_based_languages = {
    "typescript",
    "javascript",
    "typescriptreact",
    "javascriptreact",
    "vue",
}


local function setup()
    local dap = require("dap")

    require("abdellatifdev.dap-config.adapters.c_cpp_rust").setup(dap)
    require("abdellatifdev.dap-config.adapters.bash").setup(dap)
    require("abdellatifdev.dap-config.adapters.node").setup(dap)
    require("abdellatifdev.dap-config.adapters.php").setup(dap)
end

return { setup = setup, js_based_languages = js_based_languages }
