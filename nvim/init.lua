require('vim._core.ui2').enable()

-- PLUGINS ========================================================================================
vim.pack.add({
    { src = "https://github.com/navarasu/onedark.nvim" },
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/ibhagwan/fzf-lua" },
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
    { src = "https://github.com/windwp/nvim-autopairs" },
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/rcarriga/nvim-dap-ui" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/nanotee/sqls.nvim" },
    { src = "https://github.com/nvim-tree/nvim-tree.lua" },
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate"
    },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
    { src = "https://github.com/sphamba/smear-cursor.nvim" },
})

-- GITSIGNS #######################################################################################
vim.schedule(function()
    local status_ok, gitsigns = pcall(require, "gitsigns")
    if not status_ok then
        return
    end

    gitsigns.setup({
        signs = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        signs_staged = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
            follow_files = true
        },
        auto_attach = true,
        on_attach = function(bufnr)
            local gitsigns = require('gitsigns')

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            map('n', ']c', function()
                if vim.wo.diff then
                    vim.cmd.normal({ ']c', bang = true })
                else
                    gitsigns.nav_hunk('next')
                end
            end)

            map('n', '[c', function()
                if vim.wo.diff then
                    vim.cmd.normal({ '[c', bang = true })
                else
                    gitsigns.nav_hunk('prev')
                end
            end)

            map('n', '<leader>hs', gitsigns.stage_hunk)
            map('n', '<leader>hr', gitsigns.reset_hunk)

            map('v', '<leader>hs', function()
                gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end)

            map('v', '<leader>hr', function()
                gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end)

            map('n', '<leader>hS', gitsigns.stage_buffer)
            map('n', '<leader>hR', gitsigns.reset_buffer)
            map('n', '<leader>hp', gitsigns.preview_hunk)
            map('n', '<leader>hi', gitsigns.preview_hunk_inline)

            map('n', '<leader>hb', function()
                gitsigns.blame_line({ full = true })
            end)

            map('n', '<leader>hd', gitsigns.diffthis)
            map('n', '<leader>hD', function()
                gitsigns.diffthis('~')
            end)

            map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
            map('n', '<leader>hq', gitsigns.setqflist)

            map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
            map('n', '<leader>tw', gitsigns.toggle_word_diff)

            map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
        end
    })
end
)

-- LUALINE ########################################################################################
local function get_lsp_client()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if next(clients) == nil then
        return "No LSP"
    end

    local client_names = {}
    for _, client in pairs(clients) do
        table.insert(client_names, client.name)
    end
    return table.concat(client_names, ", ")
end

local unsaved_buffers_indicator = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].modified then
            return '🔀 Unsaved Changes!'
        end
    end
    return ''
end

local modified_status_color = function()
    if vim.bo.modified then
        return { fg = '#ff0000', gui = 'bold' }
    end
    return { fg = '#00ff00' }
end

require("lualine").setup {
    sections = {
        lualine_b = { "branch" },
        lualine_c = {
            {
                "filename",
                color = modified_status_color,
                path = 2,
                symbols = {
                    modified = "📝",
                    readonly = "👀",
                    unnamed = "❌",
                    newfile = "📄"
                }
            },
            unsaved_buffers_indicator
        },
        lualine_x = {},
        lualine_y = { "filesize", "encoding", "fileformat", "filetype" },
        lualine_z = { get_lsp_client },
    },
    options = {
        theme = "onelight"
    }
}

-- FZF-LUA ########################################################################################
require("fzf-lua").setup({
    defaults = {
        file_ignore_patterns = {
            'bin/',
            'obj/',
            'Debug/'
        },
    },
    winopts = {
        height  = 0.90,
        width   = 0.95,
        row     = 0.35,
        col     = 0.50,
        preview = {
            vertical = 'down:45%',
            horizontal = 'right:60%',
        }
    },
    files = {
        rg_opts = "--hidden --files --glob '!.git' --glob '!*.bin' --glob '!*.obj'",
        fd_opts = "--color=never --type f --exclude '*.bin' --exclude '*.obj'",
    },
    grep = {
        rg_glob = true,
        rg_opts =
        "--column --line-number --no-heading --color=always --smart-case --max-columns=512 --glob '!*.bin' --glob '!*.obj'",
    }
})

-- NEOVIM AUTOPAIRS ###############################################################################
require('nvim-autopairs').setup()

-- NEOVIM DEBUG ADAPTER PROTOCOL ##################################################################
-- DOTNET DAP +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
local dap = require("dap")
dap.adapters.coreclr = {
    type = 'executable',
    command = 'netcoredbg',
    args = { '--interpreter=vscode' }
}
dap.configurations.cs = {
    {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
    },
}

