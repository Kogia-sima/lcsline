"=============================================================================
" FILE: default.vim
" AUTHOR:  Kogia-sima <orcinus4627@gmail.com>
" License: MIT license
"=============================================================================

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! lcsline#default#segments_left() abort "{{{
  return [
        \ {
        \   'name': 'mode',
        \   'type': 'immediate',
        \   'highlight': 'light',
        \   'active_only': 1,
        \   'content': 'lcsline#mode',
        \   'update': []
        \ },
        \ {
        \   'name': 'branch',
        \   'type': 'lazy',
        \   'highlight': 'middle',
        \   'active_only': 0,
        \   'content': 'lcsline#branch',
        \   'update': ['BufWritePost', 'ShellCmdPost']
        \ },
        \ {
        \   'name': 'filename',
        \   'type': 'string',
        \   'highlight': 'dark',
        \   'active_only': 0,
        \   'content': '%<%f%m',
        \   'update': []
        \ }
        "\ {
        "\   'name': 'coc_status',
        "\   'type': 'lazy',
        "\   'highlight': 'dark',
        "\   'active_only': 1,
        "\   'content': 'lcsline#coc_status',
        "\   'update': ['User CocStatusChange']
        "\ },
        \ ]

endfunction "}}}

function! lcsline#default#segments_right() abort "{{{
  return [
        \ {
        \   'name': 'filetype',
        \   'type': 'lazy',
        \   'highlight': 'dark',
        \   'active_only': 0,
        \   'content': 'lcsline#filetype',
        \   'update': ['FileType']
        \ },
        \ {
        \   'name': 'encoding',
        \   'type': 'lazy',
        \   'highlight': 'middle',
        \   'active_only': 1,
        \   'content': 'lcsline#encoding',
        \   'update': ['BufWritePost']
        \ },
        \ {
        \   'name': 'cursor',
        \   'type': 'string',
        \   'highlight': 'light',
        \   'active_only': 1,
        \   'content': '%2l/%L : %-2v',
        \   'update': []
        \ },
        \ {
        \   'name': 'cocwarning',
        \   'type': 'lazy',
        \   'highlight': ['#000000', '#ffaf00', 0, 255],
        \   'active_only': 1,
        \   'content': 'lcsline#cocwarning',
        \   'update': ['User CocDiagnosticChange']
        \ },
        \ {
        \   'name': 'cocerror',
        \   'type': 'lazy',
        \   'highlight': ['#000000', '#ff0000', 0, 255],
        \   'active_only': 1,
        \   'content': 'lcsline#cocerror',
        \   'update': ['User CocDiagnosticChange']
        \ },
        \ ]
endfunction "}}}

function! lcsline#default#mode_map() abort "{{{
  return {
        \   'n': 'NORMAL',
        \   'no': 'NORMAL',
        \   'nov': 'NORMAL',
        \   'noV': 'NORMAL',
        \   'no': 'VISUAL',
        \   'niI': 'NORMAL',
        \   'niR': 'NORMAL',
        \   'niV': 'NORMAL',
        \   'v': 'VISUAL',
        \   'V': 'VISUAL LINE',
        \   '': 'VISUAL BLOCK',
        \   's': 'SELECT',
        \   'S': 'SELECT LINE',
        \   '': 'SELECT BLOCK',
        \   'i': 'INSERT',
        \   'ic': 'INSERT',
        \   'ix': 'INSERT',
        \   'R': 'REPLACE',
        \   'Rc': 'REPLACE',
        \   'Rv': 'REPLACE',
        \   'Rx': 'REPLACE',
        \   'c': 'COMMAND',
        \   'cv': 'COMMAND',
        \   'ce': 'COMMAND',
        \   'r': 'COMMAND',
        \   'rm': 'COMMAND',
        \   'r?': 'COMMAND',
        \   '!': 'COMMAND',
        \   't': 'TERMINAL',
        \ }
endfunction "}}}

function! lcsline#default#highlights() abort "{{{
  return {
        \   'NORMAL':       [['#00005f', '#dfff00',  16,  33], ['#ffffff', '#444444',  16,  26], ['#9cffd3', '#202020',  33,  16]],
        \   'INSERT':       [['#00005f', '#00dfff',  16,  10], ['#ffffff', '#005fff',  16,   2], ['#ffffff', '#000000',  10,  16]],
        \   'REPLACE':      [['#ff5f00', '#444444',  16,  10], ['#ffffff', '#444444',  16,   2], ['#ffffff', '#000000',  10,  16]],
        \   'VISUAL':       [['#000000', '#ffaf00',  16,   9], ['#000000', '#ff5f00',  16, 160], ['#ffffff', '#5f0000',   9,  16]],
        \   'VISUAL LINE':  [['#000000', '#ffaf00',  16,   9], ['#000000', '#ff5f00',  16, 160], ['#ffffff', '#5f0000',   9,  16]],
        \   'VISUAL BLOCK': [['#000000', '#ffaf00',  16,   9], ['#000000', '#ff5f00',  16, 160], ['#ffffff', '#5f0000',   9,  16]],
        \   'SELECT':       [['#000000', '#ffaf00',  16,   9], ['#000000', '#ff5f00',  16, 160], ['#ffffff', '#5f0000',   9,  16]],
        \   'SELECT LINE':  [['#000000', '#ffaf00',  16,   9], ['#000000', '#ff5f00',  16, 160], ['#ffffff', '#5f0000',   9,  16]],
        \   'SELECT BLOCK': [['#000000', '#ffaf00',  16,   9], ['#000000', '#ff5f00',  16, 160], ['#ffffff', '#5f0000',   9,  16]],
        \   'COMMAND':      [['#0000ff', '#0cff00',  63,  40], ['#ffffff', '#444444', 255, 238], ['#9cffd3', '#202020',  85, 234]],
        \   'TERMINAL':     [['#00005f', '#00ced1',  16,  33], ['#ffffff', '#444444',  16,  26], ['#9cffd3', '#202020',  33,  16]],
        \   'inactive':     [['#000000', '#ffffff', 245, 240], ['#000000', '#ffffff', 245, 240], ['#ffffff', '#000000', 240, 232]],
        \ }
endfunction "}}}
