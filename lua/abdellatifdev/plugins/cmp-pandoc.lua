return {
    {
        'aspeddro/cmp-pandoc.nvim',
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
        ft = { "pandoc", "markdown", "rmd", "bib" },
    },
}
