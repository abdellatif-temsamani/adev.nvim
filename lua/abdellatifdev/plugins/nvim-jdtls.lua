return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
        local config = {
            cmd = {
                'java',
                '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                '-Dosgi.bundles.defaultStartLevel=4',
                '-Declipse.product=org.eclipse.jdt.ls.core.product',
                '-Dlog.protocol=true',
                '-Dlog.level=ALL',
                '-Xmx1g',
                '--add-modules=ALL-SYSTEM',
                '--add-opens', 'java.base/java.util=ALL-UNNAMED',
                '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
                '-jar',
                '/home/flagmate/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.7.0.v20250331-1702.jar',
                '-configuration', '/home/flagmate/.local/share/nvim/mason/packages/jdtls/config_linux',
                '-data', '/home/flagmate/.local/share/java'
            },
            root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" }),
            settings = {
                java = {
                }
            },
            init_options = {
                bundles = {}
            },
        }
        require('jdtls').start_or_attach(config)
    end
}
