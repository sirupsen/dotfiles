function! g:Execrus()
  let current_file = expand("%")
  let max_plugin = {'priority': -1}

  for plugin in b:execrus_plugins
    if call(plugin['condition'], [current_file, &filetype]) 
      && plugin['priority'] > max_plugin['priority']
      let max_plugin = plugin
    end
  endfor

  if max_plugin['priority'] != -1
    call call(max_plugin['exec'], [current_file])
  end
endfunction

map <C-E> :call g:Execrus()<CR>