-- NEOVIM DEBUG ADAPTER PROTOCOL USER INTERFACE ###################################################
require("dapui").setup()

local dapui = require("dapui")
dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
end

-- NEOVIM TREE ####################################################################################
require("nvim-tree").setup {
    view = {
        width = 40,
        side = "right"
    },
    filters = {
        dotfiles = true,
        git_clean = false,
        no_buffer = false,
        custom = {
            "node_modules",
            ".cache",
            "*.bak",
            "**/bin",
            "**/obj"
        },
    }
}

-- NEOVIM TREESITTER ##############################################################################
require("nvim-treesitter").setup {
    install_dir = vim.fn.stdpath('data') .. '/site'
}

require("nvim-treesitter").install({
    "angular",
    "asm",
    "arduino",
    "bash",
    "c",
    "cpp",
    "css",
    "csv",
    "c_sharp",
    "dockerfile",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "go",
    "godot_resource",
    "html",
    "java",
    "javadoc",
    "javascript",
    "json",
    "latex",
    "lua",
    "luadoc",
    "make",
    "markdown",
    "markdown_inline",
    "meson",
    "nginx",
    "ocaml",
    "python",
    "regex",
    "rust",
    "sql",
    "typescript",
    "vim",
    "vimdoc",
    "yaml"
})

-- NEOVIM LSP #####################################################################################
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- ANGULAR LSP ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
local project_library_path = "/home/umuoiri/.config/nvm/versions/node/v24.16.0/lib"
local cmd = { "ngserver", "--stdio", "--tsProbeLocations", project_library_path, "--ngProbeLocations",
    project_library_path }

vim.lsp.config('angularls', {
    cmd = cmd,
})

-- CSS LSP ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
vim.lsp.config('cssls', {
    capabilities = capabilities,
})

-- HTML LSP +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
vim.lsp.config('html', {
    capabilities = capabilities,
})

-- JSON LSP +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
vim.lsp.config('jsonls', {
    capabilities = capabilities,
})

-- LUA LSP ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
vim.lsp.config('lua_ls', {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath('config')
                and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
            then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                version = 'LuaJIT',
                path = {
                    'lua/?.lua',
                    'lua/?/init.lua',
                },
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
                },
            },
        })
    end,
    settings = {
        Lua = {},
    },
})

-- SQLS +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
local home = vim.fn.expand("$HOME")

vim.lsp.config("sqls", {
    cmd = { home .. "/.local/share/go/bin/sqls" },
})

-- JAVA +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
vim.lsp.config("jdtls", {
    cmd = { home .. "/.local/share/jdtls/bin/jdtls" },
})

-- NEOVIM ENABLED LSP #############################################################################
vim.lsp.enable("angularls")
vim.lsp.enable("arduino_language_server")
vim.lsp.enable("asm_lsp")
vim.lsp.enable("bashls")
vim.lsp.enable("clangd")
vim.lsp.enable("cssls")
vim.lsp.enable("docker_compose_language_service")
vim.lsp.enable("docker_language_server")
vim.lsp.enable("emmet_language_server")
vim.lsp.enable("html")
vim.lsp.enable("jsonls")
vim.lsp.enable("jdtls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("roslyn_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("sqls")
vim.lsp.enable("tsc")

-- SMEAR CURSOR ###################################################################################
require('smear_cursor').setup({
    opts = {
        stiffness = 0.8,
        trailing_stiffness = 0.6,
        stiffness_insert_mode = 0.7,
        trailing_stiffness_insert_mode = 0.7,
        damping = 0.95,
        damping_insert_mode = 0.95,
        distance_stop_animating = 0.5,
    },
})

-- NEOVIM DIAGNOSTICS #############################################################################

vim.diagnostic.handlers["notification"] = {
    show = function(namespace, bufnr, diagnostics, opts)
        local level = opts["notification"].log_level

        local name = vim.diagnostic.get_namespace(namespace).name
        local msg = string.format("%d diagnostics in buffer %d from %s",
            #diagnostics,
            bufnr,
            name)
        vim.notify(msg, level)
    end,
}

vim.diagnostic.config({
    ["notification"] = {
        log_level = vim.log.levels.INFO,
        severity = vim.diagnostic.severity.ERROR,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "🚨",
            [vim.diagnostic.severity.WARN]  = "⚠️",
            [vim.diagnostic.severity.INFO]  = "ℹ️",
            [vim.diagnostic.severity.HINT]  = "🔍",
        },
        linehl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
        },
    },
})

