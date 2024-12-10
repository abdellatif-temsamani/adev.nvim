local function setup(dap)
    dap.adapters.firefox = {
        type = 'executable',
        command = '/home/flagmate/.local/share/nvim/mason/bin/firefox-debug-adapter',
    }

    require("dap").adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
            command = "node",
            args = { "/home/flagmate/apps/vscode-js-debug/src/dapDebugServer.js", "${port}" },
        }
    }


    dap.configurations.typescript = {
        {
            type = 'pwa-node',
            request = 'launch',
            name = "Launch file",
            runtimeExecutable = "deno",
            runtimeArgs = {
                "run",
                "--inspect-wait",
                "--allow-all"
            },
            program = "${file}",
            cwd = "${workspaceFolder}",
            attachSimplePort = 9229,
        },
        {
            name = 'Debug with Firefox',
            type = 'firefox',
            request = 'launch',
            reAttach = true,
            url = 'http://localhost:3000',
            webRoot = '${workspaceFolder}',
            firefoxExecutable = '/usr/bin/firefox-developer-edition'
        }
    }

    dap.configurations.javascriptreact = { -- change this to javascript if needed
        {
            name = 'Debug with Firefox',
            type = 'firefox',
            request = 'launch',
            reAttach = true,
            url = 'http://localhost:3000',
            webRoot = '${workspaceFolder}',
            firefoxExecutable = '/usr/bin/firefox-developer-edition'
        }
    }

    dap.configurations.typescriptreact = dap.configurations.javascriptreact
    dap.configurations.javascript = dap.configurations.typescript
end
return { setup = setup }
