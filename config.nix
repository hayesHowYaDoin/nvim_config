{
  pkgs,
  themeConfig ? {
    enable = true;
    name = "catppuccin";
    style = "mocha";
  },
  transparentBackground ? false,
  obsidianConfig ? null,
  ...
}: let
  # nvf built-in themes (from supported-themes.nix)
  nvfSupportedThemes = [
    "base16"
    "mini-base16"
    "onedark"
    "tokyonight"
    "dracula"
    "catppuccin"
    "oxocarbon"
    "gruvbox"
    "rose-pine"
    "nord"
    "github"
    "solarized"
    "solarized-osaka"
    "everforest"
  ];

  # Check if the requested theme is built-in to nvf
  isNvfTheme = builtins.elem (themeConfig.name or "") nvfSupportedThemes;

  # Use nvf's theme system only for supported themes
  # For custom themes like gruvbox-material, disable it and handle in extraPlugins
  nvfThemeConfig =
    if isNvfTheme
    then themeConfig
    else {enable = false;};
in {
  globals.mapleader = " ";

  theme = nvfThemeConfig;

  lineNumberMode = "relNumber";
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
    wgsl.enable = true;
  };

  statusline = {
    lualine = {
      enable = true;
      # Map custom themes to lualine theme names
      theme =
        if (themeConfig.name or "") == "gruvbox-material"
        then "gruvbox-material"
        else themeConfig.name or "catppuccin";
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

  dashboard.dashboard-nvim.enable = true;

  utility = {
    ccc.enable = true;
    vim-wakatime.enable = false;
    icon-picker.enable = true;
    surround.enable = true;
    diffview-nvim.enable = true;
    yazi-nvim.enable = true;
    motion = {
      hop.enable = true;
      leap.enable = true;
    };
  };

  extraPlugins = {
    dashboard-nvim-config = {
      package = pkgs.vimPlugins.dashboard-nvim;
      setup = ''
        require('dashboard').setup({
          theme = 'doom',
          config = {
            vertical_center = true,
            header = {
              "",
              "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
              "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
              "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
              "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
              "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
              "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
              "",
            },
            center = {
              {
                icon = ' ',
                desc = 'Find Files',
                action = 'Telescope find_files',
                key = 'f',
                keymap = ' ff',
              },
              {
                icon = ' ',
                desc = 'Recent Files',
                action = 'Telescope oldfiles',
                key = 'r',
                keymap = ' fr',
              },
              {
                icon = ' ',
                desc = 'Live Grep',
                action = 'Telescope live_grep',
                key = 'g',
                keymap = ' fg',
              },
              {
                icon = ' ',
                desc = 'Commands',
                action = 'Telescope commands',
                key = 'c',
                keymap = ' fc',
              },
            },
            footer = {},
          },
        })
      '';
    };
    vim-be-good = {
      package = pkgs.vimPlugins.vim-be-good;
      setup = "";
    };
    gruvbox-material = {
      package = pkgs.vimPlugins.gruvbox-material;
      setup = ''
        -- Configure gruvbox-material before setting colorscheme
        vim.g.gruvbox_material_background = '${themeConfig.style or "medium"}'
        vim.g.gruvbox_material_better_performance = 1
        ${
          if transparentBackground
          then "vim.g.gruvbox_material_transparent_background = 1"
          else ""
        }

        -- Only set colorscheme if gruvbox-material is the selected theme
        ${
          if themeConfig.name or "" == "gruvbox-material"
          then "vim.cmd('colorscheme gruvbox-material')"
          else ""
        }
      '';
    };
    transparent-background = {
      package = pkgs.vimPlugins.base16-nvim;
      setup = ''
        -- Apply transparent background to all themes if enabled
        ${
          if transparentBackground
          then ''
            -- Override background color to be transparent
            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
            vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
            vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
            vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
            vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" })
          ''
          else ""
        }
      '';
    };
    obsidian-nvim = {
      package = pkgs.vimPlugins.obsidian-nvim;
      setup = ''
        ${
          if obsidianConfig != null
          then ''
            require('obsidian').setup({
              workspaces = {
                {
                  name = "notes",
                  path = "${obsidianConfig.vaultPath}",
                },
              },

              -- Completion settings
              completion = {
                nvim_cmp = true,
                min_chars = 2,
              },

              -- Daily notes configuration
              daily_notes = {
                folder = "${obsidianConfig.dailyNotesFolder}",
                date_format = "%Y-%m-%d",
                alias_format = "%B %-d, %Y",
              },

              -- Templates configuration
              templates = {
                subdir = "${obsidianConfig.templatesFolder}",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M",
              },

              -- Note ID generation
              note_id_func = function(title)
                -- Use the title as the note ID, or generate timestamp-based ID
                local suffix = ""
                if title ~= nil then
                  suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                else
                  suffix = tostring(os.time())
                end
                return suffix
              end,

              -- UI settings
              ui = {
                enable = true,
                checkboxes = {
                  [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
                  ["x"] = { char = "", hl_group = "ObsidianDone" },
                },
              },

              -- Follow URL behavior
              follow_url_func = function(url)
                vim.fn.jobstart({"xdg-open", url})
              end,
            })
          ''
          else ""
        }
      '';
    };
  };

  # Enable true color support for transparency
  options.termguicolors = true;

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
      "<leader>fc" = {action = "<cmd>Telescope commands<CR>";};
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
