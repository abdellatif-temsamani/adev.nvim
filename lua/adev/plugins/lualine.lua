local function adev_nvim()
    return [[Adev.nvim]]
end

local function macro_recording()
    local recording_register = vim.fn.reg_recording()
    if recording_register == "" then
        return ""
    else
        return "@" .. recording_register
    end
end

return {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    opts = {
        options = {
            theme = "auto",
            globalstatus = true,
            disabled_filetypes = { "NvimTree", "adev_files" },
            always_divide_middle = true,
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { macro_recording },
            lualine_c = { "branch", "diff", "diagnostics", "lsp_status" },

            lualine_x = { "selectioncount", "encoding", "filetype", "filesize", "fileformat" },
            lualine_y = {},
            lualine_z = { "location", "progress" },
        },
        tabline = {
            lualine_a = {
                {
                    "tabs",
                    mode = 0,
                },
            },
            lualine_b = {},
            lualine_c = {
                {
                    "windows",
                    disabled_buftypes = { "quickfix", "prompt" },
                },
            },
            lualine_z = { adev_nvim },
        },
        extensions = {},
    },
}
