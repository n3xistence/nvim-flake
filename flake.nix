{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim?dir=nix";

    plugins-oh-lucy-nvim = {
      url = "github:Yazeed1s/oh-lucy.nvim";
      flake = false;
    };

    plugins-ascii-nvim = {
	    url = "github:MaximilianLloyd/ascii.nvim";
	    flake = false;
    };

    plugins-sonarlint-nvim = {
	    url = "github:danarth/sonarlint.nvim";
	    flake = false;
    };

    plugins-vim-rest-console = {
	    url = "github:diepm/vim-rest-console";
	    flake = false;
    };

    plugins-prettier-nvim = {
	    url = "github:MunifTanjim/prettier.nvim";
	    flake = false;
    };
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };

    # see :help nixCats.flake.inputs
    # If you want your plugin to be loaded by the standard overlay,
    # i.e. if it wasnt on nixpkgs, but doesnt have an extra build step.
    # Then you should name it "plugins-something"
    # If you wish to define a custom build step not handled by nixpkgs,
    # then you should name it in a different format, and deal with that in the
    # overlay defined for custom builds in the overlays directory.
    # for specific tags, branches and commits, see:
    # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#examples
  };
  outputs = { self, nixpkgs, nixCats, ... }@inputs: let
    inherit (nixCats) utils;
    luaPath = "${./extra}";
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {
      allowUnfree = true;
    };
    inherit (forEachSystem (system: let
      dependencyOverlays = /* (import ./overlays inputs) ++ */ [
        (utils.standardPluginOverlay inputs)
      ];
    in { inherit dependencyOverlays; })) dependencyOverlays;

    categoryDefinitions = { pkgs, settings, categories, name, ... }@packageDef: {
      lspsAndRuntimeDeps = {
        general = with pkgs; [
	        vimPlugins.nvim-lspconfig
	        vimPlugins.lsp-zero-nvim
          vimPlugins.cmp-nvim-lsp
          vimPlugins.cmp-buffer
          vimPlugins.cmp-path
          vimPlugins.luasnip

	        vimPlugins.nvim-treesitter.withAllGrammars
	        vimPlugins.nvim-treesitter-context

	        emmet-language-server
          lua-language-server
          gopls
          xclip
          wl-clipboard
          fd
          luajitPackages.lua-lsp
          rust-analyzer
          nodePackages.bash-language-server
          yaml-language-server
          pyright
          marksman
          black
          stylua
          prettierd
          mypy
          pylint
          nixfmt-classic
          statix
          deadnix
          nil
        ] ++ pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
      };
      startupPlugins = {
        gitPlugins = with pkgs.neovimPlugins; [
	        oh-lucy-nvim 		  # Default theme
	        ascii-nvim 		    # Dep for dashboard
	        sonarlint-nvim 	  # Linting
	        vim-rest-console	# Rest Client
          prettier-nvim     # Formatting
	      ];
        general = with pkgs.vimPlugins; [
	        # TODO: organize this stuff
          colorizer
	        plenary-nvim
	        nvim-web-devicons
	        nui-nvim
	        neo-tree-nvim
	        nvim-notify
	        noice-nvim
	        playground
	        luasnip
	        nvim-ts-autotag
	        harpoon
	        oil-nvim
	        telescope-nvim
	        undotree
	        yazi-nvim
	        rainbow-delimiters-nvim
	        mini-indentscope
	        transparent-nvim
	        tabline-nvim
	        lualine-nvim
	        fugitive-gitlab-vim
	        gitsigns-nvim
	        oxocarbon-nvim
	        poimandres-nvim
	        markdown-nvim
	        dashboard-nvim
	        autoclose-nvim
	        vim-closetag
	      ];
      };
      optionalPlugins = {
        gitPlugins = with pkgs.neovimPlugins; [ ];
        general = with pkgs.vimPlugins; [ ];
      };
      sharedLibraries = {
        general = with pkgs; [
        ];
      };
      environmentVariables = {
        test = {
          CATTESTVAR = "It worked!";
        };
      };

      # If you know what these are, you can provide custom ones by category here.
      # If you dont, check this link out:
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      extraWrapperArgs = {
        test = [
          '' --set CATTESTVAR2 "It worked again!"''
        ];
      };

      # lists of the functions you would have passed to
      # python.withPackages or lua.withPackages

      # get the path to this python environment
      # in your lua config via
      # vim.g.python3_host_prog
      # or run from nvim terminal via :!<packagename>-python3
      extraPython3Packages = {
        test = (_:[]);
      };
      # populates $LUA_PATH and $LUA_CPATH
      extraLuaPackages = {
        test = [ (_:[]) ];
      };
    };

    # And then build a package with specific categories from above here:
    # All categories you wish to include must be marked true,
    # but false may be omitted.
    # This entire set is also passed to nixCats for querying within the lua.

    # see :help nixCats.flake.outputs.packageDefinitions
    packageDefinitions = {
      # These are the names of your packages
      # you can include as many as you wish.
      nvim = {pkgs , ... }: {
        # they contain a settings set defined above
        # see :help nixCats.flake.outputs.settings
        settings = {
          wrapRc = true;
          # IMPORTANT:
          # your alias may not conflict with your other packages.
          aliases = [ "vim" ];
          # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
        };
        # and a set of categories that you want
        # (and other information to pass to lua)
        categories = {
          general = true;
          gitPlugins = true;
          customPlugins = true;
          test = true;
          example = {
            youCan = "add more than just booleans";
            toThisSet = [
              "and the contents of this categories set"
              "will be accessible to your lua with"
              "nixCats('path.to.value')"
              "see :help nixCats"
            ];
          };
        };
      };
    };
  # In this section, the main thing you will need to do is change the default package name
  # to the name of the packageDefinitions entry you wish to use as the default.
    defaultPackageName = "nvim";
  in


  # see :help nixCats.flake.outputs.exports
  forEachSystem (system: let
    nixCatsBuilder = utils.baseBuilder luaPath {
      inherit nixpkgs system dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions;
    defaultPackage = nixCatsBuilder defaultPackageName;
    # this is just for using utils such as pkgs.mkShell
    # The one used to build neovim is resolved inside the builder
    # and is passed to our categoryDefinitions and packageDefinitions
    pkgs = import nixpkgs { inherit system; };
  in
  {
    # these outputs will be wrapped with ${system} by utils.eachSystem

    # this will make a package out of each of the packageDefinitions defined above
    # and set the default package to the one passed in here.
    packages = utils.mkAllWithDefault defaultPackage;

    # choose your package for devShell
    # and add whatever else you want in it.
    devShells = {
      default = pkgs.mkShell {
        name = defaultPackageName;
        packages = [ defaultPackage ];
        inputsFrom = [ ];
        shellHook = ''
        '';
      };
    };

  }) // {

    # these outputs will be NOT wrapped with ${system}

    # this will make an overlay out of each of the packageDefinitions defined above
    # and set the default overlay to the one named here.
    overlays = utils.makeOverlays luaPath {
      inherit nixpkgs dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions defaultPackageName;

    # we also export a nixos module to allow reconfiguration from configuration.nix
    nixosModules.default = utils.mkNixosModules {
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
    # and the same for home manager
    homeModule = utils.mkHomeModules {
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
    inherit utils;
    inherit (utils) templates;
  };

}