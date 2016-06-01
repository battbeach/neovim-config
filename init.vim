
" Use before config if available {
    if filereadable(expand("~/.config/nvim/init.before"))
        source ~/.config/nvim/init.before
    endif
" }

" General {
    filetype plugin indent on   "Automatically detect file types
    syntax on                   " Syntax highlighting

    if has('clipboard')
        if has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard=unnamed,unnamedplus
        else         " On mac and Windows, use * register for copy-paste
            set clipboard=unnamed
        endif
    endif

" }

" UI {
    if has('cmdline_info')
        set ruler                   " Show the ruler
        set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
        set showcmd                 " Show partial commands in status line and
                                    " Selected characters/lines in visual mode
    endif

    if has('statusline')
        set laststatus=2

        " Broken down into easily includeable segments
        set statusline=%<%f\                     " Filename
        set statusline+=%w%h%m%r                 " Options
        " this does not work yet, maybe we should remove it and have a simpler status line
        "if !exists('g:override_spf13_bundles')
        "    set statusline+=%fugitive#statusline() " Git Hotness
        "endif
        "set statusline+=\ [%&ff/%Y]            " Filetype
        "set statusline+=\ [%getcwd()]          " Current dir
        "set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
    endif

    set backspace=indent,eol,start  " Backspace for dummies
    set linespace=0                 " No extra spaces between rows
    set number                      " Line numbers on
    set showmatch                   " Show matching brackets/parenthesis
    set incsearch                   " Find as you type search
    set hlsearch                    " Highlight search terms
    set winminheight=0              " Windows can be 0 line high
    set ignorecase                  " Case insensitive search
    set smartcase                   " Case sensitive when uc present
    set wildmenu                    " Show list instead of just completing
    set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
    set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
    set scrolljump=5                " Lines to scroll when cursor leaves screen
    set scrolloff=3                 " Minimum lines to keep above and below cursor
    set foldenable                  " Auto fold code
    set list
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

" }

" Formatting {

    set wrap                        " wrap long lines
    set autoindent                  " Indent at the same level of the previous line
    set shiftwidth=4                " Use indents of 4 spaces
    set expandtab                   " Tabs are spaces, not tabs
    set tabstop=4                   " An indentation every four columns
    set softtabstop=4               " Let backspace delete indent
    set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
    set splitright                  " Puts new vsplit windows to the right of the current
    set splitbelow                  " Puts new split windows to the bottom of the current
    "set matchpairs+=<:>             " Match, to be used with %
    set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
    "set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks
    " Remove trailing whitespaces and ^M chars
    " To disable the stripping of whitespace, add the following to your
    " .vimrc.before.local file:
    "   let g:neovim_keep_trailing_whitespace = 1
    autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> if !exists('g:neovim_keep_trailing_whitespace') | call StripTrailingWhitespace() | endif
    "autocmd FileType go autocmd BufWritePre <buffer> Fmt
    autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
    autocmd FileType haskell,puppet,ruby,yml setlocal expandtab shiftwidth=2 softtabstop=2
    " preceding line best in a plugin but here for now.

    autocmd BufNewFile,BufRead *.coffee set filetype=coffee

    " Workaround vim-commentary for Haskell
    autocmd FileType haskell setlocal commentstring=--\ %s
    " Workaround broken colour highlighting in Haskell
    autocmd FileType haskell,rust setlocal nospell

    colorscheme molokai

" }


