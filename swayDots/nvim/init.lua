-- ~/.config/nvim/init.lua
-- Persistent undo configuration

-- =============================================
-- PERSISTENT UNDO & FILE RECOVERY
-- =============================================

-- Enable persistent undo (saves undo history across sessions)
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undo//"
vim.opt.undolevels = 1000  -- Max number of changes that can be undone
vim.opt.undoreload = 10000 -- Max lines to save for undo on reload

-- Create undo directory if it doesn't exist
local undo_dir = vim.fn.stdpath('data') .. '/undo'
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, 'p')
  print("✓ Created undo directory: " .. undo_dir)
end

-- Enable swap files for crash recovery
vim.opt.swapfile = true
vim.opt.directory = os.getenv("HOME") .. "/.local/share/nvim/swap//"
vim.opt.updatecount = 50  -- Save swap file every 50 characters typed

-- Backup files
vim.opt.backup = true
vim.opt.backupdir = os.getenv("HOME") .. "/.local/share/nvim/backup//"
vim.opt.writebackup = true

-- Create backup and swap directories
local function ensure_dir(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, 'p')
  end
end

ensure_dir(vim.fn.stdpath('data') .. '/swap')
ensure_dir(vim.fn.stdpath('data') .. '/backup')

-- =============================================
-- UNDO MANAGEMENT COMMANDS
-- =============================================

-- Clear undo history for current buffer
vim.keymap.set('n', '<leader>uc', ':w | :set ul=-1 | :set ul=1000<CR>',
  { desc = 'Clear undo history' })

-- View undo information
vim.keymap.set('n', '<leader>ui', function()
  print("Undo levels: " .. vim.opt.undolevels:get())
  print("Undo files in: " .. vim.opt.undodir:get())
end, { desc = 'Show undo info' })

-- =============================================
-- RECOVERY & SESSION MANAGEMENT
-- =============================================

-- Auto-save session on exit
vim.api.nvim_create_autocmd('VimLeave', {
  callback = function()
    -- Save view (cursor position, folds, etc.)
    vim.cmd('mkview!')
  end
})

-- Auto-restore view on enter
vim.api.nvim_create_autocmd('BufRead', {
  callback = function()
    vim.cmd('silent! loadview')
  end
})

-- Recover from swap file on startup
vim.api.nvim_create_autocmd('SwapExists', {
  callback = function(args)
    local choice = vim.fn.confirm(
      "Swap file exists for " .. args.file .. "\n(R)ecover, (Q)uit, (A)bort, (D)elete, (O)pen read-only?",
      "rqado",
      1
    )
    if choice == 1 then     -- Recover
      vim.cmd('recover ' .. args.file)
      vim.cmd('edit ' .. args.file)
    elseif choice == 2 then -- Quit
      vim.cmd('quit')
    elseif choice == 3 then -- Abort
      vim.cmd('echo "Swap file warning aborted"')
    elseif choice == 4 then -- Delete
      vim.fn.delete(args.file)
      vim.cmd('edit ' .. args.file)
    elseif choice == 5 then -- Open read-only
      vim.cmd('edit ' .. args.file)
      vim.bo.modifiable = false
    end
  end
})

-- =============================================
-- VIEW SETTINGS (remembers cursor, folds, etc.)
-- =============================================
vim.opt.viewdir = os.getenv("HOME") .. "/.local/share/nvim/view//"
vim.opt.viewoptions = 'folds,cursor,curdir,slash,unix'

-- =============================================
-- BASIC EDITOR SETTINGS
-- =============================================
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = '↪ '
vim.opt.spell = true
vim.opt.spelllang = 'en_us'
vim.opt.textwidth = 0  -- Dynamic wrapping
vim.opt.clipboard = 'unnamedplus'

-- Transparent background
vim.cmd([[
  colorscheme default
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NonText guibg=NONE ctermbg=NONE
  highlight LineNr guibg=NONE ctermbg=NONE
]])

-- =============================================
-- KEYBINDINGS
-- =============================================

-- File operations
vim.keymap.set('n', '<C-s>', ':w<CR>')
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a')
vim.keymap.set('n', '<C-x>', ':q!<CR>')
vim.keymap.set('n', '<C-q>', ':wq<CR>')

-- Clipboard
vim.keymap.set('n', '<C-a>', 'ggVG')
vim.keymap.set('v', '<C-c>', '"+y')
vim.keymap.set('n', '<C-v>', '"+P')
vim.keymap.set('i', '<C-v>', '<C-r>+')

-- Undo/Redo with persistent support
vim.keymap.set('n', '<C-z>', 'u', { desc = 'Undo (persistent)' })
vim.keymap.set('n', '<C-y>', '<C-r>', { desc = 'Redo (persistent)' })

-- =============================================
-- SPELL CHECK CONFIGURATION
-- =============================================

-- Auto-enable spell check for text files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'text', 'markdown', 'gitcommit', 'mail' },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
  end
})

