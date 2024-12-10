return {
    {
        dir = "~/programming/twitch/tree-sitter-i3config/",
        ft = {"i3config"},
        config = function()
            ---@module "i3config"
            local i3config = require("i3config")
            i3config.setup()
            i3config.debugging()
        end
    }
}
