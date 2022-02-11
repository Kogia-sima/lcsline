"=============================================================================
" FILE: lcsline.vim
" AUTHOR:  Kogia-sima <orcinus4627@gmail.com>
" License: MIT license
"=============================================================================

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:mode_segments_exists = 0

function! s:generate_segments() abort "{{{
  " TODO: Generate lcsline_segments_* from configuration
  for l:segments in [g:lcsline_segments_left, g:lcsline_segments_right]
    for l:segment in l:segments
      if l:segment.content ==# 'lcsline#mode'
        let s:mode_segments_exists = 1
        return
      endif
    endfor
  endfor
endfunction "}}}

function! s:generate_highlights() abort "{{{
  let l:index = 0
  for l:segments in [g:lcsline_segments_left, g:lcsline_segments_right]
    for l:segment in l:segments
      let l:key = 'lcsline_section_a' . l:index
      if type(l:segment.highlight) == v:t_list
        let l:colors = l:segment.highlight
        let l:command = printf('hi %s guifg=%s guibg=%s ctermfg=%s ctermbg=%s', l:key, l:colors[0], l:colors[1], l:colors[2], l:colors[3])
        silent execute l:command
      elseif type(l:segment.highlight) == v:t_string
        let l:target_key = 'lcsline_hl_' . l:segment.highlight
        let l:command = printf('hi link %s %s', l:key, l:target_key)
      else
        throw 'Invalid highlight type detected.'
      endif
      silent execute l:command
      let l:index += 1
    endfor
  endfor

  call lcsline#highlight()
endfunction "}}}

function! s:generate_autocmds() abort "{{{
  let l:index = 0
  let l:autocmd_map = {}
  for l:segments in [g:lcsline_segments_left, g:lcsline_segments_right]
    for l:segment in l:segments
      for l:event in l:segment.update
        if has_key(l:autocmd_map, l:event)
          call add(l:autocmd_map[l:event], l:index)
        else
          let l:autocmd_map[l:event] = [l:index]
        endif
      endfor
      let l:index += 1
    endfor
  endfor

  let g:autocmd_map = l:autocmd_map

  for [l:event, l:indices] in items(l:autocmd_map)
    if stridx(l:event, ' ') != -1
      let l:command = printf('autocmd %s call lcsline#update_segments(%s)', l:event, string(l:indices))
    else
      let l:command = printf('autocmd %s * call lcsline#update_segments(%s)', l:event, string(l:indices))
    endif
    augroup lcsline_autocmds
      silent execute l:command
    augroup END
  endfor
endfunction "}}}

function! s:generate_cache() abort "{{{
  let l:cache = []
  for l:segments in [g:lcsline_segments_left, g:lcsline_segments_right]
    for l:segment in l:segments
      let l:info = {'active_only': l:segment.active_only, 'highlight': string(l:segment.highlight)}
      if l:segment.type == 'string'
        let l:info.content = l:segment.content
      elseif l:segment.type == 'lazy'
        let l:info.content = call(l:segment.content, [])
      elseif l:segment.type == 'immediate'
        let l:info.content = '%{' . l:segment.content . '()}'
      endif
      call add(l:cache, l:info)
    endfor
  endfor

  let w:lcsline_cache = l:cache
endfunction "}}}

let s:count = 0
function! s:render(is_active) abort "{{{
  let l:cache = getwinvar(winnr(), 'lcsline_cache')
  let s:count += 1

  if empty(l:cache)
    call s:generate_cache()
    let l:cache = getwinvar(winnr(), 'lcsline_cache')
  endif

  let l:line = s:mode_segments_exists ? '' : '%{lcsline#check_mode()}'
  let l:index = 0
  let l:prefix = a:is_active ? 'a' : 'i'
  let l:last_highlight = ''

  for l:part in l:cache
    if !empty(l:part.content) && (a:is_active || !l:part.active_only)
      if l:index != len(g:lcsline_segments_left) && l:part.highlight == l:last_highlight
        let l:line .= '│'
      endif
      if a:is_active
        let l:key = 'lcsline_section_' . l:prefix . l:index
        let l:line .= '%#' . l:key . '# ' . l:part.content . ' '
      else
        let l:line .= ' ' . l:part.content . ' '
      endif
      let l:last_highlight = l:part.highlight
    endif

    if l:index == len(g:lcsline_segments_left) - 1
      let l:line .= '%='
    endif

    let l:index += 1
  endfor

  call setwinvar(winnr(), '&statusline', l:line)
endfunction "}}}

function! lcsline#init() abort "{{{
  call s:generate_segments()
  call s:generate_highlights()
  call s:generate_autocmds()
  call lcsline#update()
endfunction "}}}

function! lcsline#update() abort "{{{
  let l:active_window = winnr()
  let l:winid = win_getid()
  windo call s:generate_cache()
  windo call s:render(l:active_window == winnr())
  call win_gotoid(l:winid)
  call lcsline#highlight()
endfunction "}}}

function! lcsline#update_segments(indices) abort "{{{
  let l:cache = getwinvar(winnr(), 'lcsline_cache')
  if empty(l:cache)
    call s:generate_cache()
    return
  endif
  let l:left_len = len(g:lcsline_segments_left)
  for l:i in a:indices
    if l:i < l:left_len
      let l:cache[l:i].content = call(g:lcsline_segments_left[l:i].content, [])
    else
      let l:cache[l:i].content = call(g:lcsline_segments_right[l:i - l:left_len].content, [])
    endif
  endfor
  call s:render(1)