-- Spelling shortcuts
vim.keymap.set('n', '<leader>s', ']s', { desc = 'Next spelling error' })
vim.keymap.set('n', '<leader>S', '[s', { desc = 'Previous spelling error' })
vim.keymap.set('n', '<leader>z', 'z=', { desc = 'Show spelling corrections' })
vim.keymap.set('n', '<leader>tg', ':set spell!<CR>', { desc = 'Toggle spell check' })

-- =============================================
-- TEXT COMPLETION
-- =============================================

-- Ctrl+N - Word completion
vim.keymap.set('i', '<C-n>', '<C-x><C-n>', { desc = 'Word completion' })
vim.keymap.set('i', '<C-p>', '<C-x><C-p>', { desc = 'Previous completion' })

-- Ctrl+Space - Trigger completion
vim.keymap.set('i', '<C-Space>', '<C-n>', { desc = 'Trigger completion' })


-- =============================================
-- KEYBIND VIEWER
-- =============================================

-- Function to display all keybindings
local function show_keybindings()
  local keymaps = vim.api.nvim_get_keymap('n')  -- Normal mode
  local keymaps_i = vim.api.nvim_get_keymap('i')  -- Insert mode
  local keymaps_v = vim.api.nvim_get_keymap('v')  -- Visual mode
  
  -- Create a new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {}
  
  -- Header
  table.insert(lines, "╔════════════════════════════════════════════════════════════════╗")
  table.insert(lines, "║                    YOUR CUSTOM KEYBINDINGS                     ║")
  table.insert(lines, "╚════════════════════════════════════════════════════════════════╝")
  table.insert(lines, "")
  
  -- Normal Mode Keybindings
  table.insert(lines, "━━━ NORMAL MODE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  table.insert(lines, "")
  table.insert(lines, "📁 FILE OPERATIONS:")
  table.insert(lines, "  <C-s>         → Save file")
  table.insert(lines, "  <C-x>         → Quit without saving")
  table.insert(lines, "  <C-q>         → Save and quit")
  table.insert(lines, "")
  table.insert(lines, "📋 CLIPBOARD:")
  table.insert(lines, "  <C-a>         → Select all")
  table.insert(lines, "  <C-v>         → Paste from system clipboard")
  table.insert(lines, "")
  table.insert(lines, "↩️  UNDO/REDO:")
  table.insert(lines, "  <C-z>         → Undo (persistent)")
  table.insert(lines, "  <C-y>         → Redo (persistent)")
  table.insert(lines, "  <leader>u     → Toggle undo tree")
  table.insert(lines, "  <leader>uc    → Clear undo history")
  table.insert(lines, "  <leader>ui    → Show undo info")
  table.insert(lines, "")
  table.insert(lines, "🔍 TELESCOPE (FUZZY FINDER):")
  table.insert(lines, "  <leader>ff    → Find files")
  table.insert(lines, "  <leader>fg    → Live grep (search in files)")
  table.insert(lines, "  <leader>fb    → Find buffers")
  table.insert(lines, "  <leader>fh    → Help tags")
  table.insert(lines, "  <leader>ds    → Document symbols")
  table.insert(lines, "")
  table.insert(lines, "📝 LSP (CODE NAVIGATION):")
  table.insert(lines, "  gd            → Go to definition")
  table.insert(lines, "  gD            → Go to declaration")
  table.insert(lines, "  gi            → Go to implementation")
  table.insert(lines, "  gr            → Show references")
  table.insert(lines, "  K             → Hover documentation")
  table.insert(lines, "  <C-k>         → Signature help")
  table.insert(lines, "  <space>rn     → Rename symbol")
  table.insert(lines, "  <space>ca     → Code action")
  table.insert(lines, "  <space>f      → Format document")
  table.insert(lines, "  <space>D      → Type definition")
  table.insert(lines, "  <space>e      → Show line diagnostics")
  table.insert(lines, "")
  table.insert(lines, "🐛 DIAGNOSTICS:")
  table.insert(lines, "  [d            → Previous diagnostic")
  table.insert(lines, "  ]d            → Next diagnostic")
  table.insert(lines, "  <space>q      → Set loclist")
  table.insert(lines, "")
  table.insert(lines, "🔧 WORKSPACE:")
  table.insert(lines, "  <space>wa     → Add workspace folder")
  table.insert(lines, "  <space>wr     → Remove workspace folder")
  table.insert(lines, "  <space>wl     → List workspace folders")
  table.insert(lines, "")
  table.insert(lines, "✍️  SPELLING:")
  table.insert(lines, "  <leader>s     → Next spelling error")
  table.insert(lines, "  <leader>S     → Previous spelling error")
  table.insert(lines, "  <leader>z     → Show spelling corrections")
  table.insert(lines, "  <leader>tg    → Toggle spell check")
  table.insert(lines, "")
  table.insert(lines, "━━━ INSERT MODE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  table.insert(lines, "")
  table.insert(lines, "  <C-s>         → Save file")
  table.insert(lines, "  <C-v>         → Paste from system clipboard")
  table.insert(lines, "  <C-n>         → Word completion (forward)")
  table.insert(lines, "  <C-p>         → Word completion (backward)")
  table.insert(lines, "  <C-Space>     → Trigger completion")
  table.insert(lines, "")
  table.insert(lines, "━━━ VISUAL MODE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  table.insert(lines, "")
  table.insert(lines, "  <C-c>         → Copy to system clipboard")
  table.insert(lines, "")
  table.insert(lines, "━━━ COMMAND LINE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  table.insert(lines, "")
  table.insert(lines, "  :Mason        → Open Mason package manager")
  table.insert(lines, "  :Telescope    → Open Telescope")
  table.insert(lines, "  :UndotreeToggle → Toggle undo tree")
  table.insert(lines, "")
  table.insert(lines, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  table.insert(lines, "")
  table.insert(lines, "💡 NOTE: <leader> is typically the space key or backslash (\\)")
  table.insert(lines, "")
  table.insert(lines, "Press 'q' or <Esc> to close this window")
  
  -- Set the lines in the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Make buffer read-only
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  
  -- Open in a new split
  vim.cmd('split')
  vim.api.nvim_win_set_buf(0, buf)
  
  -- Set window options
  vim.api.nvim_win_set_option(0, 'number', false)
  vim.api.nvim_win_set_option(0, 'relativenumber', false)
  vim.api.nvim_win_set_option(0, 'cursorline', true)
  
  -- Add keybindings to close the buffer
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':q<CR>', { noremap = true, silent = true })
  
  -- Add syntax highlighting
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
end

-- Keybinding to show all keybindings
vim.keymap.set('n', '<leader>?', show_keybindings, { desc = 'Show all keybindings' })
vim.keymap.set('n', '<F1>', show_keybindings, { desc = 'Show all keybindings' })


-- =============================================
-- LAZY.NVIM PACKAGE MANAGER SETUP
-- =============================================

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Installing lazy.nvim...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  print("✓ Installed lazy.nvim package manager")
  print("Please restart Neovim to complete setup.")
  return 
end
vim.opt.rtp:prepend(lazypath)

-- =============================================
-- PLUGIN SPECIFICATIONS
-- =============================================

local plugins = {
  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "bashls",
          "rust_analyzer",
          "ts_ls",
          "html",
          "cssls",
          "jsonls",
          "yamlls",
          "csharp_ls",
          "clangd",
        },
        automatic_installation = true,
      })
    end
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.schedule(function()
              vim.api.nvim_put({ args.body }, "c", true, true)
            end)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })

      -- Use buffer source for `/` and `?`
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':'
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    end
  },

  -- LSP UI Enhancements
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
        ui = {
          border = "rounded",
          title = true,
          winblend = 0,
          expand = "",
          collapse = "",
          code_action = "💡",
          incoming = " ",
          outgoing = " ",
          hover = ' ',
          kind = {},
        },
      })
    end,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
    }
  },

  -- Treesitter (syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "python", "bash", "rust", "javascript", "typescript",
          "html", "css", "json", "yaml", "c_sharp", "cpp", "c", "markdown",
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
      })

      -- Keybindings for Telescope
      local builtin = require("telescope.builtin")
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
      vim.keymap.set('n', 'gr', builtin.lsp_references, { desc = 'LSP references' })
      vim.keymap.set('n', 'gd', builtin.lsp_definitions, { desc = 'LSP definitions' })
      vim.keymap.set('n', 'gi', builtin.lsp_implementations, { desc = 'LSP implementations' })
      vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, { desc = 'Document symbols' })
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
      })
    end,
  },

  -- Commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Undotree
  {
    "mbbill/undotree",
    config = function()
      vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Toggle undo tree' })
    end,
  },
}

