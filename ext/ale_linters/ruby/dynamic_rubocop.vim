" Author: ynonp - https://github.com/ynonp, Eddie Lebow https://github.com/elebow
" Description: RuboCop, a code style analyzer for Ruby files

"call ale#Set('ruby_rubocop_executable', 'rubocop')
"call ale#Set('ruby_rubocop_options', '')

let g:dynamic_rubocop_vim_path = expand('<sfile>:p')

function! ale_linters#ruby#dynamic_rubocop#GetExecutable(_arg) abort
    let l:path = fnamemodify(g:dynamic_rubocop_vim_path, ':h')
    return l:path . '/../../bin/dynamic-rubocop'
endfunction

function! ale_linters#ruby#dynamic_rubocop#GetCommand(buffer) abort
    let l:executable = ale_linters#ruby#dynamic_rubocop#GetExecutable('')

    return ale#ruby#EscapeExecutable(l:executable, 'rubocop')
    \   . ' --format json --force-exclusion '
    \   . ale#Var(a:buffer, 'ruby_rubocop_options')
    \   . ' --stdin %s'
endfunction

function! ale_linters#ruby#dynamic_rubocop#GetType(severity) abort
    if a:severity is? 'convention'
    \|| a:severity is? 'warning'
    \|| a:severity is? 'refactor'
        return 'W'
    endif

    return 'E'
endfunction

call ale#linter#Define('ruby', {
\   'name': 'dynamic-rubocop',
\   'executable': function('ale_linters#ruby#dynamic_rubocop#GetExecutable'),
\   'command': function('ale_linters#ruby#dynamic_rubocop#GetCommand'),
\   'callback': 'ale#ruby#HandleRubocopOutput',
\})
