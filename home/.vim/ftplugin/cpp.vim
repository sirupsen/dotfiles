if !exists('b:execrus_plugins')
  let b:execrus_plugins = []
end

function! g:DefaultCPlusPlusCompile(file)
  let s:executeable = substitute(a:file, ".cpp", "", "")
  let s:compile_command = "!clang++ " . a:file . " -o " . s:executeable . " -O2 -std=c++0x -stdlib=libc++ -pedantic"
endfunction

function! g:DefaultCPlusPlusExecute(file)
  call g:DefaultCPlusPlusCompile(a:file)
  execute s:compile_command . ' && ' . s:executeable
endfunction

function! g:DefaultCPlusPlusCondition(file, filetype)
  return match(a:filetype, 'cpp') == 0
endfunction

let b:execrus_plugins += [{'name': 'Default C++', 'condition': function("g:DefaultCPlusPlusCondition"), 'exec': function("g:DefaultCPlusPlusExecute"), 'priority': 1}]
