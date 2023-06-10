"plugin + settings 
call jetpack#begin()
"vim 
call jetpack#add('neoclide/coc.nvim')
call jetpack#add('tani/vim-jetpack')
call jetpack#add('github/copilot.vim')
call jetpack#add('junegunn/fzf')
call jetpack#add('junegunn/fzf.vim')
call jetpack#add('lambdalisue/fern.vim')
call jetpack#add('simeji/winresizer')
call jetpack#add('vim-skk/eskk.vim')
call jetpack#add('machakann/vim-sandwich')
call jetpack#add('rhysd/clever-f.vim')
call jetpack#add('Shougo/neosnippet.vim')
call jetpack#add('Shougo/neosnippet-snippets')
call jetpack#add('jeetsukumaran/vim-indentwise')
call jetpack#add('tyru/capture.vim')
call jetpack#add('cohama/lexima.vim')
"debug 
call jetpack#add('sentriz/vim-print-debug')
call jetpack#add('mfussenegger/nvim-dap')
call jetpack#add('rcarriga/nvim-dap-ui')
"git
call jetpack#add('iberianpig/tig-explorer.vim')
"language
call jetpack#add('andreypopp/julia-repl-vim')
call jetpack#add('JuliaEditorSupport/julia-vim')
call jetpack#add('rust-lang/rust.vim')
call jetpack#add('qnighy/satysfi.vim')
call jetpack#add('alaviss/nim.nvim')
call jetpack#add('fatih/vim-go')
call jetpack#add('mattn/emmet-vim')
"clolor scheme
call jetpack#add('cocopon/iceberg.vim')
call jetpack#add('rebelot/kanagawa.nvim')
"?
call jetpack#add('Vigemus/iron.nvim')
call jetpack#add('lambdalisue/readablefold.vim')
call jetpack#add('yutkat/history-ignore.vim')
call jetpack#add('gorodinskiy/vim-coloresque')
call jetpack#add('lukas-reineke/indent-blankline.nvim')
call jetpack#add('nk0086/tosnippet.vim')
call jetpack#add('mattn/vim-maketabel')
call jetpack#end()

command! Config :tabe $MYVIMRC
command! Source :source $MYVIMRC
command! MakeSnippet :!cargo snippet % > $HOME/.config/nvim/neosnippet-snippet/rust/%<.snip
command! Test :!cargo compete test %<
command! Sub :!cargo compete submit %<

" the function of open terminal in right side
function! OpenTerminal()
	:vsplit
	:wincmd l
	:terminal
endfunction
command! Terminal :call OpenTerminal()


"auto-command
autocmd BufWritePost *.saty !satysfi % > /dev/null
autocmd BufWritePost *.rs silent !rustfmt %
"julia
function! JuliaREPL()
    :vsplit
    :terminal julia --project
    :wincmd l
endfunction

nnoremap <C-j> :call JuliaREPL()<CR>


inoremap <C-f> <C-g>U<ESC><S-a>
nnoremap <C-y> "+y
vnoremap <C-y> "+y
nnoremap ; :

" move window
nnoremap sh <C-w>h
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sH <C-w>H
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
tnoremap <C-t> <C-\><C-n><C-w>k
nnoremap <C-t> <C-w>v

set foldmethod=manual
set number
set smartindent
set shiftwidth=4
set autochdir
set encoding=utf-8
set termencoding=utf-8
set wildmenu
set noswapfile
set background=dark
set listchars=eol:¬,tab:>-,trail:~,extends:>,precedes:<,nbsp:.

syntax enable
filetype plugin indent on
colorscheme kanagawa

"fern.vim
nnoremap <C-n> :Fern . -reveal=% -drawer -toggle -width=40<CR>
let g:fern#renderer = 'nerdfont'

"fzf
let $FZF_DEFAULT_OPTS="--layout=reverse"
let $FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/**'"
let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.8,'yoffset':0.5,'xoffset': 0.5, 'border': 'sharp' } }

let mapleader = "\<Space>"

" fzf
" <C-v> width
" <C-x> height
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>r :Rg<CR>
nnoremap <silent> <leader>g :GFiles<CR>
nnoremap <silent> <leader>G :GFiles?<CR>
nnoremap <silent> <leader>h :History:<CR>
nnoremap <silent> <leader>c :Commands<CR>
nnoremap <silent> <leader>b :Buffers<CR>

" vim-print-debug
nnoremap <leader>p :call print_debug#print_debug()<cr>
let g:print_debug_templates = {
\   'go':         'fmt.Printf("+++ {}\n")',
\   'python':     'print(f"+++ {}")',
\   'rust': 	  'println!("+++ {}");',
\   'javascript': 'console.log(`+++ {}`);',
\   'c':          'printf("+++ {}\n");',
\ }

"rust.vim
let g:rustfmt_autosave=1
"neosnippet.vim
let g:neosnippet#snippets_directory = $HOME."/.config/nvim/neosnippet-snippet/"
"coc.nvim
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

"nim.nvim
let g:nim_nimsuggest_path = $HOME."/.nimble/bin/nimsuggest"
let g:nim_nvim_nimpretty_path = $HOME."/.nimble/bin/nimpretty"
if executable("nim")
    source $HOME/.config/nvim/autocmd.rc.vim
endif

"eskk.vim
let g:eskk#directory = "~/.config/eskk"
let g:eskk#dictionary = { 'path': g:eskk#directory."/my_jisyo", 'sorted': 1, 'encoding': 'utf-8',}
let g:eskk#default_dictionary_path = { 'path': g:eskk#directory."/SKK-JISYO.L", 'sorted': 1, 'encoding': 'euc-jp',}
let g:eskk#egg_like_newline = 1
let g:eskk#marker_henkan_select = "[選択]"
let g:eskk#marker_okuri = "[送り]"
let g:eskk#marker_jisyo_touroku = "[辞書]"

"winresizer
nnoremap <silent> <C-r> :WinResizerStartResize<CR>

"github copilot
let g:copilot_node_command = "/usr/bin/node"
let g:copilot_filetypes = {
    \ 'satysfi': v:false,
    \ }

"ToSnipet
let g:tosnippet#save_directory = $HOME."/.config/nvim/neosnippet-snippet/"

autocmd BufRead,BufNewFile *.saty,*.satyh,*satyh-*,*.satyg setlocal filetype=satysfi
filetype plugin indent on

command! Preview call Preview()
function! Preview() abort
    let file = expand('%:p')
    :!satysfi % > /dev/null
    ":!xdg-open %<.pdf
endfunction


let g:user_emmet_install_global = 0
autocmd FileType html,css,eruby EmmetInstall
