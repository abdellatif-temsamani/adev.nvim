return {
    {
        'aspeddro/cmp-pandoc.nvim',
        enabled = false,
        ft = { "pandoc", "markdown", "rmd", "bib" },
        opts = {
            filetypes = { "pandoc", "markdown", "bib" },
            bibliography = {
                documentation = true,
                fields = { "type", "title", "author", "year" }
            },
            crossref = { documentation = true, enable_nabla = false }
        }
    },
    {
        "jc-doyle/cmp-pandoc-references",
        enabled = false,
        ft = { "pandoc", "markdown", "rmd", "bib" },
    },
}
