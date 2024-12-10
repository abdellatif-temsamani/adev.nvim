local function setup()
    local dap = require("dap")
    dap.set_log_level('DEBUG')

    require("abdellatifdev.dap-config.adapters.c_cpp_rust").setup(dap)
    require("abdellatifdev.dap-config.adapters.bash").setup(dap)
    require("abdellatifdev.dap-config.adapters.node").setup(dap)
end

return { setup = setup }
