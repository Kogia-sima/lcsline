"=============================================================================
" FILE: lcsline.vim
" AUTHOR:  Kogia-sima <orcinus4627@gmail.com>
" License: MIT license
"=============================================================================

scriptencoding utf-8

if exists('g:loaded_lcsline')
  finish
endif
let g:loaded_lcsline = 1

function! s:set(name) abort "{{{
  let l:var = 'g:lcsline_' . a:name
  if !exists(l:var)
    let l:func = 'lcsline#default#' . a:name
    let {l:var} = call(l:func, [])
  endif
endfunction "}}}

function! s:extend(name) abort "{{{
  let l:var = 'g:lcsline_' . a:name
  let l:func = 'lcsline#default#' . a:name
  let l:default = call(l:func, [])
  if !exists(l:var)
    let {l:var} = l:default
  else
    let {l:var} = extend(l:default, {l:var})
  endif
endfunction "}}}

call s:set('segments_left')
call s:set('segments_right')
call s:extend('mode_map')
call s:extend('highlights')

augroup lcsline_config
  autocmd VimEnter * call lcsline#init()
  autocmd WinEnter * call lcsline#render_all()
  autocmd BufWinEnter * call lcsline#update_current()
  "autocmd SessionLoadPost * call lcsline#update()
  autocmd User LCSLineModeChanged call lcsline#highlight()
augroup END
