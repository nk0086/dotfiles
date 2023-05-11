if executable("nim")
    augroup MyNimCmd
        " nimファイル開いたときにfiletypeを勝手にnimにしてくれないのでわざわざautocmdで書く
        autocmd BufNewFile,BufRead *.nim,*.nimble set filetype=nim
        " 保存するたびにフォーマッタによる整形
        autocmd BufWritePost *.nim,*.nimble !nimpretty %
        " 実行
        autocmd FileType nim command! -nargs=* NimRun :sp <Bar> term nim c -r <args> %
        " ビルド
        autocmd FileType nim command! -nargs=* NimBuild :sp <Bar> term nim c <args> %
        " ライブラリとしてビルド(Pythonとの連携なんかに使う)
        autocmd FileType nim command! -nargs=* NimBuildLib :!nim c --tlsEmulation:off --app:lib --out:%:t:r.so <args> %
    augroup END
endif
