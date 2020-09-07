" Install vim-plug if not installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Visual
Plug 'itchyny/lightline.vim'
Plug 'morhetz/gruvbox'

" Editing
Plug 'unblevable/quick-scope'
Plug 'fholgado/minibufexpl.vim'
Plug 'tpope/vim-commentary'
Plug 'sickill/vim-pasta'

" Utils
Plug 'ctrlpvim/ctrlp.vim'

call plug#end()

set laststatus=2 " Otherwise lightline won't show
set noshowmode " Hides unnecessary mode at bottom
let g:lightline = { 'colorscheme': 'wombat' }

colorscheme gruvbox
set background=dark

" Line numbering
set number
set relativenumber

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" Shows tabs and trailing chars
set list
set listchars=tab:>-,trail:~

set noswapfile
set autoindent
set tabstop=4
set shiftwidth=4
set hidden
set textwidth=80
set colorcolumn=+1
set smartcase " Makes search case sensitive if you use uppercase letters
set scrolloff=4
set ssop-=options " Don't keep options between sessions
set spell spelllang=en
set nospell
set formatoptions=cro " Automatic comment continuation on next line
set completeopt+=longest

" Tab completion in insert mode
" inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-x>\<C-n>"
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-p>"

augroup filetypes
	autocmd!

	autocmd FileType python,html,htmldjango set expandtab

augroup END

" Mappings
command! Wq wq
command! WQ wq
command! W w
command! Q q

let mapleader = " "

noremap <C-k> :bprev<cr>
noremap <C-j> :bnext<cr>
noremap <C-=> <C-w>=
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l

nnoremap _ ddp==
nnoremap + ddkP==

nnoremap <leader>cl :silent! % s/\s\+$//g \| nohl<cr>
nnoremap <leader>en :vsp $MYVIMRC<cr>
nnoremap <leader>sn :source $MYVIMRC<cr>

nnoremap <leader>ms :mksession! ~/.vimsession<cr>
nnoremap <leader>ss :source ~/.vimsession<cr>

nnoremap <leader>w :w<cr>
nnoremap <leader>nh :nohl<cr>
nnoremap <leader>rw :%s/\s\+$//e<cr>

inoremap <silent><expr> <BS> pumvisible() ? "\<C-y>" : "\<BS>"
inoremap <S-Tab> <C-V><Tab>

nnoremap <leader>ll :set textwidth=0<cr>
nnoremap <leader>nl :set textwidth=80<cr>

nnoremap <leader>bd :bd<cr>
nnoremap <leader>bc :bn<bar>vs<bar>bp<bar>bd<cr>

nnoremap < :vertical resize -5<cr>
nnoremap > :vertical resize +5<cr>

vnoremap <C-c> :w !xclip -i -sel c<CR><CR>
" noremap <C-v> :r !pbpaste<CR><CR>

" Plugin settings
" Quickscrope
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" ctrlp
 let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
