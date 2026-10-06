return {
  -- ======================================================================== --
  -- VISUAL TABS (Bufferline)                                                 --
  -- ======================================================================== --
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>",      "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "<leader>bp", "<cmd>BufferLinePick<cr>",      desc = "Buffer Pick" },
      { "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Buffer Pick Close" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp", -- Show LSP error badges directly on tabs
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
            separator = true,
          },
        },
      },
    },
  },

  -- ======================================================================== --
  -- FILE TREE SIDEBAR (Nvim-Tree)                                            --
  -- ======================================================================== --
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    opts = {
      filters = { dotfiles = false },
      view = {
        width = { min = 30, max = -1, padding = 1 },
        preserve_window_proportions = true,
      },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)

      vim.keymap.set("n", "<leader>de", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })

      -- Disable side scrolling specific to the explorer window
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "NvimTree",
        callback = function()
          vim.opt_local.wrap = false
          vim.opt_local.sidescroll = 0
          vim.opt_local.sidescrolloff = 0
        end,
      })

      -- Auto-open on startup
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          -- Let Oil handle directories
          if data.file == "" or vim.fn.isdirectory(data.file) == 1 then return end
          if vim.bo[data.buf].filetype == "oil" then return end
          if data.file:match("^oil://") then return end

          local filetype = vim.bo[data.buf].filetype
          local ignored_filetypes = { "gitcommit", "gitrebase" }
          if vim.tbl_contains(ignored_filetypes, filetype) then return end

          require("nvim-tree.api").tree.open()
        end,
      })

      -- Auto-open after being passed off from Oil (i.e: "nvim .")
      vim.api.nvim_create_autocmd("BufLeave", {
        pattern = "oil://*",
        callback = function()
          vim.schedule(function()
            local next = vim.api.nvim_buf_get_name(0)
            if not next:match("^oil://") and vim.fn.filereadable(next) == 1 then
              require("nvim-tree.api").tree.open()
            end
          end)
        end,
      })
    end,
  },

  -- ======================================================================== --
  -- IN-BUFFER FILE EXPLORER (Oil.nvim)                                       --
  -- ======================================================================== --
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false, -- Ensure loads immediately
    config = function()
      require("oil").setup({
        view_options = { show_hidden = true },
      })

      vim.keymap.set("n", "<leader>oo", "<cmd>Oil<CR>", { desc = "Open parent directory" })
    end,
  },
  --{
  --  "stevearc/oil.nvim",
  --  dependencies = { "nvim-tree/nvim-web-devicons" },
  --  keys = {
  --    { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
  --  },
  --  opts = {
  --    view_options = { show_hidden = true },
  --  },
  --},

  -- ======================================================================== --
  -- FUZZY FINDER (Telescope)                                                 --
  -- ======================================================================== --
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find Files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end,  desc = "Live Grep" },
    },
    opts = {},
  },

  -- ======================================================================== --
  -- DIAGNOSTICS & SYMBOLS PANELS (Trouble.nvim)                              --
  -- ======================================================================== --
  {
    "folke/trouble.nvim",
    lazy = false,
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Symbols/Outline (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Items (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix List (Trouble)" },
    },
    config = function()
      require("trouble").setup({})

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buf = args.buf
          local ft = vim.bo[buf].filetype
          local ignored = { "NvimTree", "oil", "trouble", "lazy", "mason", "help", "qf" }
          if vim.tbl_contains(ignored, ft) then return end
          if vim.api.nvim_buf_get_name(buf) == "" then return end

          if vim.o.columns >= 120 then
            require("trouble").open({ mode = "symbols", focus = false })
          end
        end,
      })
    end,
  },

  -- ======================================================================== --
  -- DASHBOARD                                                                 --
  -- ======================================================================== --
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("dashboard").setup({
        theme = "doom",
        config = {
          --header = {
          --  "",
          --  "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  ",
          --  "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  ",
          --  "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  ",
          --  "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  ",
          --  "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  ",
          --  "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  ",
          --  "",
          --},
          header = {
            [[                                                                                ]],
            [[ =================     ===============     ===============   ========  ======== ]],
            [[ \\ . . . . . . .\\   //. . . . . . .\\   //. . . . . . .\\  \\. . .\\// . . // ]],
            [[ ||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . .|| ]],
            [[ || . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . || ]],
            [[ ||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .|| ]],
            [[ || . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\ . . . . || ]],
            [[ ||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\_ . .|. .|| ]],
            [[ || . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\ `-_/| . || ]],
            [[ ||_-' ||  .|/    || ||    \|.  || `-_|| ||_-' ||  .|/    || ||   | \  / |-_.|| ]],
            [[ ||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \  / |  `|| ]],
            [[ ||    `'         || ||         `'    || ||    `'         || ||   | \  / |   || ]],
            [[ ||            .===' `===.         .==='.`===.         .===' /==. |  \/  |   || ]],
            [[ ||         .=='   \_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \/  |   || ]],
            [[ ||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \/  |   || ]],
            [[ ||   .=='    _-'          `-__\._-'         `-_./__-'         `' |. /|  |   || ]],
            [[ ||.=='    _-'                                                     `' |  /==.|| ]],
            [[ =='    _-'                                                            \/   `== ]],
            [[ \   _-'                                                                `-_   / ]],
            [[  `''                                                                      ``'  ]],
            [[                                                                                ]],
          },
          center = {
            {
              icon = "  ",
              desc = "New File           ",
              key = "n",
              action = "enew",
            },
            {
              icon = "  ",
              desc = "Find File          ",
              key = "f",
              action = function() require("telescope.builtin").find_files() end,
            },
            {
              icon = "  ",
              desc = "Recent Files       ",
              key = "r",
              action = function() require("telescope.builtin").oldfiles() end,
            },
            {
              icon = "  ",
              desc = "Find Word          ",
              key = "g",
              action = function() require("telescope.builtin").live_grep() end,
            },
            {
              icon = "  ",
              desc = "Config             ",
              key = "c",
              action = "edit ~/.config/nvim/init.lua",
            },
            {
              icon = "󰒲  ",
              desc = "Lazy               ",
              key = "l",
              action = "Lazy",
            },
            {
              icon = "  ",
              desc = "Quit               ",
              key = "q",
              action = "qa",
            },
          },
          footer = function()
            local stats = require("lazy").stats()
            return { "⚡ " .. stats.count .. " plugins loaded" }
          end,
        },
      })
    end,
  },
}