require("lazy").setup(plugins)

-- =============================================
-- LSP CONFIGURATION (UPDATED FOR NVIM 0.11+)
-- =============================================

-- Common LSP capabilities
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

-- Common LSP on_attach function
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  -- Navigation
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)

  -- Workspace
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)

  -- Code actions
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)

  -- Diagnostics
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, bufopts)

  -- Formatting
  vim.keymap.set('n', '<space>f', function()
    vim.lsp.buf.format { async = true }
  end, bufopts)

  -- Type definition
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)

  -- References
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

  -- Show line diagnostics
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, bufopts)
end

-- Configure language servers using vim.lsp.config (NEW API)
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      }
    }
  },
  pyright = {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    }
  },
  bashls = {},
  rust_analyzer = {},
  ts_ls = {},  -- Changed from tsserver
  html = {},
  cssls = {},
  jsonls = {},
  yamlls = {},
  csharp_ls = {},
  clangd = {},
}

-- Setup each server using the NEW vim.lsp.config API
for server_name, config in pairs(servers) do
  -- Merge the server-specific config with common settings
  local server_config = vim.tbl_deep_extend("force", {
    on_attach = on_attach,
    capabilities = capabilities,
    single_file_support = true,
  }, config)
  
  -- Use vim.lsp.config instead of lspconfig
  vim.lsp.config(server_name, server_config)
  
  -- Enable the server
  vim.lsp.enable(server_name)
end

-- =============================================
-- DIAGNOSTICS CONFIGURATION
-- =============================================

vim.diagnostic.config({
  virtual_text = {
    source = "if_many",
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Show line diagnostics automatically in hover
vim.o.updatetime = 250
vim.cmd([[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
