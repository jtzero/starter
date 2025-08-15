function merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
        merge(t1[k], t2[k])
    else
        t1[k] = v
    end
  end
  return t1
end

function concatTables(t1, t2)
  for _, value in ipairs(t2) do
    table.insert(t1, value)
  end
  return t1
end

Path = {}

Path.relative_to = function(start_point, other)
  local cmmd = 'realpath --relative-to="' .. start_point .. '" "' .. other .. '"'
  return vim.fn.trim(vim.fn.system(cmmd))
end

Path.script_path = function(_)
  local caller_file_relative_to_cwd = debug.getinfo(2, 'S').source:sub(2)
  return vim.fn.fnamemodify(caller_file_relative_to_cwd, ':p:h')
end

Path.dirname = function(filepath)
  if filepath == '' then
    return ''
  end
  return vim.fn.fnamemodify(filepath, ":h")
end

secrets = require('secrets')

vim.fn.findfile(".editorconfig.vim.lua", vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "") .. ";")
EditorConfig = {
  filepath = nil
}
local filepath = vim.fn.findfile(".editorconfig.vim.lua", vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "") .. ";")
if filepath ~= "" then
  EditorConfig.filepath = filepath
  local loader, error = loadfile(filepath)
  local config_func = loader()
  if config_func ~= nil then
    config_func(vim)
  end
end
-- old may not be needed anymore
local enable_providers = {
  "python3_provider",
  "node_provider",
  "ruby_provider",
  -- and so on
}
for _, plugin in pairs(enable_providers) do
  vim.g["loaded_" .. plugin] = nil
  vim.cmd("runtime " .. plugin)
end

