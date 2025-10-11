local consts = {
    ignored_files = {
        "Cargo.lock",
        "__pycache__/",
        "node_modules/",
        ".git/",
        ".ccls-cache/",
        "build/",
        "target/",
        "dist/",
        "yarn.lock",
        "pnpm-lock.yaml",
        "lazy-lock.json",
    },
}

return consts
