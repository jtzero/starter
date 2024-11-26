let g:dynamic_rubocop_vim_path = expand('<sfile>:p')

function! ale_linters#ruby#dynamic_rubocop#GetExecutable(_arg) abort
    let l:path = fnamemodify(g:dynamic_rubocop_vim_path, ':h')
    return l:path . '/../../../bin/dynamic-rubocop'
endfunction

function! ale#fixers#dynamic_rubocop#GetCommand(buffer) abort
    let l:executable = ale_linters#ruby#dynamic_rubocop#GetExecutable('')
    let l:options = ale#Var(a:buffer, 'ruby_rubocop_options')
    let l:auto_correct_all = ale#Var(a:buffer, 'ruby_rubocop_auto_correct_all')

    return ale#ruby#EscapeExecutable(l:executable, 'rubocop')
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . (l:auto_correct_all ? ' --auto-correct-all' : ' --auto-correct')
    \   . ' --force-exclusion --stdin %s'
endfunction

function! ale#fixers#dynamic_rubocop#Fix(buffer) abort
    return {
    \   'command': ale#fixers#dynamic_rubocop#GetCommand(a:buffer),
    \   'process_with': 'ale#fixers#rubocop#PostProcess'
    \}
endfunction
