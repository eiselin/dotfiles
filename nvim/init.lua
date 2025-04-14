-- init.lua
-- Minimal Neovim configuration with Lazy.nvim

-- Basic options
vim.opt.number = true            -- Line numbers
vim.opt.relativenumber = true    -- Relative line numbers
vim.opt.cursorline = true        -- Highlight current line
vim.opt.smartindent = true       -- Smart indentation
vim.opt.wrap = false             -- Don't wrap lines
vim.opt.undofile = true          -- Persistent undo
vim.opt.clipboard = "unnamedplus" -- System clipboard integration
vim.opt.termguicolors = true     -- True color support
vim.opt.ignorecase = true        -- Case insensitive search
vim.opt.smartcase = true         -- Case sensitive when uppercase present
vim.opt.mouse = "a"              -- Enable mouse support
vim.opt.tabstop = 2              -- 2 spaces for tabs
vim.opt.shiftwidth = 2           -- 2 spaces for indentation
vim.opt.expandtab = true         -- Use spaces instead of tabs
vim.opt.completeopt = "menu,menuone,noselect" -- Completion options

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  -- Colorscheme
  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme catppuccin-latte]])
    end,
  },
  
  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "typescript", "markdown", "python", "ruby", 
          "html", "xml", "css", "lua"
        },
        highlight = {
          enable = true,
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
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.9,
            height = 0.8,
            prompt_position = "top",
          },
          sorting_strategy = "ascending",
        },
      })
    end,
  },
  
  -- Completion plugins
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer", -- Source for buffer words
    },
    config = function()
      local cmp = require("cmp")
      
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<C-j>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-k>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          -- Only use buffer source for completion (current file only)
          { name = "buffer", option = { keyword_length = 2 } },
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = function(entry, vim_item)
            -- Add source indication
            vim_item.menu = "[" .. entry.source.name .. "]"
            return vim_item
          end,
        },
      })
    end,
  },
})

-- Key mappings
-- Map jj to Escape in insert mode
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

-- Buffer navigation
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { noremap = true, silent = true })

-- Quick save and quit
vim.keymap.set("n", "<leader>w", ":w<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", ":q<CR>", { noremap = true, silent = true })

-- No highlight search
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { noremap = true, silent = true })

-- Move text up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- Auto-reload config when saved
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.fn.stdpath("config") .. "/init.lua",
  callback = function()
    vim.cmd("source " .. vim.fn.expand("<afile>"))
  end,
  group = vim.api.nvim_create_augroup("config_reload", { clear = true }),
})

print("Neovim config loaded!")
