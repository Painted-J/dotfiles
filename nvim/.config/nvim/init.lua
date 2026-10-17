-- 1. BASIC OPTIONS & SILVERBLUE TOOLBOX INTEGRATION
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

vim.opt.laststatus = 0 -- Hides the statusline completely (saves 1 line)
vim.opt.cmdheight = 0  -- Keeps command area minimal (collapses when unused in Neovim 0.10+)

vim.ui.open = function(path)
  vim.fn.jobstart({ "flatpak-spawn", "--host", "xdg-open", path }, { detach = true })
end

-- Remember and restore cursor position when reopening any file
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 2. KEYMAPS
local map = vim.keymap.set

map("i", "jj", "<Esc>", { desc = "Exit insert mode" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "Close active buffer" })

map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to host clipboard" })

map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

map("n", "<leader>s|", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>s-", "<cmd>split<CR>", { desc = "Split horizontal" })

-- 3. PLUGINS (Auto-bootstraps lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  rocks = {
    enabled = false, -- Disables luarocks to prevent build errors on Silverblue
  },
  spec = {
    {
      "olimorris/onedarkpro.nvim",
      priority = 1000,
      opts = {
        options = {
          transparency = true,
        },
      },
      config = function(_, opts)
        require("onedarkpro").setup(opts)
        vim.cmd.colorscheme("onedark")
      end,
    },

    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = {
        bigfile = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        picker = {
          enabled = true,
          sources = {
            files = { hidden = true },
            grep = { hidden = true },
          },
        },
        explorer = {
          enabled = true,
          hidden = true,
          cwd = function()
            return Snacks.vim.root() or vim.fn.getcwd()
          end,
        },
        dashboard = {
          enabled = true,
          preset = {
            header = [[
 ███▄    █ ▓█████  ▒█████   ██▒   █▓ ██▓ ███▄ ▄███▓
 ██ ▀█   █ ▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒▓██▒▀█▀ ██▒
▓██  ▀█ ██▒▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██    ▓██░
▓██▒  ▐▌██▒▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▒██    ▒██ 
▒██░   ▓██░░▒████▒░ ████▓▒░   ▒▀█░  ░██░▒██▒   ░██▒
░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ░  ░
░ ░░   ░ ▒░ ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░  ░      ░
   ░   ░ ░    ░   ░ ░ ░ ▒       ░░   ▒ ░░      ░   
         ░    ░  ░    ░ ░        ░   ░         ░   
                                ░                
]],
            keys = {
              { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
              { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
              { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
              { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
              { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
              { icon = " ", key = "s", desc = "Restore Session", section = "session" },
              { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
              { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
          },
        },
      },
      keys = {
        { "<leader><leader>", function() Snacks.picker.files() end, desc = "Find Files (Snacks)" },
        { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
        { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live Grep" },
        { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer Tree" },
      },
    },

{
      "christoomey/vim-tmux-navigator",
      cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
      },
      keys = {
        { "<M-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/Tmux Left" },
        { "<M-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window/Tmux Down" },
        { "<M-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window/Tmux Up" },
        { "<M-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/Tmux Right" },
      },
    },

    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {},
    },

    {
      "stevearc/conform.nvim",
      opts = {
        format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          javascript = { "prettier" },
          json = { "jq" },
          yaml = { "prettier" },
          sh = { "shfmt" },
        },
      },
    },
  },
})
