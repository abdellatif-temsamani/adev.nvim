local events = require "adev.utils.consts.events"
return {
    "nvimtools/none-ls.nvim",
    event = { events.file.read_pre, events.lsp.attach, },
    config = function()
        require "adev.config.none-ls".setup()
    end
}
