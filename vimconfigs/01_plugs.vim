" ------------------------------------
" |  Setup vim-plug  |
" ------------------------------------
" auto-install vim-plug
if !isdirectory('$HOME/.vimplugged')
    if empty(glob('~/.config/nvim/autoload/plug.vim'))
        silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    endif
    autocmd VimEnter * PlugInstall
endif

" Where to load our plugins
call plug#begin('$HOME/.vimplugged')

Plug 'inkarkat/vim-ingo-library'
Plug 'vim-scripts/L9'

Plug 'airblade/vim-gitgutter'
Plug 'chrisbra/csv.vim'
Plug 'chrisbra/NrrwRgn'
Plug 'chrisbra/SudoEdit.vim'
Plug 'chrisbra/unicode.vim'
Plug 'christoomey/vim-sort-motion'
Plug 'derekwyatt/vim-scala'
Plug 'easymotion/vim-easymotion'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'godlygeek/tabular'
Plug 'gregsexton/MatchTag'
Plug 'hail2u/vim-css3-syntax'
Plug 'honza/vim-snippets'
Plug 'iiey/visincr'
Plug 'inkarkat/vim-AdvancedSorters'
Plug 'inkarkat/vim-ChangeGloballySmartCase'
Plug 'inkarkat/vim-CursorLineCurrentWindow'
Plug 'jremmen/vim-ripgrep'
Plug 'junegunn/fzf'
Plug 'junegunn/seoul256.vim'
Plug 'junegunn/vim-easy-align'
Plug 'mbbill/undotree'
Plug 'mhinz/vim-startify'
Plug 'mtdl9/vim-log-highlighting'
Plug 'myusuf3/numbers.vim'
Plug 'pearofducks/ansible-vim'
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'PProvost/vim-ps1'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'qpkorr/vim-renamer'
Plug 'Raimondi/delimitMate'
Plug 'rust-lang/rust.vim'
Plug 's3rvac/vim-syntax-yara'
Plug 'sbdchd/neoformat'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'SirVer/ultisnips'
Plug 'taku-o/vim-reorder-columns'
Plug 'terryma/vim-expand-region'
Plug 'terryma/vim-multiple-cursors'
Plug 'tmhedberg/matchit'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-characterize'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'triglav/vim-visual-increment'
Plug 'tweekmonster/braceless.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/LargeFile'
Plug 'w0rp/ale'
Plug 'wellle/targets.vim'
Plug 'Yggdroot/indentLine'

" Initialize plugin system
call plug#end()