-- AUTOCOMMANDS ===================================================================================
-- Restore last cursor position when reopening a file
local last_cursor_group = vim.api.nvim_create_augroup("LastCursorGroup", {})
vim.api.nvim_create_autocmd("BufReadPost", {
    group = last_cursor_group,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Highlight the yanked text for 200ms
local highlight_yank_group = vim.api.nvim_create_augroup("HighlightYank", {})
vim.api.nvim_create_autocmd("TextYankPost", {
    group = highlight_yank_group,
    pattern = "*",
    callback = function()
        vim.hl.on_yank({
            higroup = "IncSearch",
            timeout = 200,
        })
    end,
})

-- LSP attach handler
vim.api.nvim_create_autocmd("LspAttach", {
    -- Enable auto-completion. Note: Use Ctrl + Y to select an item.
    callback = function(ev)
        -- Auto-format on save
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = ev.buf,
            callback = function()
                vim.lsp.buf.format { async = false, id = ev.data.client_id }
            end,
        })

        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, {
                autotrigger = true,

                convert = function(item)
                    return { abbr = item.label:gsub("%b()", "") }
                end
            })
            vim.keymap.set("i", "<C-space>", vim.lsp.completion.get, { desc = "Trigger autocompletion" })
        end
    end
})

-- Treesitter features
vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "angular",
        "asm",
        "arduino",
        "bash",
        "c",
        "cpp",
        "css",
        "csv",
        "c_sharp",
        "dockerfile",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        "godot_resource",
        "html",
        "java",
        "javadoc",
        "javascript",
        "json",
        "latex",
        "lua",
        "luadoc",
        "make",
        "markdown",
        "markdown_inline",
        "meson",
        "nginx",
        "ocaml",
        "python",
        "regex",
        "rust",
        "sql",
        "typescript",
        "vim",
        "vimdoc",
        "yaml"
    },
    callback = function()
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldmethod = "expr"
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.treesitter.start()
    end,
})

vim.g.omni_sql_no_default_maps = 1
vim.g.omni_sql_default_compl_type = 'syntax'

