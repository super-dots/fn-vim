

" add this ultisnips directory to the search path

let s:this_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

if !exists("g:UltiSnipsSnippetDirectories")
    let g:UltiSnipsSnippetDirectories=[]
endif

let g:UltiSnipsSnippetDirectories=add(g:UltiSnipsSnippetDirectories, s:this_dir."/ultisnippets")