local ssh_config_filepath = os.getenv("HOME") .. "/.ssh/config"
local my_ssh_config_found = io.open(os.getenv("HOME") .. "/.ssh/config", "r"):read("*a"):find("-mine") -- if it finds it, it will return the index, if not it will return nil

  -- nvchad/starter defaults
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local map = vim.keymap.set
        local opts = { buffer = buffer, noremap = true, silent = true, desc = "Gitsigns blame_line" }
        map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, opts)
      end,
    },
  },
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    enabled = false,
    opts = require "configs.conform",
  },
  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    keys = {
      -- Already defined somewhere
      --{ "<C-W>d", function() vim.diagnostic.open_float() end, desc = "Show line diagnostics", noremap = true, silent = false },
      { "<C-W>s", function() vim.lsp.buf.signature_help() end, desc = "Show signature help", noremap = true },
    },
    config = function()
      require "configs.lspconfig"
      if EditorConfig.filepath ~= nil then
        local async = require("plenary.async")
        async.run(function()
          vim.lsp.buf.add_workspace_folder(Path.dirname(EditorConfig.filepath))
        end)
      end
    end,
  },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
  -- nvchad/starter defaults end
  -- nvchad overrides
  { "lukas-reineke/indent-blankline.nvim", enabled = false }, -- highlights blocks and provides vertical lines on indent
  { "windwp/nvim-autopairs", enabled = false }, -- auto createes closing paren bracket quote etc
  {
    "hrsh7th/nvim-cmp",
    lazy = true,
    event = "VimEnter",
    opts = function(_, opts)
      local cmp = require('cmp')
      opts.mapping["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = false,
      }
      -- opt.preselect = cmp.PreselectMode.None
      opts.completion.completeopt = "menu,menuone,noselect" --stop auotselecting the first item in the snippets
      -- completeopt= "menu,menuone,noinsert,noselect",

      return opts
    end
  },
  {
    "NvChad/ui",
    config = function()
      require "nvchad"
      vim.opt.statusline=""
    end
  },
  {
    "NvChad/nvim-colorizer.lua",
    enabled = false,
    lazy = true,
    opts = {
      filetypes = {
        '*',
        '!cmp_menu',
        '!toml',
        '!python',
      },
      --buftypes = {}
    }
  },
  -- end nvchad overrides
  {
    'jtzero/go-to-test-file.nvim',
    lazy = false,
    config = true,
    opts = {
      print_main_command_result = true
    },
    keys = {
      {
        '<M-T>',
        '<cmd>FindTestOrSourceCodeFileWithFallback<CR>',
        mode = { "n" },
        desc = 'Opens a corresponding test file or source file if not found opens the test folder',
      },
    },
  },
  -- folding zo, zc for open and close
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async'},
    lazy = true,
    event = "VimEnter", -- needed for folds to load in time and comments closed
		keys = {
			-- stylua: ignore start
			{ "zm", function() require("ufo").closeAllFolds() end, desc = " 󱃄 Close All Folds" },
			{ "zr", function() require("ufo").openFoldsExceptKinds { "comment", "imports" } end, desc = " 󱃄 Open All Regular Folds" },
			{ "zR", function() require("ufo").openFoldsExceptKinds {} end, desc = " 󱃄 Open All Folds" },
			{ "z1", function() require("ufo").closeFoldsWith(1) end, desc = " 󱃄 Close L1 Folds" },
			{ "z2", function() require("ufo").closeFoldsWith(2) end, desc = " 󱃄 Close L2 Folds" },
			{ "z3", function() require("ufo").closeFoldsWith(3) end, desc = " 󱃄 Close L3 Folds" },
			{ "z4", function() require("ufo").closeFoldsWith(4) end, desc = " 󱃄 Close L4 Folds" },
			-- stylua: ignore end
		},
    init = function()
			-- INFO fold commands usually change the foldlevel, which fixes folds, e.g.
			-- auto-closing them after leaving insert mode, however ufo does not seem to
			-- have equivalents for zr and zm because there is no saved fold level.
			-- Consequently, the vim-internal fold levels need to be disabled by setting
			-- them to 99
			vim.opt.foldlevel = 99
			vim.opt.foldlevelstart = 99
		end,
		opts = {
			provider_selector = function(_, ft, _)
				-- INFO some filetypes only allow indent, some only LSP, some only
				-- treesitter. However, ufo only accepts two kinds as priority,
				-- therefore making this function necessary :/
				local lspWithOutFolding = { "markdown", "sh", "css", "html", "python" }
				if vim.tbl_contains(lspWithOutFolding, ft) then return { "treesitter", "indent" } end
				return { "lsp", "indent" }
			end,
			-- when opening the buffer, close these fold kinds
			-- use `:UfoInspect` to get available fold kinds from the LSP
			close_fold_kinds_for_ft = {
        default = { "imports", "comment" },
      },
			open_fold_hl_timeout = 800,
			--fold_virt_text_handler = foldTextFormatter,
		},
  },
  { "mikavilpas/yazi.nvim",
    lazy = true,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    keys = {
      {
        -- Open in the current working directory
        "<M-o>",
        function()
          require("yazi").yazi(nil, vim.fn.expand("%:."))
        end,
        desc = "Open the file manager in current folder of the file" ,
      },
      {
        "<leader>cw", "<cmd>Yazi cwd<cr>",
        desc = "Open in the current working directory" ,
      },
      --{
        -- NOTE: this requires a version of yazi that includes
        -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
        --'<c-up>',
        --"<cmd>Yazi toggle<cr>",
        --desc = "Resume the last yazi session",
      --},
    },
    opts = {
      open_for_directories = true,
      open_file_function = function(chosen_file, config, state)
        local openers = require("yazi.openers")
        local rel_path_chosen_file = Path.relative_to(vim.fn.getcwd(), chosen_file)
        openers.open_file(rel_path_chosen_file, config, state)
      end,
    },
  },
  -- :NvCheatsheet print a cheatsheet
  { "folke/which-key.nvim",
    enabled = true,
    lazy = true,
    event = "VimEnter",
  },
  { dir = "~/dev_setup/var/fzf", name = "fzf-source" },
  {
    "junegunn/fzf.vim",
    lazy = false,
    dependencies = {
      "fzf-source"
    },
    keys = {
      { "<M-O>", "<cmd>Files<CR>", desc = "FZF filter all files", noremap = true },
      { "<M-H>", "<cmd>History<CR>", desc = "FZF comamnd history", noremap = true },
      { "<leader>o", "<cmd>GFiles<CR>", desc = "FZF Git Files", noremap = true }
    }
  },
  -- TODO dark theme switching
  {
  "f-person/auto-dark-mode.nvim",
    enabled = false,
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd("colorscheme gruvbox")
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd("colorscheme gruvbox")
      end,
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      { "arcticicestudio/nord-vim", name = "nord", lazy = true },
      { "dracula/vim", name = "dracula", lazy = false },
      { "skbolton/embark", name = "embark", lazy = true },
    },
    -- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
    -- https://github.com/neanias/everforest-nvim -- has a lualine theme
    opts = function(_plugin)
      local theme = os.getenv("THEME")
      if theme == "" or theme == nil then
        theme="dracula"
      end
      return {
        options = {
          icons_enabled = true,
          theme = theme,
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {{'filename', path = 1}},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      }
    end
  },
  -- ================= Language
  -- mason.vim controls languages :Mason
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      auto_install = true,
      highlight = {
        enable = true,
        use_languagetree = true,
        disable = { "python" },
      },
      indent = {
        enable = true,
        disable = {"ruby"}
      },
    },
  },
  {
    "wookayin/semshi",
    lazy = true,
    ft = 'python',
    build = ":UpdateRemotePlugins",
    config = function(_plugin)
      vim.g["semshi#always_update_all_highlights"] = 1
    end
  },
  { "ntpeters/vim-better-whitespace" },
  -- https://github.com/dense-analysis/ale/issues/4497
  --{
  --  "Shopify/ruby-lsp",
  --  lazy = true,
  --  ft = 'ruby'
  --},
  {
    "jtzero/ale",
    lazy = false,
    keys = {
      --{"<C-L>", "<Plug>(ale_fix)", desc = "Runs the fixers in ale", noremap = true},
      {"<C-L>", "<cmd>ALEFix<CR>", desc = "Runs the fixers in ale", noremap = true},
      {"<M-B>", "<cmd>ALEGoToDefinition<CR>", desc = "Finds the definition", noremap = true},
    },
    config = function(_plugins)
      vim.g["airline#extensions#ale#enabled"] = 1
      vim.g["ale_fix_on_save"] = 1
      -- If true or 1, disables ALE's built in error display.
      -- and switches to using Neovim's built in diagnostics.
      vim.g["ale_use_neovim_diagnostics_api"] = 1
      --When |g:ale_use_neovim_diagnostics_api| is `1`, the only other setting that
      --will be respected for signs is |g:ale_sign_priority|.
      --vim.g["ale_set_signs"] = 1 -- with this make the depcrecation go away? - nope

      vim.g["ale_typescript_tslint_use_global"] = 0

      vim.g["ale_lua_luacheck_options"] = '--ignore 21/_.*'


      vim.g["ale_python_pylint_change_directory"] = 1
      vim.g["ale_python_mypy_change_directory"] = 1
      vim.g["ale_python_flake8_change_directory"] = 1
      vim.g["ale_python_mypy_auto_poetry"] = 1
      --vim["g.ale_python_mypy_use_global"] = 1
      vim.g["ale_python_auto_pipenv"] = 1
      vim.g["ale_python_auto_poetry"] = 1
      vim.g["ale_python_auto_uv"] = 1

      -- is this needed because of above ?
      vim.g["ale_python_ruff_auto_pipenv"] = 1
      vim.g["ale_python_ruff_auto_poetry"] = 1
      vim.g["ale_python_ruff_auto_uv"] = 1
      -- they added check but ale doesn;t use it or, doesn't use it on the version I have to pinned, works for fixer as well
      vim.g["ale_python_ruff_options"] = 'check'


      if os.getenv("ALE_PYTHON_POETRY") == nil or os.getenv("ALE_PYTHON_POETRY") == "true"
      then
        local poetry_env_path = vim.fn.trim(vim.fn.system("poetry env info --path"))
        if(poetry_env_path == "" or poetry_env_path == ".")
        then
          local version = vim.fn.trim(vim.fn.system("poetry env info | grep 'Python:' | tr -s ' ' | cut -d' ' -f2 | head -n 1"))
          vim.fn.system('poetry env use ' .. version)
          poetry_env_path = vim.fn.trim(vim.fn.system('poetry env info --path'))
          vim.fn.setenv("VIRTUAL_ENV", poetry_env_path)
          -- vim.g["ale_python_pyright_config"] = {
          --   venvPath = vim.fn.trim(vim.fn.system('poetry config virtualenvs.path')),
          --   venv = vim.fs.basename(path)
          -- }
        end
      end

      local rtp_ext = Path.dirname(Path.script_path()) .. "/../ext"
      vim.opt.runtimepath:append(',' .. rtp_ext)
      vim.cmd.execute("ale#fix#registry#Add('dynamic-rubocop', 'ale#fixers#dynamic_rubocop#Fix', ['ruby'], 'dynamic rubocop')")

      vim.g["ale_ruby_syntax_tree_options"] = "--print-width=100"
      vim.g["ale_ruby_rubocop_auto_correct_all"] = 0

      vim.g["ale_sh_shellcheck_options"] = "-o check-extra-masked-returns" ..
        " -o require-variable-braces" ..
        " -o check-set-e-suppressed" ..
        " -o deprecate-which" ..
        " -o quote-safe-variables" ..
        " -o require-variable-braces"

      --By default, all available tools for all supported languages will be run.
      vim.g["ale_linters"] = {
        proto = {'buf-lint'},
        vue = {'vtsls', 'eslint'}, -- for some reason volar is not on by default -- ale only works with v1
      }
      vim.g["ale_ruby_sorbet_executable"] = '' -- ignoring isn;t working ???
      vim.g["ale_linters_ignore"] = {
        ruby = {'rubocop', 'debride', 'sorbet', 'srb'}, -- sorbet spams the messages
      }
      -- the asterisk is the default case
      -- It works even if not explicitly added to a language
      vim.g["ale_fixers"] = {
        ["*"] = {"remove_trailing_lines", "trim_whitespace"},
        javascript = {"eslint", "trim_whitespace", "prettier"},
        vue = {"prettier"},
        typescript = {"eslint", "tslint", "prettier"},
        python = {"black", "reorder-python-imports", "ruff_format", "ruff"},
        terraform = {"terraform", "trim_whitespace"},
        hcl = {"terraform", "trim_whitespace"},
        ruby = {
          -- found this to be obtuse in it's formatting
          -- updating the print-width improved it
          -- https://github.com/ruby-syntax-tree/syntax_tree/issues/407
          -- nested iterators become a single line
          -- https://github.com/ruby-syntax-tree/syntax_tree/issues/406
          --"syntax_tree", -- https://github.com/ruby-syntax-tree/syntax_tree#write -- this works in conjunction with rubocop only if listed first?
          --"prettier", -- is just syntax_tree?
          "rufo", -- see notion about formatting conflicts
          --"rubocop",
          "dynamic-rubocop", -- dynamically determines if bundle is needed
          --"sorbet", -- will replace constants I.E. SyntaxTree to SyntaxError, because
                      -- it needs to be ran with bundle exec, but it cannot because then it
                      -- would have to be added to the gemfile
          "standardrb",
        }
      }
      vim.api.nvim_create_autocmd("VimResume", { pattern = "*", command = "ALELint" })
    end
  },
  {
    "maxmellon/vim-jsx-pretty",
    build = ":UpdateRemotePlugins",
    ft = 'jsx'
  },
  {
    "psf/black",
    ft = "python",
    config = function(_plugin)
      vim.g.black_virtualenv = vim.g.vim_venv
    end
  },
  { "vim-ruby/vim-ruby", ft = "ruby" },
  { "cespare/vim-toml", ft = "toml" },
  { "yuezk/vim-js", ft = "javascript" },
  -- seems to override tf ?
  --{ "jvirtanen/vim-hcl", ft = "hcl" },
  { "hashivim/vim-terraform", ft = "terraform" },
  -- ================ experimental
  {
    "vim-test/vim-test",
    lazy = true,
  },
  {
    "mg979/vim-visual-multi",
    lazy = true,
    event = 'VeryLazy',
    config = function(_plugin)
      --vim.g.VM_maps = {} -- vim.fn.get("g:", "VM_maps", {}) -- set mapping to nothing
    end
  },

  --{ "dstein64/vim-startuptime", lazy = false }

  -- jupyter notebook WIP
  --pip install notedown
  --Plug 'szymonmaszke/vimpyter'

  { "nvim-telescope/telescope-project.nvim", lazy = true},
  --- AI
  -- avante cannot replace auto-suggestions because it is currently experimental
  -- issues changing my email
  -- how do I log this in ?
  {
    "supermaven-inc/supermaven-nvim",
    enabled = true,
    lazy = false,
    cond = function()
      return secrets.suggestion.name == 'supermaven'
    end,
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<C-f>",
          clear_suggestion = "<C-z>",
          accept_word = '<C-g>',
          next = '<C-Right>',
          previous = '<C-Left>',
        },
      })
    end,
  },
  -- this has a lualine option
  {
    'milanglacier/minuet-ai.nvim',
    enabled = true,
    lazy = true,
    event = { 'BufReadPre', 'BufNewFile' }, -- Activate when a file is created/opened
    --event = "InsertEnter", -- not sure why but above is better
    cond = function()
      vim.fn.setenv('AVANTE_GEMINI_API_KEY', secrets.suggestion.key)
      return secrets.suggestion.name == 'gemini'
    end,
    config = function()
      require('minuet').setup {
        provider = secrets.suggestion.name,
        cmp = {
          enable_auto_complete = false,
        },
        blink = {
          enable_auto_complete = false,
        },
        virtualtext = {
          auto_trigger_ft = { '*' },
          keymap = {
              -- accept whole completion
              accept = '<C-f>',
              -- accept one line
              accept_line = '<C-g>',
              -- accept n lines (prompts for number)
              -- e.g. "A-z 2 CR" will accept 2 lines
              accept_n_lines = '<A-z>',
              -- Cycle to prev completion item, or manually invoke completion
              prev = '<C-Left>',
              -- Cycle to next completion item, or manually invoke completion
              next = '<C-Right>',
              dismiss = '<C-z>',
          },
        },
        provider_options = {
          gemini = {
            stream = true,
            api_key = function() return secrets.suggestion.key end,
          }
        }
      }
    end,
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      -- optional, if you are using virtual-text frontend, nvim-cmp is not
      -- required.
      { 'Saghen/blink.cmp' },
    },
  },
  {
    "yetone/avante.nvim",
    enabled = true,
    event = "VeryLazy",
    version = false, -- set this if you want to always pull the latest change
    cond = function()
      return secrets.chat.name == 'copilot' or secrets.chat.name == 'gemini'
    end,
    opts = {
      provider = secrets.chat.name,
      -- add any opts here
      mode = "agentic", -- The default mode for interaction. "agentic" uses tools to automatically generate code, "legacy" uses the old planning method to generate code.
      -- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
      -- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
      -- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
      -- auto_suggestions in avante are experimental so it's off by default -- behavior.auto_suggestions
      -- can use copilot.lua to provide the functionality directly. Or supermaven, etc
      --auto_suggestions_provider = ""
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        "zbirenbaum/copilot.lua", -- for providers='copilot' -- improved over copilot.vim
        enabled = secrets.chat.name == 'copilot',
        lazy = true,
        cmd = "Copilot",
        event = "InsertEnter",
        -- this was for copilot.vim
        --init = function(_plugin)
        --  vim.g.copilot_no_tab_map = true
        --  vim.g.copilot_assume_mapped = true
        --  vim.g.copilot_tab_fallback = ""
          --vim.api.nvim_set_keymap("i", "<C-f>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
        --end,
        opts = {
          suggestion = {
            auto_trigger = true,
            hide_during_completion = false,
            -- debounce = 75, -- default
            keymap = {
              accept = '<C-f>',
              accept_word = '<C-g>',
              next = '<C-Right>',
              previous = '<C-Left>',
            },
          },
        },
      },

      {
        -- support for image pasting
        -- seems to be hooked into the clipboard/cmd+P
        "HakonHarnes/img-clip.nvim",
        enabled = false,
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  }
}