-- COLORSCHEME ####################################################################################
-- Lua
require('onedark').setup {
    -- Main options --
    style = 'light',              -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
    transparent = true,           -- Show/hide background
    term_colors = true,           -- Change terminal color as per the selected theme style
    ending_tildes = false,        -- Show the end-of-buffer tildes. By default they are hidden
    cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

    -- toggle theme style ---
    toggle_style_key = nil,                                                              -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
    toggle_style_list = { 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light' }, -- List of styles to toggle between

    -- Change code style ---
    -- Options are italic, bold, underline, none
    -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
    code_style = {
        comments = 'italic',
        keywords = 'bold',
        functions = 'bold,italic',
        strings = 'bold',
        variables = 'italic'
    },

    -- Lualine options --
    lualine = {
        transparent = true, -- lualine center bar transparency
    },

    -- Custom Highlights --
    colors = {},     -- Override default colors
    highlights = {}, -- Override highlight groups

    -- Plugins Config --
    diagnostics = {
        darker = true,     -- darker colors for diagnostic
        undercurl = true,  -- use undercurl instead of underline for diagnostics
        background = true, -- use background color for virtual text
    },
}

require('onedark').load()
-- OPTIONS ========================================================================================
-- Basic Settings
vim.opt.number = true              -- Line numbers
vim.opt.relativenumber = true      -- Relative line numbers
vim.opt.cursorline = true          -- Highlight current line
vim.opt.scrolloff = 10             -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8          -- Keep 8 columns left/right of cursor
vim.opt.wrap = false               -- Don't wrap lines
vim.opt.cmdheight = 1              -- Command line height
vim.opt.spelllang = { "en", "de" } -- Set language for spellchecking

-- Tabbing / Indentation
vim.opt.tabstop = 4                -- Tab width
vim.opt.shiftwidth = 4             -- Indent width
vim.opt.softtabstop = 4            -- Soft tab stop
vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.smartindent = true         -- Smart auto-indenting
vim.opt.autoindent = true          -- Copy indent from current line
vim.opt.grepprg = "rg --vimgrep"   -- Use ripgrep if available
vim.opt.grepformat = "%f:%l:%c:%m" -- filename, line number, column, content

-- Search Settings
vim.opt.ignorecase = true -- Case-insensitive search
vim.opt.smartcase = true  -- Case-sensitive if uppercase in search
vim.opt.hlsearch = false  -- Don't highlight search results
vim.opt.incsearch = true  -- Show matches as you type

-- Visual Settings
vim.opt.termguicolors = true  -- Enable 24-bit colors
vim.opt.signcolumn = "number" -- Always show sign column
vim.opt.colorcolumn = "100"   -- Show column at 100 characters
vim.opt.showmatch = true      -- Highlight matching brackets
vim.opt.matchtime = 2         -- How long to show matching bracket
vim.opt.complete:append('i')
vim.opt.complete:append('k')
vim.opt.complete:append('s')
vim.opt.complete:append('o')
vim.opt.autocomplete = true                             -- Enable autocomplete
vim.opt.completeopt = "menuone,noinsert,noselect,popup" -- Completion options
vim.opt.showmode = false                                -- Don't show mode in command line
vim.opt.pumheight = 10                                  -- Popup menu height
vim.opt.pumblend = 10                                   -- Popup menu transparency
vim.opt.winblend = 0                                    -- Floating window transparency
vim.opt.conceallevel = 2                                -- Obsidian requirement
vim.opt.concealcursor = ""                              -- Show markup even on cursor line
vim.opt.synmaxcol = 300                                 -- Syntax highlighting column limit

-- File Handling
vim.opt.backup = false                       -- Don't create backup files
vim.opt.writebackup = false                  -- Don't backup before overwriting
vim.opt.swapfile = false                     -- Don't create swap files
vim.opt.undofile = true                      -- Persistent undo
vim.opt.updatetime = 300                     -- Time in ms to trigger CursorHold
vim.opt.timeoutlen = 500                     -- Time in ms to wait for mapped sequence
vim.opt.ttimeoutlen = 0                      -- No wait for key code sequences
vim.opt.autoread = true                      -- Auto-reload file if changed outside
vim.opt.autowrite = false                    -- Don't auto-save on some events
vim.opt.diffopt:append("vertical")           -- Vertical diff splits
vim.opt.diffopt:append("algorithm:patience") -- Better diff algorithm
vim.opt.diffopt:append("linematch:60")       -- Better diff highlighting (smart line matching)

-- Set undo directory and ensure it exists
local undodir = "~/.local/share/nvim/undodir" -- Undo directory path
vim.opt.undodir = vim.fn.expand(undodir)      -- Expand to full path
local undodir_path = vim.fn.expand(undodir)
if vim.fn.isdirectory(undodir_path) == 0 then
    vim.fn.mkdir(undodir_path, "p") -- Create if not exists
end

-- Behavior Settings
vim.opt.errorbells = false              -- Disable error sounds
vim.opt.backspace = "indent,eol,start"  -- Make backspace behave naturally
vim.opt.autochdir = false               -- Don't change directory automatically
vim.opt.iskeyword:append("-")           -- Treat dash as part of a word
vim.opt.path:append("**")               -- Search into subfolders with `gf`
vim.opt.selection = "inclusive"         -- Use inclusive selection
vim.opt.mouse = "a"                     -- Enable mouse support
vim.opt.mousemodel = "popup"            -- Set the right-click behavior to 'popup'
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard
vim.opt.modifiable = true               -- Allow editing buffers
vim.opt.encoding = "UTF-8"              -- Use UTF-8 encoding
vim.opt.wildmenu = true                 -- Enable command-line completion menu
vim.opt.wildmode = "longest:full,full"  -- Completion mode for command-line
vim.opt.wildignorecase = true           -- Case-insensitive tab completion in commands

-- Folding Settings
vim.opt.foldmethod = "expr"                          -- Use expression for folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- Use treesitter for folding
vim.opt.foldlevel = 99                               -- Keep all folds open by default

-- Split Behavior
vim.opt.splitbelow = true -- Horizontal splits open below
vim.opt.splitright = true -- Vertical splits open to the right

-- KEYMAPS ========================================================================================
-- Quick config editing
vim.keymap.set("n", "<leader>rc", "<Cmd>e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })

vim.keymap.set("n", "j", function()
    return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
    return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

vim.keymap.set("n", "<leader>pa", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    print("file:", path)
end, { desc = "Copy full file path" })

vim.keymap.set("n", "<leader>m", "<Cmd>NvimTreeFocus<CR>", { desc = "Focus on File" })
vim.keymap.set("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

vim.keymap.set("n", "<leader>ff", function() require("fzf-lua").files() end, { desc = "FZF Files" })
vim.keymap.set("n", "<leader>fg", function() require("fzf-lua").live_grep() end, { desc = "FZF Live Grep" })
vim.keymap.set("n", "<leader>fb", function() require("fzf-lua").buffers() end, { desc = "FZF Buffers" })
vim.keymap.set("n", "<leader>fh", function() require("fzf-lua").help_tags() end, { desc = "FZF Help Tags" })
vim.keymap.set("n", "<leader>fx", function() require("fzf-lua").diagnostics_document() end,
    { desc = "FZF Diagnostics Document" })
vim.keymap.set("n", "<leader>fX", function() require("fzf-lua").diagnostics_workspace() end,
    { desc = "FZF Diagnostics Workspace" })

vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, { desc = "Format current buffer" })

vim.keymap.set('i', '<c-space>', function() vim.lsp.completion.get() end, { desc = "Trigger LSP Completion" })
