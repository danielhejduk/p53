{ pkgs, ... }:

{
  #############################################################################
  # External binaries the plugins shell out to.
  #############################################################################
  home.packages = with pkgs; [
    nodejs_22 # required by coc.nvim (it is a Node process)
    fzf # fzf-vim
    ripgrep # :Rg, fzf file crawler
    bat # fzf preview highlighting
    universal-ctags # tagbar / vim-gutentags
    git # fugitive, gitgutter
    fd

    # Language servers / formatters — trim to what you actually use.
    clang-tools # clangd
    pyright
    nixd
    rust-analyzer
    gopls
    typescript-language-server # NOT nodePackages.* — that set is being removed
    typescript # tsserver itself, needed by the above
    black
    nixfmt
  ];

  #############################################################################
  # coc.nvim needs a writable config file; Nix store paths are read-only.
  #############################################################################
  home.file.".vim/coc-settings.json".text = builtins.toJSON {
    "suggest.noselect" = false;
    "diagnostic.virtualText" = true;
    "diagnostic.virtualTextCurrentLineOnly" = false;
    "coc.preferences.formatOnSave" = true;
    languageserver = {
      nix = {
        command = "nixd";
        filetypes = [ "nix" ];
        rootPatterns = [ "flake.nix" ];
      };

      # coc-go was removed from nixpkgs alongside coc-tsserver — same reason.
      go = {
        command = "gopls";
        rootPatterns = [ "go.mod" ];
        filetypes = [ "go" ];
      };

      # Replacement for the removed vimPlugins.coc-tsserver: drive
      # typescript-language-server through coc's generic LSP client.
      tsserver = {
        command = "typescript-language-server";
        args = [ "--stdio" ];
        filetypes = [
          "javascript"
          "javascriptreact"
          "javascript.jsx"
          "typescript"
          "typescriptreact"
          "typescript.tsx"
        ];
        rootPatterns = [
          "tsconfig.json"
          "jsconfig.json"
          "package.json"
          ".git"
        ];
      };
    };
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;

    # vim-full = +python3 (UltiSnips), +clipboard, +terminal. Do not drop this.
    packageConfigurable = pkgs.vim-full;

    plugins = with pkgs.vimPlugins; [
      ##### LSP / completion — coc.nvim ########################################
      coc-nvim
      coc-json
      coc-yaml
      coc-html
      coc-css
      coc-clangd
      coc-pyright
      # coc-tsserver / coc-go: REMOVED from nixpkgs (unmaintained node2nix
      # packages). TS/JS and Go are handled by the `languageserver` block in
      # coc-settings.json above instead. See the note at the bottom of this
      # file if you want the real extension back.
      coc-eslint
      coc-prettier
      coc-rust-analyzer
      coc-snippets
      coc-git
      coc-fzf
      coc-pairs

      ##### Fuzzy finding / navigation #########################################
      fzf-wrapper
      fzf-vim
      nerdtree
      nerdtree-git-plugin
      vim-devicons
      tagbar

      ##### Git ###############################################################
      vim-fugitive
      vim-rhubarb
      vim-gitgutter

      ##### Build / test / tasks ##############################################
      vim-dispatch
      vim-test
      asynctasks-vim
      asyncrun-vim

      ##### Editing ###########################################################
      vim-surround
      vim-repeat
      vim-commentary
      vim-unimpaired
      vim-abolish
      vim-eunuch
      vim-easy-align
      vim-visual-multi
      vim-matchup
      vim-indent-object
      vim-exchange
      undotree
      editorconfig-vim
      traces-vim

      ##### Snippets ##########################################################
      ultisnips
      vim-snippets

      ##### Syntax / filetypes ################################################
      vim-polyglot
      vim-nix

      ##### UI ################################################################
      vim-airline
      vim-airline-themes
      gruvbox
      indentLine
      rainbow
      vim-startify
      vim-highlightedyank
      vim-which-key
    ];

    extraConfig = ''
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Base
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      set nocompatible
      set encoding=utf-8
      set hidden
      set number relativenumber
      set signcolumn=yes
      set cursorline
      set scrolloff=6
      set mouse=a
      set clipboard=unnamedplus
      set splitbelow splitright
      set termguicolors
      set updatetime=300
      set shortmess+=c
      set nobackup nowritebackup
      set undofile
      set undodir=$HOME/.vim/undo
      set backspace=indent,eol,start
      set expandtab tabstop=4 shiftwidth=4 softtabstop=4 smartindent
      set ignorecase smartcase incsearch hlsearch
      set wildmenu wildmode=longest:full,full
      set completeopt=menuone,noinsert,noselect
      set laststatus=2
      set ttimeoutlen=10
      syntax on
      filetype plugin indent on

      let mapleader = " "
      let maplocalleader = ","

      colorscheme gruvbox
      set background=dark

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " coc.nvim — completion, diagnostics, code actions
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      function! CheckBackspace() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1] =~# '\s'
      endfunction

      inoremap <silent><expr> <TAB>
            \ coc#pum#visible() ? coc#pum#next(1) :
            \ CheckBackspace() ? "\<Tab>" :
            \ coc#refresh()
      inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
      inoremap <silent><expr> <CR>
            \ coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
      inoremap <silent><expr> <C-space> coc#refresh()

      " Navigation
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)
      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)

      " Hover docs
      nnoremap <silent> K :call ShowDocumentation()<CR>
      function! ShowDocumentation()
        if CocAction('hasProvider', 'hover')
          call CocActionAsync('doHover')
        else
          call feedkeys('K', 'in')
        endif
      endfunction

      " Refactor / fix
      nmap <leader>rn <Plug>(coc-rename)
      nmap <leader>ca <Plug>(coc-codeaction-cursor)
      nmap <leader>qf <Plug>(coc-fix-current)
      xmap <leader>f  <Plug>(coc-format-selected)
      nmap <leader>f  <Plug>(coc-format)

      " Highlight symbol under cursor
      autocmd CursorHold * silent call CocActionAsync('highlight')

      " Lists
      nnoremap <silent><nowait> <leader>d  :<C-u>CocFzfList diagnostics<CR>
      nnoremap <silent><nowait> <leader>o  :<C-u>CocFzfList outline<CR>
      nnoremap <silent><nowait> <leader>s  :<C-u>CocFzfList symbols<CR>
      nnoremap <silent><nowait> <leader>ce :<C-u>CocFzfList extensions<CR>

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " fzf
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline --bind ctrl-/:toggle-preview'
      let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.85 } }
      nnoremap <leader><leader> :Files<CR>
      nnoremap <leader>b :Buffers<CR>
      nnoremap <leader>/ :Rg<CR>
      nnoremap <leader>l :BLines<CR>
      nnoremap <leader>h :History<CR>
      nnoremap <leader>gc :Commits<CR>

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " File tree + tag outline
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      let g:NERDTreeShowHidden = 1
      let g:NERDTreeWinSize = 32
      let g:NERDTreeMinimalUI = 1
      nnoremap <leader>e :NERDTreeToggle<CR>
      nnoremap <leader>E :NERDTreeFind<CR>

      let g:tagbar_width = 34
      let g:tagbar_autofocus = 1
      nnoremap <leader>t :TagbarToggle<CR>

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Git
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      nnoremap <leader>gs :Git<CR>
      nnoremap <leader>gb :Git blame<CR>
      nnoremap <leader>gd :Gvdiffsplit<CR>
      let g:gitgutter_map_keys = 0
      nmap ]c <Plug>(GitGutterNextHunk)
      nmap [c <Plug>(GitGutterPrevHunk)
      nmap <leader>gp <Plug>(GitGutterPreviewHunk)
      nmap <leader>ga <Plug>(GitGutterStageHunk)
      nmap <leader>gu <Plug>(GitGutterUndoHunk)

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Build / run / test
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      let g:asyncrun_open = 8
      let g:asynctasks_term_pos = 'bottom'
      nnoremap <leader>mm :AsyncTask project-build<CR>
      nnoremap <leader>mr :AsyncTask project-run<CR>
      nnoremap <leader>mt :AsyncTask project-test<CR>

      let g:test#strategy = 'dispatch'
      nnoremap <leader>Tn :TestNearest<CR>
      nnoremap <leader>Tf :TestFile<CR>
      nnoremap <leader>Ts :TestSuite<CR>
      nnoremap <leader>Tl :TestLast<CR>

      " Integrated terminal
      nnoremap <leader>` :botright terminal ++rows=14<CR>
      tnoremap <Esc><Esc> <C-\><C-n>

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Snippets (UltiSnips — needs +python3, hence vim-full)
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      let g:UltiSnipsExpandTrigger = '<C-j>'
      let g:UltiSnipsJumpForwardTrigger = '<C-j>'
      let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " UI
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      let g:airline_theme = 'gruvbox'
      let g:airline_powerline_fonts = 1
      let g:airline#extensions#tabline#enabled = 1
      let g:airline#extensions#coc#enabled = 1

      let g:indentLine_char = '|'
      let g:indentLine_setConceal = 0
      let g:rainbow_active = 1
      let g:highlightedyank_highlight_duration = 150

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Window / buffer motions
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :bd<CR>
      nnoremap <silent> <Esc><Esc> :nohlsearch<CR>
      xmap ga <Plug>(EasyAlign)
      nmap ga <Plug>(EasyAlign)
      nnoremap <leader>u :UndotreeToggle<CR>

      " Persistent undo dir must exist
      if !isdirectory($HOME . '/.vim/undo')
        call mkdir($HOME . '/.vim/undo', 'p', 0700)
      endif
    '';
  };
}

#############################################################################
# GETTING coc-tsserver BACK (optional)
#
# Its `release` branch ships pre-bundled JS, so buildVimPlugin works with no
# npm/node2nix involvement. Add near the top of the file:
#
#   let
#     coc-tsserver = pkgs.vimUtils.buildVimPlugin {
#       pname = "coc-tsserver";
#       version = "2.4.1";           # bump as needed
#       src = pkgs.fetchFromGitHub {
#         owner = "neoclide";
#         repo  = "coc-tsserver";
#         rev   = "v2.4.1";
#         hash  = "sha256-AAAA...";  # nix-prefetch-github neoclide coc-tsserver --rev v2.4.1
#       };
#     };
#   in
#
# then list `coc-tsserver` in plugins and delete the `tsserver` entry from
# coc-settings.json (otherwise you get two clients on the same buffers).
#
# The real extension gives you organize-imports, auto-import code actions and
# tsserver-specific refactors that the generic LSP client does not expose. If
# you don't miss those, the languageserver config above is less maintenance.
#
# Two more coc extensions in the config are built the same fragile way —
# coc-eslint and coc-prettier. If either errors out on a channel bump, drop it
# and use ALE as a fixer-only layer instead:
#   let g:ale_disable_lsp = 1
#   let g:ale_fixers = {'javascript': ['prettier','eslint'], '*': ['trim_whitespace']}
#   let g:ale_fix_on_save = 1
#############################################################################

#############################################################################
# ALTERNATIVE: pure-Vimscript LSP stack (no Node.js at all)
#
# Replace every coc-* entry above with:
#
#   plugins = with pkgs.vimPlugins; [
#     async-vim
#     vim-lsp
#     vim-lsp-settings
#     asyncomplete-vim
#     asyncomplete-lsp-vim
#     ale                  # linters + fixers
#     vista-vim            # symbol outline, replaces tagbar
#     ...
#   ];
#
# and use this config instead of the coc block:
#
#   let g:lsp_diagnostics_enabled = 1
#   let g:lsp_diagnostics_echo_cursor = 1
#   let g:lsp_document_highlight_enabled = 1
#   let g:lsp_settings_servers_dir = expand('~/.local/share/vim-lsp-settings/servers')
#   let g:ale_disable_lsp = 1
#
#   function! s:on_lsp_buffer_enabled() abort
#     setlocal omnifunc=lsp#complete
#     setlocal signcolumn=yes
#     nmap <buffer> gd <plug>(lsp-definition)
#     nmap <buffer> gr <plug>(lsp-references)
#     nmap <buffer> gi <plug>(lsp-implementation)
#     nmap <buffer> K  <plug>(lsp-hover)
#     nmap <buffer> <leader>rn <plug>(lsp-rename)
#     nmap <buffer> <leader>ca <plug>(lsp-code-action)
#     nmap <buffer> [g <plug>(lsp-previous-diagnostic)
#     nmap <buffer> ]g <plug>(lsp-next-diagnostic)
#   endfunction
#
#   augroup lsp_install
#     au!
#     autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
#   augroup END
#
# vim-lsp-settings normally downloads servers itself — on NixOS install them
# via home.packages (as above) and register them with g:lsp_settings, e.g.
#   let g:lsp_settings = { 'clangd': {'cmd': ['clangd', '--background-index']} }
#############################################################################
