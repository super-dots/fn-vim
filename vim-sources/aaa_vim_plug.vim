
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let s:path = expand('<sfile>:p')
  autocmd VimEnter * PlugInstall --sync | exit
endif


" vim-plug
call plug#begin('~/.vim/plugged')

Plug 'SirVer/ultisnips'

call plug#end()
