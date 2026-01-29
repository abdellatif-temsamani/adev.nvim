local fs = require "adev-files.utils.fs"

return {
    mkdir_p = fs.mkdir_p,
    create_empty_file = fs.create_empty_file,
    rm_rf = fs.rm_rf,
    rename_path = fs.rename_path,
}
