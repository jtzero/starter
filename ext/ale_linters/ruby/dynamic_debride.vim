" Author: Eddie Lebow https://github.com/elebow
" Description: debride, a dead method detector for Ruby files

"call ale#Set('ruby_debride_executable', 'debride')
"call ale#Set('ruby_debride_options', '')

let g:dynamic_debride_vim_path = expand('<sfile>:p')

function! ale_linters#ruby#dynamic_debride#GetExecutable(_arg) abort
    let l:path = fnamemodify(g:dynamic_debride_vim_path, ':h')
    return l:path . '/../../bin/dynamic-debride'
endfunction

function! ale_linters#ruby#dynamic_debride#GetCommand(buffer) abort
    let l:executable = ale_linters#ruby#dynamic_debride#GetExecutable('')

    return ale#ruby#EscapeExecutable(l:executable, 'debride')
    \   . ale#Var(a:buffer, 'ruby_debride_options')
    \   . ' %s'
endfunction

function! ale_linters#ruby#dynamic_debride#HandleOutput(buffer, lines) abort
    let l:output = []

    for l:line in a:lines
        if l:line !~# '^  '
            continue
        endif

        let l:elements = split(l:line)
        let l:method_name = l:elements[0]
        let l:lnum = split(l:elements[1], ':')[1]

        call add(l:output, {
        \   'lnum': 0 + l:lnum,
        \   'text': 'Possible unused method: ' . l:method_name,
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('ruby', {
\   'name': 'dynamic-debride',
\   'executable': function('ale_linters#ruby#dynamic_debride#GetExecutable'),
\   'command': function('ale_linters#ruby#dynamic_debride#GetCommand'),
\   'callback': 'ale_linters#ruby#dynamic_debride#HandleOutput',
\})