endfunction "}}}

function! lcsline#highlight() abort "{{{
  " TODO: update highlights
  let l:new_mode = g:lcsline_mode_map[mode()]
  if l:new_mode == 'TERMINAL'
    echo l:new_mode
  endif
  let l:hl = get(g:lcsline_highlights, l:new_mode, g:lcsline_highlights['NORMAL'])
  "call writefile([string(l:hl)], '/tmp/vim_hl.log', 'a')

  silent execute printf('hi! lcsline_hl_light guifg=%s guibg=%s ctermfg=%d, ctermbg=%d', l:hl[0][0], l:hl[0][1], l:hl[0][2], l:hl[0][3])
  silent execute printf('hi! lcsline_hl_middle guifg=%s guibg=%s ctermfg=%d, ctermbg=%d', l:hl[1][0], l:hl[1][1], l:hl[1][2], l:hl[1][3])
  silent execute printf('hi! lcsline_hl_dark guifg=%s guibg=%s ctermfg=%d, ctermbg=%d', l:hl[2][0], l:hl[2][1], l:hl[2][2], l:hl[2][3])
endfunction "}}}

let s:mode = 'NORMAL'

" ---------- Component functions ---------- {{{
function! lcsline#check_mode() abort "{{{
  let l:new_mode = g:lcsline_mode_map[mode()]
  if l:new_mode !=# s:mode
    let s:mode = l:new_mode
    silent doautocmd User LCSLineModeChanged
  endif
  return ''
endfunction "}}}

function! lcsline#render_all() abort "{{{
  let l:active_window = winnr()
  let l:winid = win_getid()
  windo call s:render(l:active_window == winnr())
  call win_gotoid(l:winid)
endfunction "}}}

function! lcsline#update_current() abort "{{{
  call s:generate_cache()
  call s:render(1)
endfunction "}}}

function! lcsline#mode() abort "{{{
  let l:new_mode = g:lcsline_mode_map[mode()]
  if l:new_mode !=# s:mode
    let s:mode = l:new_mode
    silent doautocmd User LCSLineModeChanged
  endif
  return l:new_mode
endfunction "}}}

function! lcsline#branch() abort "{{{
  if winwidth(0) < 50
    return ''
  endif
  let l:path = expand('%')
  if isdirectory(l:path) || (&buftype =~# 'nofile\|quickfix\|help')
    return ''
  endif

  let l:branch = substitute(system('git -C ' . fnamemodify(l:path, ':p:h') . ' symbolic-ref --short -q HEAD'), '[\0x08\r\t\n ]*$', '', '')
  if v:shell_error != 0 || l:branch ==# ''
    return ''
  endif

  return ' ' . l:branch
endfunction "}}}

function! lcsline#filetype() abort "{{{
  return &filetype
endfunction "}}}

function! lcsline#encoding() abort "{{{
  if winwidth(0) < 50
    return ''
  endif
  if empty(&fileformat)
    return &encoding
  else
    return printf('%s[%s]', &fileencoding !=# "" ? &fileencoding : &encoding, &fileformat)
  endif
endfunction "}}}

function! lcsline#debug_count() abort "{{{
  return printf("(%d)", s:count)
endfunction "}}}

function! lcsline#quickrun_running() abort "{{{
  
endfunction "}}}

let s:diagnostics = {}
function! s:lc_record_diagnostics(state) abort "{{{
  if has_key(a:state, 'result')
    let s:diagnostics = json_decode(a:state.result).diagnostics
    doautocmd User LcsLineLspDiagnostics
  endif
endfunction "}}}

function! s:lc_diagnostics() abort "{{{
  call LanguageClient#getState(function("s:lc_record_diagnostics"))
endfunction "}}}

function! lcsline#lspwarning() abort "{{{
  let l:cnt = 0

  for l:d in get(s:diagnostics, expand('%:p'), [])
    if has_key(l:d, 'severity') && l:d.severity == 2
      let l:cnt += 1
    endif
  endfor

  return l:cnt == 0 ? '' : printf("⚠" . ' %d', l:cnt)
endfunction "}}}

function! lcsline#lsperror() abort "{{{
  let l:cnt = 0

  for l:d in get(s:diagnostics, expand('%:p'), [])
    if has_key(l:d, 'severity') && l:d.severity == 1
      let l:cnt += 1
    endif
  endfor

  return l:cnt == 0 ? '' : printf("✗" . ' %d', l:cnt)
endfunction "}}}

function! lcsline#cocwarning() abort "{{{
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) | return '' | endif
  let l:cnt = get(info, 'warning', 0)

  return l:cnt == 0 ? '' : "⚠ " . l:cnt
endfunction "}}}

function! lcsline#cocerror() abort "{{{
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) | return '' | endif
  let l:cnt = get(info, 'error', 0)

  return l:cnt == 0 ? '' : "✗ " . l:cnt
endfunction "}}}

function! lcsline#coc_status() abort "{{{
  let l:win_width = winwidth(0)
  if l:win_width < 120
    return ''
  endif

  return trim(strpart(get(g:, 'coc_status', ''), 0, l:win_width - 80))
endfunction "}}}

augroup lcsline_config
  autocmd User LanguageClientDiagnosticsChanged call <sid>lc_diagnostics()
augroup END

"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
