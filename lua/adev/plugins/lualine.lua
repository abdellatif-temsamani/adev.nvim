local function adev_nvim()
    return [[Adev.nvim]]
end

local function macro_recording()
    local recording_register = vim.fn.reg_recording()
    if recording_register == "" then
        return ""
    else
        return "Recording @" .. recording_register
    end
end

return {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    opts = {
        options = {
            theme = "catppuccin-mocha",
            globalstatus = true,
            disabled_filetypes = { "NvimTree" },
            always_divide_middle = true,
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
        },
        sections = {
            lualine_a = { "mode", "branch" },
            lualine_b = { macro_recording },
            lualine_c = { "branch", "diff", "diagnostics" },
            lualine_x = { "selectioncount", "encoding", "filetype" },
            lualine_y = {},
            lualine_z = { "filesize", "location", "progress" },
        },
        winbar = {
            lualine_c = {
                "filename",
            },
        },
        tabline = {
            lualine_a = {
                {
                    "tabs",
                    mode = 4,
                    max_length = vim.o.columns / 2,
                },
            },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = { adev_nvim },
        },
        extensions = {},
    },
}
