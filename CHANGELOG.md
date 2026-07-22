# Adev.nvim Changelog

> Release history and notable changes for the over-engineered Neovim distribution.

[Latest release](https://github.com/abdellatif-temsamani/adev.nvim/releases/latest) · [All releases](https://github.com/abdellatif-temsamani/adev.nvim/releases) · [Report an issue](https://github.com/abdellatif-temsamani/adev.nvim/issues/new)

> [!NOTE]
> This file is generated automatically from conventional commits using [git-cliff](https://git-cliff.org). Do not edit it manually.

---
## [2.1.1](https://github.com/abdellatif-temsamani/adev.nvim/releases/tag/v2.1.1) · 2026-07-22
> 10 changes


### Features

- `2026-07-20` · **`adev-files`** · &lt;leader&gt;nj/k jump to next/prev modification ([`9a19279`](https://github.com/abdellatif-temsamani/adev.nvim/commit/9a1927944c785346667e0e10b0efe353233ec45b))
- `2026-07-22` · **`adev-files`** · Replace netrw directory buffers ([`0e24467`](https://github.com/abdellatif-temsamani/adev.nvim/commit/0e2446741fd2848593f84c8e38f98a3d9898518d))
- `2026-07-22` · **`adev-files`** · Polish virtual header ([`ff67e3a`](https://github.com/abdellatif-temsamani/adev.nvim/commit/ff67e3a364cbf2161caa12c65f4d0fc31fce8735))
- `2026-07-22` · **`adev-files`** · Promote to core file manager ([`a02cded`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a02cdedaad37fdfd3fbcd0566656b6d6f06375e9))
- `2026-07-22` · **`changelog`** · Add commit dates and chronological ordering ([`ddca3c7`](https://github.com/abdellatif-temsamani/adev.nvim/commit/ddca3c7a05b646c95c1b0fd9c429146a41c163d2))

### Bug fixes

- `2026-07-20` · **`adev-files`** · Footer undo, utf-8 line parse, and TextChangedP cleanup ([`0e9df82`](https://github.com/abdellatif-temsamani/adev.nvim/commit/0e9df822c74a2acdfa26ab5b56a977b92b54abae))
- `2026-07-22` · **`adev-files`** · Make filesystem batches transactional ([`4680b91`](https://github.com/abdellatif-temsamani/adev.nvim/commit/4680b91654c989546ccb75e670b0a987f63c6a52))
- `2026-07-22` · **`adev-files`** · Close confirmation windows ([`4fdfd9e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/4fdfd9e43d450b6dd204f830a2ab4807ed30d62b))
- `2026-07-22` · **`adev-files`** · Disable global actions in netrw mode ([`99908f8`](https://github.com/abdellatif-temsamani/adev.nvim/commit/99908f860a33923b4a4955043d2cd74543d49dcb))
- `2026-07-22` · **`adev-files`** · Avoid overwrite prompt after rename ([`17726f6`](https://github.com/abdellatif-temsamani/adev.nvim/commit/17726f61190121aa1f5b9b3b7d6028759ffc271b))

---
## [2.1.0](https://github.com/abdellatif-temsamani/adev.nvim/releases/tag/v2.1.0) · 2026-07-20
> 37 changes


### Features

- `2026-02-04` · **`laravel`** · Improve plugin config ([`c57297d`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c57297da0ba334c7e6964ad41004559e4f63ac15))
- `2026-04-08` · Configure core plugins ([`bb8e988`](https://github.com/abdellatif-temsamani/adev.nvim/commit/bb8e9883dcc496795d0f22c6f838fb453ecaea17))
- `2026-07-19` · **`adev-files`** · Improve UI/UX — header, expand indicator, separator, footer, hidden toggle and fixes ([`638cd6b`](https://github.com/abdellatif-temsamani/adev.nvim/commit/638cd6b7989846dd389714ec88fc85dd09a309af))
- `2026-07-19` · **`adev-files`** · Multi-file selection with TAB toggle, pipe-delimited labels, color highlights ([`49b9aa9`](https://github.com/abdellatif-temsamani/adev.nvim/commit/49b9aa9ddab9e5d62dacdca5b93229f91138e929))
- `2026-07-20` · **`adev-files`** · Git status indicators with per-status suffix colors ([`154a382`](https://github.com/abdellatif-temsamani/adev.nvim/commit/154a38223976bdb15fcddda5ec339c1154765191))

### Bug fixes

- `2026-02-01` · **`adev-files`** · File sync ([`416529c`](https://github.com/abdellatif-temsamani/adev.nvim/commit/416529cde8cf58a4f62e86004a80029569c872c4))
- `2026-02-01` · Harden window close handling in navigation quit ([`de5986f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/de5986ff5be41c061a5909fea41a530eb53f7eb4))
- `2026-02-15` · **`snacks`** · Disable file-manager ([`c19afca`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c19afca015228a7d6825a8e048dfee88f9bff104))
- `2026-02-15` · **`mason`** · Add missing package ([`edad713`](https://github.com/abdellatif-temsamani/adev.nvim/commit/edad713614a39a0725b1f91b216e6e9ce443142c))
- `2026-02-16` · **`blink-cmp`** · Remove blink-calc ([`e805019`](https://github.com/abdellatif-temsamani/adev.nvim/commit/e8050198bc4b49fcb9c136384e99163126e96a55))
- `2026-03-13` · Theme defaults ([`c57a7e8`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c57a7e85615ec06c6fb6c87be37cc709012f5109))
- `2026-05-13` · **`update`** · Handle tag fetch failures and branch cleanup ([`7214ce7`](https://github.com/abdellatif-temsamani/adev.nvim/commit/7214ce7b244a52d5fca6621dc06d49e37f6e3ed4))
- `2026-05-13` · Address Lua review findings ([`8b63be3`](https://github.com/abdellatif-temsamani/adev.nvim/commit/8b63be35a238d436262141db8a5f20a763cff222))
- `2026-05-13` · Harden adev-files path handling ([`94dc847`](https://github.com/abdellatif-temsamani/adev.nvim/commit/94dc8470fac713f688a09ddecb18dfe370436707))
- `2026-07-19` · **`adev-files`** · Jump cursor to current buffer file on open and to created files after write ([`fea7058`](https://github.com/abdellatif-temsamani/adev.nvim/commit/fea7058f69e925e41ca8ef70290f3efae4899a90))
- `2026-07-19` · **`adev-files`** · Fix 12 bugs across the plugin ([`1b1a884`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1b1a884f92ba526a5a17a2673cf5fa373ff884fb))
- `2026-07-19` · Harden lua modules across adev, adev-common, and plugins ([`ab956eb`](https://github.com/abdellatif-temsamani/adev.nvim/commit/ab956ebbfe1a431ca9de0fbeee9465fe893f12b1))
- `2026-07-19` · **`adev-files`** · Clear clipboard on reset/revert to remove stale markers ([`fcebca3`](https://github.com/abdellatif-temsamani/adev.nvim/commit/fcebca3e76589ed27ab9c925c6ec3182bd80f321))
- `2026-07-19` · **`adev-files`** · Match original entries by abs_path instead of row index ([`a6a99ac`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a6a99ac35add655e421687481e3891651183baf2))
- `2026-07-20` · **`adev-files`** · Handle pending delete ops in revert_current_line ([`10cac01`](https://github.com/abdellatif-temsamani/adev.nvim/commit/10cac01043760b771dfb5ca98f2abf6772013874))
- `2026-07-20` · **`adev-files`** · Handle directories in global commands and planner matching ([`8816013`](https://github.com/abdellatif-temsamani/adev.nvim/commit/881601340f786ece3bb06ad0702b283ff3355b2b))

### Other changes

- `2026-06-14` · **`lsp`** · Remove pyright support ([`6228c78`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6228c784d7484f7df22db7ed75c1bee738f4efbc))

### Refactoring

- `2026-02-04` · **`adev-files`** · Unify sync ([`1e348d4`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1e348d44d98722dda2228cec2fae6b7a996103b4))
- `2026-02-04` · **`adev-files`** · Rewrite ([`fb20dfe`](https://github.com/abdellatif-temsamani/adev.nvim/commit/fb20dfe0b1d969a553ab00e7c39058dc5c81b9a5))
- `2026-02-15` · **`adev-files`** · Sensible defaults ([`2a92b49`](https://github.com/abdellatif-temsamani/adev.nvim/commit/2a92b491144062550fa6083de1a466508af35c02))
- `2026-04-08` · Use adev.update directly ([`1769eaa`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1769eaa81a2630315269cfe331d1ddcd448c3128))
- `2026-04-08` · **`lsp`** · Simplify capability and path setup ([`88046fa`](https://github.com/abdellatif-temsamani/adev.nvim/commit/88046fad019ce5340ab4aca11b6f1e28a840ee52))
- `2026-05-13` · Deduplicate Lua config helpers ([`c2a382c`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c2a382c3cb027e75a37aa1699fc3f0c5d6772554))
- `2026-07-19` · **`adev-files`** · Line-based change detection, keymaps, and paste fixes ([`f5b668d`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f5b668d6e01a2e3987affd4f5210fc08ab2b0004))
- `2026-07-19` · **`adev-files`** · Keymap prefix, delete via pending ops, clipboard source labels ([`0c4ee60`](https://github.com/abdellatif-temsamani/adev.nvim/commit/0c4ee6031db3cb29623df4739e1bca92d96e71c1))

### Documentation

- `2026-07-19` · Update docs ([`b77bebf`](https://github.com/abdellatif-temsamani/adev.nvim/commit/b77bebf7bbbe95e216c2a6bb7eee39a4d732b42e))

### Plugins

- `2026-02-03` · **`"markdown"`** · Add render-markdown ([`a66e8ac`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a66e8ac542bb9ab53718eea106fb7cf218a83777))
- `2026-02-05` · **`lspconfig`** · Add timeout to vim format ([`c308385`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c308385bd8fd439469547e021ff7e92bbace7fc1))
- `2026-02-11` · **`markdown`** · Switched tj present ([`7f7418c`](https://github.com/abdellatif-temsamani/adev.nvim/commit/7f7418cc0edcc35ce5a3daed092be30664555c31))
- `2026-02-26` · **`snacks`** · Disable image preview ([`88dd7a2`](https://github.com/abdellatif-temsamani/adev.nvim/commit/88dd7a2d6c668d4dcc9c19c5b26b73923668b983))
- `2026-04-10` · Undotree ([`52e031c`](https://github.com/abdellatif-temsamani/adev.nvim/commit/52e031c8fcb7079ff54b0b953ce51450391ee8a3))

### Maintenance

- `2026-05-13` · Funding ([`da7dc92`](https://github.com/abdellatif-temsamani/adev.nvim/commit/da7dc929020de727d31e5be2ede482566f9319d8))

---
## [2.0.5-1](https://github.com/abdellatif-temsamani/adev.nvim/releases/tag/v2.0.5-1) · 2026-01-31
> 29 changes


### Features

- `2026-01-23` · **`plugins`** · Mdx filetype support ([`10fb18a`](https://github.com/abdellatif-temsamani/adev.nvim/commit/10fb18a22694f48ed95b9c45ba62ffb14079cdb7))
- `2026-01-25` · **`adev-files`** · Structuring core plugin ([`f4652de`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f4652decc07083948f1d832dcd3e4a3d297f5e40))
- `2026-01-26` · **`adev`** · Major refactor of file manager and UI infrastructure ([`34ee527`](https://github.com/abdellatif-temsamani/adev.nvim/commit/34ee527558d8e2c276a185b02be3df096693f05a))
- `2026-01-29` · Adev-files ([`27ddcf3`](https://github.com/abdellatif-temsamani/adev.nvim/commit/27ddcf38afa07227a6bc6ce51124cb854d2060be))
- `2026-01-29` · **`adev-files`** · Mini-icons support ([`8aa3b8d`](https://github.com/abdellatif-temsamani/adev.nvim/commit/8aa3b8db557cd349fb46dc8040f4da8607eabfe3))
- `2026-01-29` · **`adev-files`** · Opening files ([`6f1b3d3`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6f1b3d3116ae69fdf9907e7c30556035b6fa3ba0))
- `2026-01-29` · **`core`** · Lazy laoding ([`6bb26e4`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6bb26e4784997b338525b9db3c50ded4114a7d2c))
- `2026-01-31` · Implement virtual text for file manager UI ([`63fbc63`](https://github.com/abdellatif-temsamani/adev.nvim/commit/63fbc63d428fb3ebbe4c171b3b30c7c56c1fee2c))

### Bug fixes

- `2026-01-25` · **`changelog`** · Version display in the title ([`8299a33`](https://github.com/abdellatif-temsamani/adev.nvim/commit/8299a33ff571d2ce0bcdf41b342f7a8fdd440ced))
- `2026-01-25` · **`lspconfig`** · Lua_ls load ([`1507b63`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1507b63b0f8d97f5adf5fd6f26965ae5acdcfaed))
- `2026-01-29` · Conflict lua_ls x stylua on code formatting ([`1e5e92c`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1e5e92cd87e876b393d025a394ebe15f3ca88ba9))
- `2026-01-29` · **`adev-files`** · Window sizing ([`b1839f3`](https://github.com/abdellatif-temsamani/adev.nvim/commit/b1839f3ce4e9b51143eb55ffa919ee7aa721be7a))
- `2026-01-31` · Compare current version with latest in check_update ([`7a8d833`](https://github.com/abdellatif-temsamani/adev.nvim/commit/7a8d833efa8e6efa532ab3ad895a06a89234914e))
- `2026-01-31` · **`adev-files`** · Create new file ([`db3e836`](https://github.com/abdellatif-temsamani/adev.nvim/commit/db3e83686a7501a258cf52d2517a783b01dbd37f))
- `2026-01-31` · **`adev-files`** · Rename ([`fcaac25`](https://github.com/abdellatif-temsamani/adev.nvim/commit/fcaac25f3b215084118a8915c1e912f3cba9f336))

### Other changes

- `2026-01-28` · **`telescope`** · Changing keymaps ([`7f0e555`](https://github.com/abdellatif-temsamani/adev.nvim/commit/7f0e555d6a9587a72f4a82c11ef3e198d8813e75))
- `2026-01-31` · Adev-files ([`91b48ce`](https://github.com/abdellatif-temsamani/adev.nvim/commit/91b48ce87b4d097ff2259ba4b13da42b827f2a76))
- `2026-01-31` · Adev-files (#14) ([`ce8d0bd`](https://github.com/abdellatif-temsamani/adev.nvim/commit/ce8d0bd4921fe59c9d7be8da06836004f32036a6))
- `2026-01-31` · Adev-files ([`f9b869d`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f9b869dfbc3538356c54c7d1a5af23c709a0e1f5))

### Refactoring

- `2026-01-27` · Restructure file manager and remove deprecated code ([`6dc41e1`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6dc41e169ecd671864649c0539e0c9458159ff39))
- `2026-01-29` · **`core`** · Big refactor ([`6837be4`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6837be4030dc98645c114715835bdcb678eb0655))
- `2026-01-30` · **`adev-files`** · Change keymap to &lt;leader&gt;n ([`9146a2c`](https://github.com/abdellatif-temsamani/adev.nvim/commit/9146a2ca7b5c66d90c93758f56439058e1cba02f))
- `2026-01-30` · **`adev-files`** · Use &lt;nop&gt; to disable keymaps ([`2596d89`](https://github.com/abdellatif-temsamani/adev.nvim/commit/2596d893d1099fa6c69610615d799a543818844e))
- `2026-01-31` · **`adev-files`** · Index by filename instead of line number ([`6c735f1`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6c735f1bd58ef2f002a13f0ec5d45556941b8256))

### Documentation

- `2026-01-25` · **`requirement`** · Update min version of deps ([`149fd63`](https://github.com/abdellatif-temsamani/adev.nvim/commit/149fd63cab293d1ad027ba99ea43fe01261736a5))

### Plugins

- `2026-01-24` · **`none-ls`** · Disabled rustywind ([`43481e4`](https://github.com/abdellatif-temsamani/adev.nvim/commit/43481e4d3d48362e6034dc23db6959aead198971))
- `2026-01-29` · **`adev-files`** · Disable some keymaps ([`8b27e94`](https://github.com/abdellatif-temsamani/adev.nvim/commit/8b27e9463ff7d7d63c0a6fc0c5b5ef702a8d3a03))

### Maintenance

- `2026-01-24` · Update cliff.toml ([`4ffa746`](https://github.com/abdellatif-temsamani/adev.nvim/commit/4ffa7460d021a2a4b96cb96f07e0acab526c3251))
- `2026-01-30` · Coderabbit suggestions ([`6d2da0b`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6d2da0bad15bafdbf734256ad7f0fd29d1b356d9))

---
## [2.0.4](https://github.com/abdellatif-temsamani/adev.nvim/releases/tag/v2.0.4) · 2026-01-20
> 15 changes


### Features

- `2026-01-12` · **`update_manager`** · **BREAKING** · New update method ([`eb43c82`](https://github.com/abdellatif-temsamani/adev.nvim/commit/eb43c826a59669324aef67665044c9821f76497f))
- `2026-01-17` · **`blink.cmp`** · Enhance completion with mini.icons and add JS/TS snippets ([`b04776f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/b04776f7de03d600a7ea9fe23a363553dc244202))
- `2026-01-17` · Add custom vscode snippets support ([`9e1f905`](https://github.com/abdellatif-temsamani/adev.nvim/commit/9e1f905275ddfb3417bbb117582acecdb2039e05))

### Bug fixes

- `2026-01-12` · **`update_manager`** · Update ([`462256e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/462256eadc146916d412425e4868bbce6c8a97e4))
- `2026-01-12` · **`update_manager`** · Fetch remote tags ([`6011254`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6011254a0d9fcdd97121d5fe052635040ebc4a07))
- `2026-01-17` · **`blink`** · Sorting ([`4482e70`](https://github.com/abdellatif-temsamani/adev.nvim/commit/4482e70a994f6d945663648390ca58d45fbb58bc))
- `2026-01-17` · **`mini-files`** · Opens in current buf's dir ([`26a2304`](https://github.com/abdellatif-temsamani/adev.nvim/commit/26a2304e4d7f8d649071a20e6cb713364e50bdc1))

### Refactoring

- `2026-01-11` · Consolidate utilities and add feature flags system (#8) ([`fb07e6b`](https://github.com/abdellatif-temsamani/adev.nvim/commit/fb07e6b2d4012e3bb87302e9de28a8c8aed0e7c0))
- `2026-01-17` · **`lualine`** · **BREAKING** · Replace winbar with tabline.windows ([`7f64439`](https://github.com/abdellatif-temsamani/adev.nvim/commit/7f64439f798d88c5d815c6cfabaa778c6da4d437))
- `2026-01-17` · **`lualine`** · Change placing of lsp status ([`d105dcb`](https://github.com/abdellatif-temsamani/adev.nvim/commit/d105dcb2dfe67feacddbe63582768c03a589adac))
- `2026-01-17` · **`core-plugin`** · Re-structure adev core plugins ([`8a45d40`](https://github.com/abdellatif-temsamani/adev.nvim/commit/8a45d40b61a8c22dc6cc8c20241b7409dd5900fd))
- `2026-01-17` · Simplify file explorer configuration and remove telescope dependency ([`68b510e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/68b510e1ac44569333ce22fd3685c74a19e0f7d8))

### Documentation

- `2026-01-17` · **`adev.txt`** · Refactor docs ([`c2073d4`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c2073d40d7053747678dcec06b8ba6da8eebea72))
- `2026-01-19` · Update README and help to use :ADConfig for configuration ([`36dba27`](https://github.com/abdellatif-temsamani/adev.nvim/commit/36dba27b183cebb6e954e1c610c231f56e97e1f8))

### Reverts

- `2026-01-17` · Disable ghost_line ([`62c19e9`](https://github.com/abdellatif-temsamani/adev.nvim/commit/62c19e9cb39c45edaf251b630995574ceca61f36))

---
## [2.0.3](https://github.com/abdellatif-temsamani/adev.nvim/releases/tag/v2.0.3) · 2026-01-11
> 12 changes


### Features

- `2026-01-09` · Add feature flags system for experimental features (#5) ([`9a12347`](https://github.com/abdellatif-temsamani/adev.nvim/commit/9a12347df96ef1e506e3fa52cc7ae3fc2652d057))

### Bug fixes

- `2026-01-10` · Improve remote tag fetching and async handling ([`9f8bf11`](https://github.com/abdellatif-temsamani/adev.nvim/commit/9f8bf1192654c85d4f849a343545c77dd7483ad5))

### Refactoring

- `2026-01-10` · Improve onboarding module structure ([`e8f6406`](https://github.com/abdellatif-temsamani/adev.nvim/commit/e8f64060a5e5eac5bb15e750df1cd1cda05ff7e5))
- `2026-01-10` · Consolidate update_manager into single module ([`160f311`](https://github.com/abdellatif-temsamani/adev.nvim/commit/160f311fc1cf91138705f38678e523b3f134c7a4))
- `2026-01-10` · Extract git utilities to common module ([`1fd67af`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1fd67af6357e66f845e1ea92ffbd508c6c71cd4b))
- `2026-01-11` · **`utils`** · Restart_nvim to nvim ([`aac97e9`](https://github.com/abdellatif-temsamani/adev.nvim/commit/aac97e994e5a5aaafe98b6225720c9f6771e21f5))
- `2026-01-11` · Unify window and buffer creation API ([`e5bac44`](https://github.com/abdellatif-temsamani/adev.nvim/commit/e5bac44ea84c8a98cec5feb28343436e5ed60df0))
- `2026-01-11` · **`utils`** · Restart neovim take 2000ms instead of 1500ms ([`48d6a1e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/48d6a1e908eba6089002d3bc910e5eeea7ce688d))
- `2026-01-11` · **`blink`** · Start on CmdEnter ([`171647e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/171647ebb4f4e87a81dd8ce98c39e92245a77233))
- `2026-01-11` · Consolidate types and improve error handling ([`8e0dc58`](https://github.com/abdellatif-temsamani/adev.nvim/commit/8e0dc58231f7247290dc64fc91e9b96ee6bd24ea))

### Maintenance

- `2026-01-09` · Fix dupe @return ([`42bcf92`](https://github.com/abdellatif-temsamani/adev.nvim/commit/42bcf9215a70efe00bcbc2c47645a7e817537246))
- `2026-01-11` · **`coderabbit`** · Added .coderabbit.yaml ([`7fac20f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/7fac20f1711af045ca778a033fba252cd67f120d))

---
## [2.0.2](https://github.com/abdellatif-temsamani/adev.nvim/releases/tag/v2.0.2) · 2026-01-09
> 65 changes


### Features

- `2025-12-23` · Add build command for Catppuccin theme ([`311f3cd`](https://github.com/abdellatif-temsamani/adev.nvim/commit/311f3cd96283b66c45b7f63507a60c256817ed64))
- `2025-12-29` · Update treesitter ([`27de47b`](https://github.com/abdellatif-temsamani/adev.nvim/commit/27de47bf079cc996602cd9f451d95588a8e41b4d))
- `2026-01-03` · Adev-files ([`c76c939`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c76c939bf42324eda04fef0990da0e2877bda80f))
- `2026-01-03` · **`core`** · Spliting to adev, adev-common ([`a5025a9`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a5025a94993278f31d726d223c74f2f3bda0e5ab))
- `2026-01-04` · **`adev-files`** · List files ([`aac954d`](https://github.com/abdellatif-temsamani/adev.nvim/commit/aac954dc819aa806b5a96390541753a49d80168f))
- `2026-01-08` · Add build command for Catppuccin theme ([`3a93ea7`](https://github.com/abdellatif-temsamani/adev.nvim/commit/3a93ea72ada7aac334324adbe9e9b2a8431ab949))
- `2026-01-08` · Update treesitter ([`33b095a`](https://github.com/abdellatif-temsamani/adev.nvim/commit/33b095a6ef82b80c5ad28d27139747955d75ebee))
- `2026-01-08` · Adev-files ([`22a0d1e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/22a0d1efbf6a7912b5c00832648ad41e22d5f19e))
- `2026-01-08` · **`core`** · Spliting to adev, adev-common ([`ac35470`](https://github.com/abdellatif-temsamani/adev.nvim/commit/ac35470e69544e35971ed026f3a1ba324a52a891))
- `2026-01-08` · **`adev-files`** · List files ([`c0d8ac8`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c0d8ac8e800a44cf0c03f2c35ca75fb4c9bc4e56))
- `2026-01-09` · Add feature flags system ([`1f34fa5`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1f34fa57e877e6d4d852b285388fca1d16436c0b))

### Bug fixes

- `2025-12-23` · **`treesitter`** · Add ipkg to ignore_install list ([`128b114`](https://github.com/abdellatif-temsamani/adev.nvim/commit/128b11431ee00773c1bc5d9668b0074948344850))
- `2025-12-29` · Treesitter ([`2af2eca`](https://github.com/abdellatif-temsamani/adev.nvim/commit/2af2eca7eaec598efef231c28eb7a8e55e454fa6))
- `2025-12-29` · Remove those annoying arg auto fill snippets ([`29e749a`](https://github.com/abdellatif-temsamani/adev.nvim/commit/29e749a2e0f2cdf59be83483f29d58adace5dcb1))
- `2026-01-02` · **`blink`** · Cmdline completions ([`9de1600`](https://github.com/abdellatif-temsamani/adev.nvim/commit/9de1600000a75733ea16c5f96d069e3010a66095))
- `2026-01-03` · **`onboarding`** · If init.lua exist but init-opts.lua not found edge case ([`5b78848`](https://github.com/abdellatif-temsamani/adev.nvim/commit/5b788484e350bde23a8fad4d0956d5fad75b7e53))
- `2026-01-03` · **`core`** · Fix onboarding ([`1c93fad`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1c93fad1b619b1f1a7b17dfcd5a6840825255e44))
- `2026-01-04` · Get_dirname ([`5e11904`](https://github.com/abdellatif-temsamani/adev.nvim/commit/5e1190432383c04017cbfb08e4382f2b67f6f80c))
- `2026-01-06` · **`blink`** · Completions ([`a97e422`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a97e422ff5d63d8f61fede49eb27787b54d09744))
- `2026-01-08` · Spelling ([`42e49f7`](https://github.com/abdellatif-temsamani/adev.nvim/commit/42e49f7f13acedc197f15d44204daf6322a5859e))
- `2026-01-08` · **`treesitter`** · Add ipkg to ignore_install list ([`164b55f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/164b55fa4d96117f19eb4a6fa15961b0919160a7))
- `2026-01-08` · Remove those annoying arg auto fill snippets ([`04707bc`](https://github.com/abdellatif-temsamani/adev.nvim/commit/04707bc015a7ba3bea337860c5e424c37788586a))
- `2026-01-08` · **`onboarding`** · If init.lua exist but init-opts.lua not found edge case ([`0535ef9`](https://github.com/abdellatif-temsamani/adev.nvim/commit/0535ef9d059e055e55f2b1da11fe7f2874cbccc8))
- `2026-01-08` · **`blink`** · Cmdline completions ([`6ed4cd3`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6ed4cd385df54691d7c9a14c4598f1096e2a30d1))
- `2026-01-08` · **`core`** · Fix onboarding ([`2026256`](https://github.com/abdellatif-temsamani/adev.nvim/commit/20262567540b3b021cbb695930518e1ed9048b5c))
- `2026-01-08` · Get_dirname ([`2a2bcc7`](https://github.com/abdellatif-temsamani/adev.nvim/commit/2a2bcc749de07719950b0a550b4b66dd6510bcfd))
- `2026-01-08` · **`blink`** · Completions ([`9f4a88e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/9f4a88ecc5fe1d19a82cc446267c65a5df087b71))
- `2026-01-08` · Spelling ([`802c753`](https://github.com/abdellatif-temsamani/adev.nvim/commit/802c7534a2ab97552144b85860c319070efa0fab))
- `2026-01-09` · Refactor config merging to properly handle user-only keys ([`114b377`](https://github.com/abdellatif-temsamani/adev.nvim/commit/114b377fc5fee1d8e79887d91c4b0a49042b4812))
- `2026-01-09` · **`typo`** · Lua/adev-common/utils/files.lua ([`65b0f72`](https://github.com/abdellatif-temsamani/adev.nvim/commit/65b0f72d377b1f099bcc9c0bc68ea2e595a2e74a))
- `2026-01-09` · Docs ([`9af4716`](https://github.com/abdellatif-temsamani/adev.nvim/commit/9af4716ca45a5e9311627841d6ccd6338093d8c0))
- `2026-01-09` · **`adev-files`** · Expand paths consistently before file operations ([`648bd2f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/648bd2ffa98e151130ee1d24502f1fe6864230d5))

### Refactoring

- `2026-01-03` · **`onboarding`** · ADConfig hot-reloads nvim ([`a3c9c07`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a3c9c07a5ba3c8a8884ecef340130c30bf4556fd))
- `2026-01-03` · **`plugins`** · Changing plugins configs ([`1c611b3`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1c611b3d4d5c010394ac2e41edb44f0f68912bc6))
- `2026-01-03` · **`mini`** · Move to standalone mini.nvim plugins ([`8d7606e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/8d7606e4c7e61dd5d8edb6dc2102a07b18294001))
- `2026-01-03` · **`adev-files`** · Common-utils ([`0de042e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/0de042e2294b675e4af3f57bb1ab2ff1684a6a50))
- `2026-01-03` · Simplify mini plugin spec nesting and update UI structure ([`f1a1386`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f1a13867b0591957302a4ddad8cc7ae9cb9f56e6))
- `2026-01-03` · Improve neovim config utilities and plugin settings ([`ea93882`](https://github.com/abdellatif-temsamani/adev.nvim/commit/ea9388286227c486986eb5ad65ddd1877b378b87))
- `2026-01-04` · **`adev-files`** · Refactor list files to open in a floating window ([`48914d8`](https://github.com/abdellatif-temsamani/adev.nvim/commit/48914d8e1717a57d6bb0168fb7bdddd5e3bcfef8))
- `2026-01-04` · **`adev-files`** · List files improve highlighting ([`7f8ff59`](https://github.com/abdellatif-temsamani/adev.nvim/commit/7f8ff59792fe529b62185e7121fbdb5183e43516))
- `2026-01-08` · Improve input UI signature and centralize file operations ([`6a09fce`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6a09fce5a730e411a7c57282000e0d3ada902c22))
- `2026-01-08` · Improve code structure and error handling ([`2e3e0c9`](https://github.com/abdellatif-temsamani/adev.nvim/commit/2e3e0c992c8ed2520bdd8cfec0721316b390e42d))
- `2026-01-08` · **`onboarding`** · ADConfig hot-reloads nvim ([`4e73986`](https://github.com/abdellatif-temsamani/adev.nvim/commit/4e739865ca76ed65d6dc20bb2e26ad7f74b1836d))
- `2026-01-08` · **`plugins`** · Changing plugins configs ([`6d34213`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6d34213efb9ffd15cca50343be7061ad333a73ec))
- `2026-01-08` · **`mini`** · Move to standalone mini.nvim plugins ([`fbc3d75`](https://github.com/abdellatif-temsamani/adev.nvim/commit/fbc3d754e45220628cce7f6f0be7abe4d4786925))
- `2026-01-08` · **`adev-files`** · Common-utils ([`6c263a0`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6c263a056c0bc4d61ccca13086569e107d1340a0))
- `2026-01-08` · Simplify mini plugin spec nesting and update UI structure ([`27e2cb3`](https://github.com/abdellatif-temsamani/adev.nvim/commit/27e2cb306ec5bccde1190d25f0475783ac4dff0f))
- `2026-01-08` · Improve neovim config utilities and plugin settings ([`8a6e7d4`](https://github.com/abdellatif-temsamani/adev.nvim/commit/8a6e7d451ba226328eb29aeb19c7c2a428a51edb))
- `2026-01-08` · **`adev-files`** · Refactor list files to open in a floating window ([`5137fc2`](https://github.com/abdellatif-temsamani/adev.nvim/commit/5137fc27802ac6792d69b6b57e842097f39fbfc6))
- `2026-01-08` · **`adev-files`** · List files improve highlighting ([`a9fd8a7`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a9fd8a74f12e668fe6801569bf74f277476329b4))
- `2026-01-08` · Improve input UI signature and centralize file operations ([`834e10a`](https://github.com/abdellatif-temsamani/adev.nvim/commit/834e10a75fd8bf699f2951c8c72a7be0029bc155))
- `2026-01-08` · Improve code structure and error handling ([`3c6e474`](https://github.com/abdellatif-temsamani/adev.nvim/commit/3c6e4747a5869aaf2d905bed030029d1daa0f5b2))
- `2026-01-09` · Restructure adev-files actions ([`07add3e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/07add3ec9fdfa2a9fc5d179b3e0aac439dec635c))

### Documentation

- `2025-12-26` · Update TODO.md with custom file management UI ([`bf07a36`](https://github.com/abdellatif-temsamani/adev.nvim/commit/bf07a364065eb0aeb714dc49dd738b821a05bbf6))
- `2026-01-08` · Improve personal statement supporting Palestinian human rights ([`d3503a0`](https://github.com/abdellatif-temsamani/adev.nvim/commit/d3503a005d4f8ebc413a793d985a7e8509fc61ff))
- `2026-01-08` · Update TODO.md with custom file management UI ([`b7d714f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/b7d714fe368ebcc8f40dbd33465c7e3fce038a53))
- `2026-01-09` · Update documentation with feature flags info ([`a8ff629`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a8ff629943878d105ea3293c91a4487406bd1830))
- `2026-01-09` · Mention :ADConfig command for modifying flags ([`add861a`](https://github.com/abdellatif-temsamani/adev.nvim/commit/add861a600e472fa7aa053c30e196475fcf3a762))

### Styling

- `2026-01-09` · Fix lua doc comment syntax ([`b75260a`](https://github.com/abdellatif-temsamani/adev.nvim/commit/b75260ad9f7d05a74909785476473095d1e57eb6))

### Maintenance

- `2025-12-30` · **`laravel`** · Switch to laravel ([`ee0f477`](https://github.com/abdellatif-temsamani/adev.nvim/commit/ee0f477335a123360e40b3213baa3a622ca2834f))
- `2026-01-04` · **`adev-files`** · List files help index ([`ffcec37`](https://github.com/abdellatif-temsamani/adev.nvim/commit/ffcec37b8d2f380861c2b44decc07541c417c267))
- `2026-01-08` · Add project-specific git attributes for neovim config ([`bde3f2d`](https://github.com/abdellatif-temsamani/adev.nvim/commit/bde3f2d9e693cf2cf26d56fb1c0a8fd9c8cfff6c))
- `2026-01-08` · **`laravel`** · Switch to laravel ([`b4b1231`](https://github.com/abdellatif-temsamani/adev.nvim/commit/b4b123100ad6c62a018920cf872668826444000d))
- `2026-01-08` · **`adev-files`** · List files help index ([`40ad3e9`](https://github.com/abdellatif-temsamani/adev.nvim/commit/40ad3e995aeb9177755ce5c56e9660a7ccf1157d))
- `2026-01-08` · Add project-specific git attributes for neovim config ([`ba78b11`](https://github.com/abdellatif-temsamani/adev.nvim/commit/ba78b11337b147aaea72a382a89d74ac20362ac8))

---
## [2.0.1](https://github.com/abdellatif-temsamani/adev.nvim/releases/tag/v2.0.1) · 2025-12-23
> 109 changes


### Features

- `2024-12-18` · Lazy laoding ([`2f37cfc`](https://github.com/abdellatif-temsamani/adev.nvim/commit/2f37cfc27aeff10cb41a95989be8ab7b2c37cc51))
- `2024-12-22` · Nvim-cmp -&gt; blink-cmp ([`4b160e1`](https://github.com/abdellatif-temsamani/adev.nvim/commit/4b160e130277054d74a58733010ab39ee9c16724))
- `2025-01-25` · Mini.nvim && cleaning plugins ([`7db3a3b`](https://github.com/abdellatif-temsamani/adev.nvim/commit/7db3a3b1728eed7f05a346d8def592cf990ea006))
- `2025-07-30` · Config to distro ([`cdb419c`](https://github.com/abdellatif-temsamani/adev.nvim/commit/cdb419cf6e5bbfea8d52bc2bee233313dbbe7b6f))
- `2025-07-30` · **`snacks`** · Add image support ([`0ac4e41`](https://github.com/abdellatif-temsamani/adev.nvim/commit/0ac4e413cb5ddb2d2ca309cbc00ed09c76d37f6b))
- `2025-07-31` · **`lsp`** · Diagonistic vertual line [expermental] ([`7e51c97`](https://github.com/abdellatif-temsamani/adev.nvim/commit/7e51c9799248369f74eb6296a74511e9d4ef1fff))
- `2025-08-02` · **`config`** · Mv config to lua/abdellatifdev/config ([`3710dbd`](https://github.com/abdellatif-temsamani/adev.nvim/commit/3710dbdade823db47177909c8fbdcaeb52b38ba6))
- `2025-08-02` · **`git-worktree`** · **BREAKING** · Rm plugins ([`8cff229`](https://github.com/abdellatif-temsamani/adev.nvim/commit/8cff229c784fe6f3fae43d5520e6e8ca9a61b727))
- `2025-08-02` · **`health`** · Healthcheck adev ([`53ec74e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/53ec74ea5c04efc3cb0f73d880d01fc4280be038))
- `2025-08-04` · **`blink-cmp`** · Conventional-commits ([`60faa4b`](https://github.com/abdellatif-temsamani/adev.nvim/commit/60faa4b4ca70d6ed4c80e2c098acb8b2647e2bf3))
- `2025-08-04` · **`blink-cmp`** · Ghostline cmdline ([`1e77b24`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1e77b24314d4bf1563115ea2e79021c14f44cfcc))
- `2025-08-25` · **`noice`** · Override defaults ([`2fa949d`](https://github.com/abdellatif-temsamani/adev.nvim/commit/2fa949df7cefb812183a498b2a0baa7a81eabf14))
- `2025-09-01` · **`lsp`** · Tailwindcss config ([`f966151`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f9661511ff512694fcc4d5d2f06f446d376865f1))
- `2025-09-11` · **`blink.nvim`** · **BREAKING** · Removing providers ([`247705f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/247705f4bab06b91feb96b269ca44468d887bef9))
- `2025-09-23` · **`cmp`** · **BREAKING** · Blink-cmp -&gt; nvim-cmp ([`e3f8628`](https://github.com/abdellatif-temsamani/adev.nvim/commit/e3f86288c9daf044e0e3eb24310a93eb8503ff49))
- `2025-09-28` · Godot linting ([`4809caa`](https://github.com/abdellatif-temsamani/adev.nvim/commit/4809caa48c99d08e9ce20ac70f17f8b99349058a))
- `2025-09-29` · Auto check for update ([`b5f00af`](https://github.com/abdellatif-temsamani/adev.nvim/commit/b5f00af8cea65a056acd5e317c41b91c12cc0445))
- `2025-10-04` · Gdformat use spaces ([`c764d06`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c764d06ada7697d7af60335d7b2151ff80914818))
- `2025-10-04` · **`autocmd`** · Gdscript space ([`7b1d5bd`](https://github.com/abdellatif-temsamani/adev.nvim/commit/7b1d5bd419d724e224ee9abac6d7d6c832dc4956))
- `2025-10-07` · **`cmp`** · Back to blink.cmp v1.3.1 ([`61fb4cd`](https://github.com/abdellatif-temsamani/adev.nvim/commit/61fb4cdcb58456b4d2a315bf40e11890f9f0fcb1))
- `2025-10-08` · **`lua`** · Vim highlight as builtin ([`8f886e4`](https://github.com/abdellatif-temsamani/adev.nvim/commit/8f886e4a9cb2f48f0b3dc977bb589e0330db8514))
- `2025-10-08` · **BREAKING** · Lua_ls hints ([`bfd1599`](https://github.com/abdellatif-temsamani/adev.nvim/commit/bfd1599244c5f205c3e713582134e184ae9aa6aa))
- `2025-10-09` · More info ([`3f72c11`](https://github.com/abdellatif-temsamani/adev.nvim/commit/3f72c118e7baa726dc321adea461fe661e30f169))
- `2025-10-11` · New utils function ([`e35e47f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/e35e47f8de08d758d72c9f3f4b47959b5968d449))
- `2025-10-11` · Opts "git" ([`87954bf`](https://github.com/abdellatif-temsamani/adev.nvim/commit/87954bf698c7179d21963902281ecbe50417d436))
- `2025-10-11` · Opts "colorscheme" ([`a37851e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a37851e859f4efc5037db6909de8f55b7bfeb950))
- `2025-10-12` · **`blink-cmp`** · Calc source ([`d14e22c`](https://github.com/abdellatif-temsamani/adev.nvim/commit/d14e22c9963235fdead93d9be9af5aa117d7b94a))
- `2025-10-13` · **`null-ls`** · Added stylua ([`98f2926`](https://github.com/abdellatif-temsamani/adev.nvim/commit/98f2926a8bf46077707eb8647bc9c5169b5fa0d2))
- `2025-10-13` · **`new-plugin`** · **BREAKING** · Augment ([`00dd09f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/00dd09f7a6ed202fb0b94e2de95ef2de73ee4e49))
- `2025-10-15` · **`set`** · More options ([`cd99cc7`](https://github.com/abdellatif-temsamani/adev.nvim/commit/cd99cc70728ad8433288fa3c68059aa0037ac959))
- `2025-12-21` · Add treesitter auto-start configuration and update project release name ([`ffc7e26`](https://github.com/abdellatif-temsamani/adev.nvim/commit/ffc7e265c3d134fdf0945279a15526bbbb6487e3))
- `2025-12-21` · Temp implementation of ADConfig ([`f9457b2`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f9457b2933b26e3dd230bfba7ee38effa9c7ad4c))

### Bug fixes

- `2024-12-18` · Readme ([`2223821`](https://github.com/abdellatif-temsamani/adev.nvim/commit/2223821d5c947f02ab1b874484d744ca01a71110))
- `2025-01-26` · Snacks ([`f5cd1bf`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f5cd1bf2414dce57352314dea43c812160d720d4))
- `2025-05-19` · Lsp keymaps ([`f38d83a`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f38d83a6f544877fa0e774faf9811064a0010a51))
- `2025-06-25` · **`blink.cmp`** · Temp fix ([`57a1543`](https://github.com/abdellatif-temsamani/adev.nvim/commit/57a15435fec911914ee5e755c123e2573148a343))
- `2025-07-30` · **`theme`** · Align with telescope and snacks ([`32a1c08`](https://github.com/abdellatif-temsamani/adev.nvim/commit/32a1c088f9ad4555c99921d43390fd12ca2f7376))
- `2025-07-31` · **`lualine`** · Winbar now displays "Adev.nvim" instead of "abdellatif dev" ([`3049ea2`](https://github.com/abdellatif-temsamani/adev.nvim/commit/3049ea2c24bb842efcc2d9419a0fac264b5330b6))
- `2025-08-02` · **`blink.cmp`** · Downgrade to "v1.3.1" ([`84b21b0`](https://github.com/abdellatif-temsamani/adev.nvim/commit/84b21b0d1c1a1a0fcbcec1dbe442e2a39811060f))
- `2025-08-02` · **`crates.nvim`** · Add event for lazy loading ([`360106c`](https://github.com/abdellatif-temsamani/adev.nvim/commit/360106cd37abc689d402730d8fb519a441462733))
- `2025-08-02` · **`treesitter`** · Plugin event ([`aa0f7f1`](https://github.com/abdellatif-temsamani/adev.nvim/commit/aa0f7f1a25a0350bac5f3e07dcf1ef47b0896284))
- `2025-08-02` · **`telescope`** · Border style ([`e137c04`](https://github.com/abdellatif-temsamani/adev.nvim/commit/e137c0445d0cfc16a5dda25f19434c3c68d63101))
- `2025-09-05` · Better notifications ([`1e0b130`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1e0b13081e1c0ad7e3a1fb749986bd62e3b33417))
- `2025-09-11` · **`laravel`** · Missing deps ([`f5e7731`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f5e77311d868a7546f23f51b20b3723977ae1f9e))
- `2025-09-15` · **`laravel`** · **BREAKING** · Fix commands ([`d09760a`](https://github.com/abdellatif-temsamani/adev.nvim/commit/d09760a8284a25d77dd845640a512be540b91ad5))
- `2025-10-04` · Sets config ([`0d619f9`](https://github.com/abdellatif-temsamani/adev.nvim/commit/0d619f9d95aad4ed6625ad28c3ef9dd762900994))
- `2025-10-08` · **`blink.cmp`** · Config ([`11fc43a`](https://github.com/abdellatif-temsamani/adev.nvim/commit/11fc43a86a45b056ffabe0aa506e7445ead9bb1c))
- `2025-10-08` · **BREAKING** · Cmp ([`1e446f1`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1e446f1d7ab892e653bc6effdadcfe536b5c07fc))
- `2025-10-08` · Version ([`43017c9`](https://github.com/abdellatif-temsamani/adev.nvim/commit/43017c92880bfc1105b79a6928cb0f8001495939))
- `2025-10-09` · Check update ([`1133ef8`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1133ef84e97bcbed259e707aef84b9b921d63127))
- `2025-10-10` · **`laravel`** · Fix lazyloading ([`8c2e8a5`](https://github.com/abdellatif-temsamani/adev.nvim/commit/8c2e8a57c16e2ea2b6dc8a81fd6345580fa912db))
- `2025-10-11` · Lazy loading ([`eac2f34`](https://github.com/abdellatif-temsamani/adev.nvim/commit/eac2f348da5f5a04e942fded0b7fc135577335c7))
- `2025-10-11` · Lazyloading ([`aa1e9f8`](https://github.com/abdellatif-temsamani/adev.nvim/commit/aa1e9f891f6bcd902dec9205a5e3e5cdb7f9003a))
- `2025-10-11` · Luadocs ([`c3fc076`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c3fc07666d6044a7caba2eb82310ecbd9e4826da))
- `2025-10-12` · Queries ([`0e2252e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/0e2252eaf7fd8b6ab69a9241dbd732ec47d8aee8))
- `2025-10-13` · **`comments`** · Lazyloading conditions ([`1c70603`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1c70603f57914fbcb6fb22263546e4ab4ce0c49c))
- `2025-10-13` · **`mason`** · Lazyloading ([`29ed374`](https://github.com/abdellatif-temsamani/adev.nvim/commit/29ed3740a3220a52b993ec6e311e21e4b2b50cc1))
- `2025-10-13` · **`mason`** · Plugin not loading ([`91c324b`](https://github.com/abdellatif-temsamani/adev.nvim/commit/91c324b0a68157008590eb6a4f233ebafd534f83))
- `2025-10-13` · **BREAKING** · Lazy loading condition ([`f6f7996`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f6f79963a42fc6881582a1121cf7337d5f65c96b))
- `2025-10-15` · **`mason-lspconfig`** · Origin ([`886536b`](https://github.com/abdellatif-temsamani/adev.nvim/commit/886536b4da15548d1c79006d97cdf1361fff3741))
- `2025-10-15` · Config ([`f9d505c`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f9d505ca639f8dddf6f9508969628af17a8ed7c1))
- `2025-10-16` · **`options`** · Border = 'single' ([`0ee8c3b`](https://github.com/abdellatif-temsamani/adev.nvim/commit/0ee8c3b5069827797aafe5ddfe51cb1dd2e3fcc5))
- `2025-10-19` · **`plugins`** · Event loading ([`b52a471`](https://github.com/abdellatif-temsamani/adev.nvim/commit/b52a4712e03196694b7c04f15c9502aaeda6ff8c))
- `2025-10-19` · **`treesitter`** · Not loading ([`652f372`](https://github.com/abdellatif-temsamani/adev.nvim/commit/652f372c466725004203a1c8114df31d55642249))
- `2025-10-19` · **`plugins`** · Lazy loading conditions ([`4b08129`](https://github.com/abdellatif-temsamani/adev.nvim/commit/4b081299284b73da5b318426d1da6d65d59c72be))
- `2025-10-20` · **`gitsigns`** · Lazyloading ([`bc9428d`](https://github.com/abdellatif-temsamani/adev.nvim/commit/bc9428d40e90076f48da0f05a6f2b2d5841dd7f3))
- `2025-12-21` · Add assertion for LSP defaults in lsp.lua ([`7f0b9fa`](https://github.com/abdellatif-temsamani/adev.nvim/commit/7f0b9fa7f60c5b2d8c019ab1cc84cddbb31b1e21))
- `2025-12-23` · Treesitter config ([`c5d38d2`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c5d38d22351d0d463c7c8a68c5584545351ba900))

### Refactoring

- `2025-07-31` · **`notification`** · Changes notification handling ([`f793e4c`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f793e4c8171c7359630c93559d08b17c4e941d95))
- `2025-08-01` · **`theme`** · Optimize opts ([`3226bf7`](https://github.com/abdellatif-temsamani/adev.nvim/commit/3226bf7dc846d042b763f3528bc9a0273b6081a1))
- `2025-08-01` · **`theme`** · Optimize config ([`68b6393`](https://github.com/abdellatif-temsamani/adev.nvim/commit/68b6393e8a1669f53d8ad7073ac12b641b75c41b))
- `2025-08-02` · **`plugins`** · Lazy = true as default value ([`366592f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/366592fe0e3d3d53f9ad292ceee6df32f2b00d55))
- `2025-08-02` · **`comments`** · Change config ([`bd57ce8`](https://github.com/abdellatif-temsamani/adev.nvim/commit/bd57ce87233c1264aa3f43596ea15bf68cb57869))
- `2025-08-02` · **`ui`** · Border styles ([`f334fbb`](https://github.com/abdellatif-temsamani/adev.nvim/commit/f334fbbb248559a5a21a1e227db13c28f774fb3f))
- `2025-08-02` · **`plugins`** · Lazy loading ([`73cc63d`](https://github.com/abdellatif-temsamani/adev.nvim/commit/73cc63d1c6d838a3771f11273672545e54cb339c))
- `2025-08-02` · **`config`** · Lua/abdellatifdev -&gt; lua/adev ([`94613e5`](https://github.com/abdellatif-temsamani/adev.nvim/commit/94613e52d8143b4727873314dce7ba165b4f5e73))
- `2025-08-02` · **`plugins`** · Cleaning plugins ([`e604cc7`](https://github.com/abdellatif-temsamani/adev.nvim/commit/e604cc7d4dfda62410360f844c10b41635c24414))
- `2025-08-02` · **`plugins`** · Structure ([`a19c847`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a19c847fc9a6390e2d2b5f8660e8f8463de20caf))
- `2025-10-11` · **`core`** · Changing code structure ([`56da910`](https://github.com/abdellatif-temsamani/adev.nvim/commit/56da910eaae67ef8f2fa802443f8f71dab6e348b))
- `2025-10-11` · **BREAKING** · Internal structure ([`dabd06f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/dabd06fe56832a41ab97d92a3f9ab42e102727d6))
- `2025-10-11` · **`events`** · Rewrite Event handler ([`2f20310`](https://github.com/abdellatif-temsamani/adev.nvim/commit/2f2031006d8e7dfd75f1995250f8618228662789))
- `2025-10-15` · **`core`** · Refactoring vim.g.adev ([`ffaf324`](https://github.com/abdellatif-temsamani/adev.nvim/commit/ffaf324b28848e0dba75973c894b3abde626a85b))
- `2025-10-15` · **`core`** · Refactoring vim.g.adev ([`6b9ab01`](https://github.com/abdellatif-temsamani/adev.nvim/commit/6b9ab01042791eeeab5223c5bde9c5c867fb2ab0))

### Documentation

- `2025-07-30` · Add contributing and PR guidelines ([`c8eaa76`](https://github.com/abdellatif-temsamani/adev.nvim/commit/c8eaa76b9f29763ca202dd9c04d3e6067c148ceb))
- `2025-07-30` · Add contributing and PR guidelines (#1) ([`742ee78`](https://github.com/abdellatif-temsamani/adev.nvim/commit/742ee784589546f5eb66681016b8bdab9ada2369))
- `2025-08-02` · **`adev`** · Vim docs ([`0e878b8`](https://github.com/abdellatif-temsamani/adev.nvim/commit/0e878b8a4160698e01a9312dd9d9b51de9f7a49d))
- `2025-09-23` · Cleaning docs ([`e633439`](https://github.com/abdellatif-temsamani/adev.nvim/commit/e6334399fb059900833caa3effbd5448dbdde810))
- `2025-10-08` · Fix plugin struture ([`00bfc12`](https://github.com/abdellatif-temsamani/adev.nvim/commit/00bfc12f4852fa0331596b118e51e8aadf1bdbc0))
- `2025-10-11` · Update adev.txt ([`b53deee`](https://github.com/abdellatif-temsamani/adev.nvim/commit/b53deee360dbf91f571bb9296be7dfc78acd1bdf))
- `2025-10-11` · **`adev.txt`** · Update ([`2e06452`](https://github.com/abdellatif-temsamani/adev.nvim/commit/2e0645234a4bb2e731a1d81bcd825e773eea565a))
- `2025-10-11` · Update README ([`a834852`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a83485298aa91fb3169fd7a1a1de31c9acc6df92))
- `2025-12-21` · Update CHANGELOG.md ([`bb63428`](https://github.com/abdellatif-temsamani/adev.nvim/commit/bb63428be68896ac4223972735ef1ac3a3c985a2))
- `2025-12-21` · Update documentation to reflect codebase changes ([`799c41f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/799c41fd5fe1a8c3727ce156d145c0250b71370e))
- `2025-12-21` · Update documentation to reflect codebase changes ([`0518051`](https://github.com/abdellatif-temsamani/adev.nvim/commit/05180514e8d64f54f7f14a1bcfd67f5cbd977388))

### Styling

- `2025-10-11` · Unify code formatting ([`fd56489`](https://github.com/abdellatif-temsamani/adev.nvim/commit/fd564897b8d5c417110b9ade0dc4510d72558dd9))
- `2025-10-11` · Stylua toml ([`b73290d`](https://github.com/abdellatif-temsamani/adev.nvim/commit/b73290d7471ab7140dc3f3710d020a1b1f706ed5))
- `2025-10-11` · **`stylua`** · Formatting ([`cadfe7e`](https://github.com/abdellatif-temsamani/adev.nvim/commit/cadfe7eaa90f38e5dee7527bad7c7fc5d5037966))
- `2025-10-13` · Linting ([`5e2c688`](https://github.com/abdellatif-temsamani/adev.nvim/commit/5e2c688155b9439d55e6c1c66921ef8cccaedc1d))

### Tests

- `2025-08-02` · **`checkhealth`** · Improve checkhealth ([`92796f4`](https://github.com/abdellatif-temsamani/adev.nvim/commit/92796f4aa25cf9679fc531c64cecf1cce30d9e49))

### Maintenance

- `2025-07-30` · Updates docs ([`95fe463`](https://github.com/abdellatif-temsamani/adev.nvim/commit/95fe4637a959deba2c0981691b0e012b730510ea))
- `2025-07-30` · Adding humanity ([`00901ef`](https://github.com/abdellatif-temsamani/adev.nvim/commit/00901ef7cdae1e786e18d9382b9bc5bd74a590bb))
- `2025-07-30` · **`issue templates`** · Refine templates ([`b860d63`](https://github.com/abdellatif-temsamani/adev.nvim/commit/b860d638ae4e459627e6bb9a4fad5c1a5ed646a7))
- `2025-07-30` · **`issue templates`** · Refine templates (#2) ([`1e9d1b0`](https://github.com/abdellatif-temsamani/adev.nvim/commit/1e9d1b00a1b1bb6784b4b19764ff99400f6ec5f6))
- `2025-07-31` · **`todo`** · Todo comment to github issues ([`2315fe2`](https://github.com/abdellatif-temsamani/adev.nvim/commit/2315fe2c271c65654b4e4ed9e734538f80830293))
- `2025-08-02` · **`version`** · 1.2.0 ([`a901dd9`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a901dd97bd9663785d64f0a3f626407b3c16704c))
- `2025-08-02` · **`github`** · Pull request template ([`089915f`](https://github.com/abdellatif-temsamani/adev.nvim/commit/089915ffb4b7bf34b07e459314ff9af689e5c8e5))
- `2025-09-15` · **`version`** · Minor update ([`6209434`](https://github.com/abdellatif-temsamani/adev.nvim/commit/62094348fc42f3211dc3d3782fa7f2b6ddb799c6))
- `2025-10-11` · Todo.md ([`e69be6d`](https://github.com/abdellatif-temsamani/adev.nvim/commit/e69be6d9bfbf4017319aaba0b526ba46318b1b41))
- `2025-12-21` · Auto publish ([`a5924c7`](https://github.com/abdellatif-temsamani/adev.nvim/commit/a5924c7261a67876cc331633d4a8984149647f6f))

---
## Project links

[Repository](https://github.com/abdellatif-temsamani/adev.nvim) · [Releases](https://github.com/abdellatif-temsamani/adev.nvim/releases) · [Issues](https://github.com/abdellatif-temsamani/adev.nvim/issues) · [Contributing](CONTRIBUTING.md) · [MIT License](LICENSE)

<sub>Generated with [git-cliff](https://git-cliff.org) for Adev.nvim.</sub>