" Functions {

    " Strip whitespace {
    function! StripTrailingWhitespace()
        " Preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " do the business:
        %s/\s\+$//e
        " clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endfunction

    function! VisualSelection(direction, extra_filter) range
        let l:saved_reg = @"
        execute "normal! vgvy"

        let l:pattern = escape(@", '\\/.*$^~[]')
        let l:pattern = substitute(l:pattern, "\n$", "", "")

        if a:direction == 'b'
            execute "normal ?" . l:pattern . "^M"
        elseif a:direction == 'gv'
            call CmdLine("Ag \"" . l:pattern . "\" " )
        elseif a:direction == 'replace'
            call CmdLine("%s" . '/'. l:pattern . '/')
        elseif a:direction == 'f'
            execute "normal /" . l:pattern . "^M"
        endif

        let @/ = l:pattern
        let @" = l:saved_reg
    endfunction

    " }
" }

" Plugin {
    " Instalation {
    call plug#begin('~/.config/nvim/plugged')

    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'

    call plug#end()
    " }
" }

" Key mapping {

    " Note that Mac command key is not sent by the terminal, thus not available
    " fdsafds fdsafds f dsafds llfda 
    let mapleader=','
    let maplocalleader=' '

    vnoremap < <gv " Visual shifting (does not exit Visual mode)
    vnoremap > >gv

    " Easier moving in tabs and windows
    "map <C-J> <C-W>j<C-W>_
    "map <C-K> <C-W>k<C-W>_
    "map <C-L> <C-W>l<C-W>_
    "map <C-H> <C-W>h<C-W>_
    "This is based on the golang setup, which might be better
    map <C-J> <C-W>j
    map <C-K> <C-W>k
    map <C-L> <C-W>l
    map <C-H> <C-W>h

    " when wrapped is on, go to virual line instead of line in file 
    noremap j gj
    noremap k gk

    " Yank from the cursor to the end of the line
    nnoremap Y y$

    " disable search highlight
    nmap <silent> <leader>/ :nohlsearch<CR>

    " Find merge conflict markers
    map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

    " Allow using the repeat operator with a visual selection (!)
    " http://stackoverflow.com/a/8064607/127816
    vnoremap . :normal .<CR>

    " Adjust viewports to the same size
    map <Leader>= <C-w>=

    " Map <Leader>fw to display all lines with keyword under cursor
    " and ask which one to jump to
    nmap <Leader>fw [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

    " Simply zl/zh to scroll horizontally
    map zl zL
    map zh zH

    " Easier formatting
    " Not sure how that works yet
    " nnoremap <silent> <leader>q gwip

    " FZF {
        " Fuzzy Open files
        nnoremap <silent> <leader>o :Files<CR>

        " Fuzzy open git files 
        nnoremap <silent> <leader>g :GitFiles<CR>

        " Fuzzy open buffer
        nnoremap <silent> <leader>b :Buffers<CR>

        vnoremap <silent> gv :call VisualSelection('gv', '')<CR> 

    " }
    " NERDTree {

        " Locate file in hierarchy quickly
        map <leader>n :NERDTreeFind<cr> 

        " Toggle on/off
        map <leader>nn : NERDTreeToggle<cr>

        " Open up NERDTree at startup
        autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

    " }

    " Switch be3tween the last two files
    nnoremap <leader><leader> <C-^>

    " Allow to copy/paste between VIM instances
    "copy the current visual selection to ~/.vbuf
    vmap <leader>y :w! ~/.vbuf<cr>

    "copy the current line to the buffer file if no visual selection
    nmap <leader>y :.w! ~/.vbuf<cr>

    "paste the contents of the buffer file
    nmap <leader>p :r ~/.vbuf<cr>

    " Make sure that CTRL-A (used by gnu screen) is redefined
    noremap <leader>inc <C-A>

    " Fast saving
    map <Leader>w :w<CR>
    imap <Leader>w <ESC>:w<CR>
    vmap <Leader>w <ESC><ESC>:w<CR>

    " This is totally awesome - remap jj to escape in insert mode.  You'll never type jj anyway, so it's great!
    inoremap jj <esc>
    nnoremap JJJJ <nop>


    " Useful mappings for managing tabs (not sure if I like it) 
    map <leader>tn :tabnew<cr>
    map <leader>to :tabonly<cr>
    map <leader>tc :tabclose<cr>
    map <leader>tm :tabmove<cr>
    map <leader>tj :tabnext<cr>
    map <leader>tk :tabprevious<cr>

    " Let 'tl' toggle between this and the last accessed tab
    let g:lasttab = 1
    nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
    au TabLeave * let g:lasttab = tabpagenr()

    " Opens a new tab with the current buffer's path
    " Super useful when editing files in the same directory
    map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" }


" Use after config if available {
    if filereadable(expand("~/.config/nvim/init.after"))
        source ~/.config/nvim/init.after
    endif
" }
"
" Notes {
    " If escape key takes time to response , it is probably tmux. Add the
        " following to tmux.conf
        " set -s escape-time 0
" }
