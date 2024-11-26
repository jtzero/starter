local filepath = debug.getinfo(1).source:match("@?(.*/)") .. 'secrets'
if vim.fn.filereadable(filepath) == 1 then
  local file = io.open(filepath, "rb") -- r read mode and b binary mode
  local content = file:read "*a" -- *a or *all reads the whole file
  GITLAB_TOKEN=content:gmatch('=(.+)')(1)
  file:close()
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

local ssh_config_filepath = os.getenv("HOME") .. "/.ssh/config"
local my_ssh_config_found = io.open(os.getenv("HOME") .. "/.ssh/config", "r"):read("*a"):find("-mine") -- if it finds it, it will return the index, if not it will return nil

  -- nvchad/starter defaults
return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    enabled = false,
    opts = require "configs.conform",
  },
  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
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
  -- `setl bufhidden=delete | buffer! #`
  -- :bd closes all windows by default, this overrides that
  -- needed when closing ranger to autoclose Process exited 0
  {
    "rbgrouleff/bclose.vim",
    lazy = false,
    config = function(_plugin)
      vim.cmd("cnoreabbrev bd Bclose")
      -- closing netrw; bclose might also help with this?
      vim.g.netrw_fastbrowse = 0
    end
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
    "dense-analysis/ale",
    lazy = false,
    keys = {
      --{"<C-L>", "<Plug>(ale_fix)", desc = "Runs the fixers in ale", noremap = true},
      {"<C-L>", "<cmd>ALEFix<CR>", desc = "Runs the fixers in ale", noremap = true},
      {"<M-B>", "<cmd>ALEGoToDefinition<CR>", desc = "Finds the definition", noremap = true},
    },
    config = function(_plugins)
      vim.g["airline#extensions#ale#enabled"] = 1
      vim.g["ale_fix_on_save"] = 1
      vim.g["ale_use_neovim_diagnostics_api"] = 1
      --vim.g["ale_set_signs"] = 1

      vim.g["ale_typescript_tslint_use_global"] = 0
      vim.g["ale_lua_luacheck_options"] = '--ignore 21/_.*'


      vim.g["ale_python_pylint_change_directory"] = 1
      vim.g["ale_python_mypy_change_directory"] = 1
      vim.g["ale_python_flake8_change_directory"] = 1
      vim.g["ale_python_mypy_auto_poetry"] = 1
      --vim["g.ale_python_mypy_use_global"] = 1
      vim.g["ale_python_auto_pipenv"] = 1
      vim.g["ale_python_auto_poetry"] = 1

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
        python = {"black", "reorder-python-imports"},
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

  { "nvim-telescope/telescope-project.nvim", lazy = true },
  -- ================
  -- After installation and configuration, you will need to authenticate with Codeium.
  -- This can be done by running :Codeium Auth, copying the token from your browser
  -- and pasting it into API token request.
  -- ctrl [ to loop through the suggestions
  {
    "Exafunction/codeium.nvim",
    lazy = true,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("codeium").setup({
        })
    end
  },
  -- can chat with ollama
  -- https://github.com/Robitx/gp.nvim
  -- {
  --  "robitx/gp.nvim",
  --  config = function()
  --      local conf = {
            -- For customization, refer to Install > Configuration in the Documentation/Readme
  --      }
  --      require("gp").setup(conf)

        -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
  --  end,
  --}
  {
    'git@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git',
    enabled = false,
    event = { 'BufReadPre', 'BufNewFile' }, -- Activate when a file is created/opened
    ft = { 'go', 'javascript', 'python', 'ruby' }, -- Activate when a supported filetype is open
    cond = function()
      return GITLAB_TOKEN ~= nil and GITLAB_TOKEN ~= '' -- Only activate is token is present in environment variable (remove to use interactive workflow)
    end,
    opts = {
      statusline = {
        enabled = true, -- Hook into the builtin statusline to indicate the status of the GitLab Duo Code Suggestions integration
      },
    },
  },
  {
    "github/copilot.vim",
    lazy = true,
    --event = { 'BufReadPre', 'BufNewFile' },
    event = 'VimEnter',
    init = function(_plugin)
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""
      vim.api.nvim_set_keymap("i", "<C-f>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
    end
  },
}
