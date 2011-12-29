"=============================================================================
" A ref source for OxfordDictionry
" URL: http://oxforddictionaries.com/
"
" File    : autoload/ref/oxford.vim
" Updated : 2011-12-29
" Version : 0.0.1
" License : MIT license {{{
"
"   Permission is hereby granted, free of charge, to any person obtaining
"   a copy of this software and associated documentation files (the
"   "Software"), to deal in the Software without restriction, including
"   without limitation the rights to use, copy, modify, merge, publish,
"   distribute, sublicense, and/or sell copies of the Software, and to
"   permit persons to whom the Software is furnished to do so, subject to
"   the following conditions:
"
"   The above copyright notice and this permission notice shall be included
"   in all copies or substantial portions of the Software.
"
"   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! ref#oxford#define()
  return s:source
endfunction

"-----------------------------------------------------------------------------

if exists('g:ref_alc_cmd')
  let s:get_cmd = g:ref_alc_cmd
else
  let s:get_cmd =
        \ executable('elinks') ? 'elinks -dump -no-numbering -no-references %s' :
        \ executable('w3m')    ? 'w3m -dump %s' :
        \ executable('links')  ? 'links -dump %s' :
        \ executable('lynx')   ? 'lynx -dump -nonumbers %s' :
        \ ''
endif

if !exists('g:ref_oxford_use_cache')
  let g:ref_oxford_use_cache = 1
endif

"----------------------------------------------------------------------------
" Source

let s:source = { 'name': 'oxford' }

function! s:source.available()
  return !empty(s:get_cmd)
endfunction

function! s:source.normalize(query)
  let query = substitute(substitute(a:query, '^\s*', '', ''), '\s*$', '', '')
  let query =  substitute(a:query, '\s\+', '+', 'g')
  return query
endfunction

function! s:source.get_body(query)
  if type(s:get_cmd) == type('')
    let cmdline = split(s:get_cmd, '\s\+')
  elseif type(s:get_cmd) == type([])
    let cmdline = copy(s:get_cmd)
  else
    return ''
  endif
  let url = 'http://oxforddictionaries.com/definition/' . a:query
  call map(cmdline, 'substitute(v:val, "%s", url, "g")')
  if g:ref_oxford_use_cache
    let expr = 'ref#system(' . string(cmdline) . ').stdout'
    let resp = join(ref#cache('oxford', a:query, expr), "\n")
  else
    let resp = ref#system(cmdline).stdout
  endif
  return resp
endfunction

function! s:source.opened(query)
  let save_lazyredraw = &lazyredraw
  set lazyredraw
  call s:format()
  " Move the cursor to the viewing position.
  call cursor(1, 1)
  call search('^ '.a:query, 'W')
  execute "normal! z\<CR>"
  call s:highlight(a:query)
  redraw!
  let &lazyredraw = save_lazyredraw
endfunction

function! s:format()
endfunction

function! s:highlight(query)
  syntax clear
  let pattern = escape(substitute(a:query, '+', '\\_s\\+', 'g'), '/')
  execute 'syntax match refOxfordDictKeyword /\c\<' . pattern . '/'
  highlight default link refOxfordDictKeyword Special
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: filetype=vim
