{pkgs, ...}: {
  globals.mapleader = " ";

  theme = {
    enable = true;
    name = "catppuccin";
    style = "mocha";
  };

  lineNumberMode = "relative";
  preventJunkFiles = true;
  options.wrap = true;
  options.scrolloff = 8;

  clipboard = {
    registers = "unnamedplus";
  };

  treesitter = {
    enable = true;
    fold = true;
    highlight.enable = true;
    indent.enable = true;
  };

  lsp = {
    enable = true;
    formatOnSave = true;
    lspkind.enable = true;
    lightbulb.enable = true;
    lspsaga.enable = false;
    trouble.enable = true;
    lspSignature.enable = true;
  };

  languages = {
    enableFormat = true;
    enableTreesitter = true;
    enableExtraDiagnostics = true;

    nix.enable = true;
    python.enable = true;
    lua.enable = true;
    rust.enable = true;
    clang.enable = true;
  };

  statusline = {
    lualine = {
      enable = true;
      theme = "catppuccin";
    };
  };

  autocomplete = {
    nvim-cmp.enable = true;
  };

  terminal = {
    toggleterm = {
      enable = true;
      lazygit.enable = true;
      setupOpts = {
        direction = "float";
      };
    };
  };

  ui = {
    borders = {
      enable = true;
      globalStyle = "rounded";
    };
    noice.enable = true;
    colorizer.enable = true;
    illuminate.enable = true;
  };

  utility = {
    ccc.enable = true;
    vim-wakatime.enable = false;
    icon-picker.enable = true;
    surround.enable = true;
    diffview-nvim.enable = true;
    motion = {
      hop.enable = true;
      leap.enable = true;
    };
  };

  extraPlugins = {
    vim-be-good = {
      package = pkgs.vimPlugins.vim-be-good;
      setup = "";
    };
  };

  git = {
    enable = true;
    gitsigns.enable = true;
    gitsigns.codeActions.enable = false;
  };

  maps = {
    normal = {
      "<leader>ff" = {action = "<cmd>Telescope find_files<CR>";};
      "<leader>fg" = {action = "<cmd>Telescope live_grep<CR>";};
      "<leader>fb" = {action = "<cmd>Telescope buffers<CR>";};
      "<leader>fh" = {action = "<cmd>Telescope help_tags<CR>";};
      "<leader>ft" = {action = "<cmd>NvimTreeToggle<CR>";};
      "<leader>e" = {action = "<cmd>NvimTreeFocus<CR>";};
      "<C-\\>" = {action = "<cmd>ToggleTerm<CR>";};
    };
    terminal = {
      "<C-\\>" = {action = "<cmd>ToggleTerm<CR>";};
    };
  };

  telescope = {
    enable = true;
  };

  debugger = {
    nvim-dap = {
      enable = true;
      ui.enable = true;
    };
  };

  comments = {
    comment-nvim.enable = true;
  };

  presence = {
    neocord = {
      enable = false;
    };
  };
}
