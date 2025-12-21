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
            theme = "auto",
            globalstatus = true,
            disabled_filetypes = { "NvimTree" },
            always_divide_middle = true,
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
        },
        sections = {
            lualine_a = { "mode", "branch" },
            lualine_b = { macro_recording },
            lualine_c = { "diff", "diagnostics" },
            lualine_x = { "selectioncount", "encoding", "filetype" },
            lualine_z = { "filesize", "location", "progress" },
        },
        winbar = {
            lualine_b = {
                "filename",
            },
            lualine_y = {
                "filetype",
            },
        },
        tabline = {
            lualine_a = {
                {
                    "tabs",
                    mode = 0,
                },
            },
            lualine_z = { adev_nvim },
        },
        extensions = {},
    },
}
