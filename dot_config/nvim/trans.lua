-- plugin 
-- jetpack.vim
require'jetpack'.startup(function(use)
  use 'Shougo/neosnippet.vim'
  use 'Shougo/neosnippet-snippets'
  use 'neoclide/coc.nvim'
  use 'cocopon/iceberg.vim'
  use 'rebelot/kanagawa.nvim'
  use 'vim-skk/eskk.vim'
  use 'rust-lang/rust.vim'
  use 'cohama/lexima.vim'
  use 'qnighy/satysfi.vim'
  use 'alaviss/nim.nvim'
  use 'github/copilot.vim'
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
end)

--- まだ
command! Config :e $MYVIMRC
command! I3 :e $HOME/.config/i3/config
command! Judge :! cargo-judge -t %
command! Source :source $MYVIMRC
command! MakeSnippet :!cargo snippet % > ~/.config/nvim/neosnippet-snippet/rust/%<.snip

"competitive programming {
command! Test :!cargo compete t %<
command! Submit :!cargo compete s %<
"}

inoremap <C-f> <C-g>U<ESC><S-a>
nnoremap ; :
set foldmethod=manual
set number
set smartindent
set shiftwidth=4
set autochdir
set encoding=utf-8
set wildmenu
set noswapfile
set background=dark

syntax enable
colorscheme kanagawa

tnoremap <C-t> <C-\><C-n><C-w>k
nnoremap <C-t> <C-w>ji


"rust.vim
let g:rustfmt_autosave=1
"neosnippet.vim
let g:neosnippet#snippets_directory='~/.config/nvim/neosnippet-snippet/'
"coc.nvim
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

"eskk.vim
let g:eskk#directory = "~/.config/eskk"
let g:eskk#dictionary = { 'path': "~/.config/eskk/my_jisyo", 'sorted': 1, 'encoding': 'utf-8',}
let g:eskk#large_dictionary = {'path': "~/.config/eskk/SKK-JISYO.L", 'sorted': 1, 'encoding': 'euc-jp',}
let g:eskk#egg_like_newline = 1
let g:eskk#marker_henkan_select = "[選択]"
let g:eskk#marker_okuri = "[送り]"
let g:eskk#marker_jisyo_touroku = "[辞書]"

"github copilot
 let g:copilot_node_command = "~/.nodenv/versions/17.9.1/bin/node"



autocmd BufRead,BufNewFile *.saty,*.satyh,*satyh-*,*.satyg setlocal filetype=satysfi
filetype plugin indent on


command! ToSnippet call ToSnippet()
function! ToSnippet() abort
    let save_to_path = "~/.config/nvim/neosnippet-snippet/"
    let file_path = expand("%")
    let file_extention = expand("%:e")

    let flag = 0
    let lines = readfile(file_path)
    let snippet = []
    let snippet_name = ""
    for i in range(len(lines))
	if lines[i] =~ "@snippet"
	    let list = split(lines[i], ":")
	    let snippet_name = list[1]
	    let snippet += ["snippet ".list[1]]
	    let flag = 1
	    continue
	endif

	if flag == 1
	    if lines[i] =~ "@endsnippet"
		let flag = 0
		break
		endif
	    let snippet += ["    ".lines[i]]
	endif
    endfor
    echo snippet_name

    let file_name = save_to_path."python/".snippet_name.".snip"   
    " write to file from snippet
    call writefile(snippet, file_name)
    "echo file_name
endfunction

