" Vim global plugin for selecting the file you actually want to open
" Last Change: 2015-04-22
" Maintainer: Daniel Schemala <istjanichtzufassen@gmail.com>
" License: MIT


function! s:filter_out_swapfile(matched_files)
    silent! redir => swapfile
        silent swapname
    redir END
    let swapfile = fnamemodify(swapfile[1:], ':t')

    return filter(a:matched_files, 'v:val != swapfile')
endfunction


function! s:didyoumean()
    if filereadable(expand("%"))
        " Another BufNewFile event might have handled this already.
        return
    endif
    try
        " As of Vim 7.4, glob() has an optional parameter to split, but not
        " everybody is using 7.4 yet
        let matching_files = split(glob(expand("%")."*", 0), '\n')
        if !len(matching_files)
            let matching_files = split(glob(expand("%")."*", 1), '\n')
        endif
        let matching_files = s:filter_out_swapfile(matching_files)
        if empty(matching_files)
            return
        endif
    catch
        return
    endtry

    if len(matching_files) > 1
        if len(matching_files) == 1
            let selected_number = 1
        else
            let shown_items = ['Did you mean:']
            for i in range(1, len(matching_files))
                call add(shown_items, i.'. '.matching_files[i-1])
            endfor
        let selected_number = inputlist(shown_items)
        endif
    endif
    if selected_number >= 1 && selected_number <= len(matching_files)
        let empty_buffer_nr = bufnr("%")
        execute ":edit " . fnameescape(matching_files[selected_number-1])
        execute ":silent bdelete " . empty_buffer_nr
        filetype detect  " without this line, the filetype is not set
    endif
endfunction


autocmd BufNewFile * call s:didyoumean()
