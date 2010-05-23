" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/HighlightPlugin.vim	[[[1
27
" HighlightPlugin.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Nov 26, 2008
"   Version: 1b	NOT RELEASED
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_HighlightPlugin")
 finish
endif
let g:loaded_HighlightPlugin = "v1b"
let s:keepcpo                = &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Public Interface: {{{1
com! -nargs=* -bar		HLcolor			call Highlight#Color(<f-args>)
com! -count=1 -nargs=*	HLsrch			call Highlight#Srch(<count>,<q-args>)
com! -nargs=? -bar		HLclear			call Highlight#Clear(<f-args>)
nmap <silent>			<Leader>HLw		:<c-u>call Highlight#Srch(v:count,expand("<cword>"))<cr>
nmap <silent>			<Leader>HLl		:<c-u>call Highlight#Srch(v:count,'^\%'.line(".").'l.*$')<cr>
vmap <silent>           <Leader>HL		:<c-u>call Highlight#Srch(v:count,'\%'.line("'<").'l\%'.col("'<").'c\_.*\%'.line("'>").'l\%'.(col("'>")+1).'c')<cr>

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
doc/Highlight.txt	[[[1
109
*Highlight.txt*	Highlighting      				Nov 26, 2008

Author:    Charles E. Campbell, Jr.  <NdrOchip@ScampbellPfamily.AbizM>
           (remove NOSPAM from Campbell's email first)
Copyright: (c) 2008 by Charles E. Campbell, Jr.		*Highlight-copyright*
           The VIM LICENSE applies to Highlight.vim and Highlight.txt
           (see |copyright|) except use "Highlight" instead of "Vim"
           NO WARRANTY, EXPRESS OR IMPLIED.  USE AT-YOUR-OWN-RISK.

==============================================================================
1. Contents					*Highlight* *Highlight-contents* {{{1

	1. Contents.................: |Highlight-contents|
	2. Highlight Manual.........: |Highlight-manual|
	5. Highlight History........: |Highlight-history|

==============================================================================
2. History Manual					*Highlight-manual* {{{1

   The highlight command is designed to work with gvim only.

COMMANDS:

	:HLcolor					*HLcolor*
		Lists currently selected highlighting colors
	
	:HLcolor name name name ...
		Sets list of names to be the highlighting colors.
		Default: HLcolor IndianRed orange3 khaki3 OliveDrab3 ...
		                 MediumSeaGreen CornflowerBlue turquoise3 ...
				 MediumPurple3 burlywood4 grey72

	:[count]HLsrch					*HLsrch*
		Uses the last pattern (|@/|) to highlight with the count'th
		color
	
	:[count]HLsrch pattern
		Uses the specified pattern (|@/|) to highlight with the count'th
		color
	
	:HLclear					*HLclear*
		If the cursor is atop one of the Highlighted patterns, then
		that pattern will be cleared.  Otherwise, all Highlighted
		patterns will be cleared.

	:HLclear 1+
		If a positive integer is given, then the Highlighting for the
		given id will be cleared.

	:HLclear 0
		All Highlighted patterns will be cleared

	:HLclear -1
		If the cursor is atop one of the Highlighted patterns, then
		that pattern will be cleared.  Otherwise, nothing happens.
	
NORMAL MAPS:
	[count]\HLw					*\HLw*
		A HLsrch pattern will be constructed which highlights the
		word under the cursor.  The count'th id highlighting color
		will be used.  ie.  expand("<cword.")

	[count]\HLl					*\HLl*
		A HLsrch pattern will be constructed which highlights the
		line under the cursor.  The count'th id highlighting color
		will be used.  ie.  '^\%'.line(".").'l.*$'

VISUAL MAP:						*\HL*
	[count]\HL
		A HLsrch patttern will be constructed which will highlight
		just the visually selected text. ie.
		'\%'.line("'<").'l\%'.col("'<").'c\_.*\%'.line("'>").'l\%'.(col("'>")+1).'c'

SUGGESTED FUNCTION KEY MAPS:

nmap <silent> <c-F10>	:call Highlight#Clear(-1)<cr>
nmap <silent> <c-F11>	:call Highlight#Srch(v:count,'^\%'.line(".").'l.*$')<cr>
vmap <silent> <c-F11>	:<c-u>call Highlight#Srch(v:count,'\%'.line("'<").'l\%'.col("'<").'c\_.*\%'.line("'>").'l\%'.(col("'>") + (col("'>") != col("$"))).'c')<cr>

With these maps:

	<c-F10>          ctrl-functionkey-10  will clear the Highlighted pattern
	                                      under the cursor.
		
	[count]<c-F11>   ctrl-functionkey-11  (normal mode) will Highlight the
	                                      current line with the count'th
					      Highlighting color.

	[count]<c-F11>   ctrl-functionkey-11  (visual mode) will Highlight the
	                                      current visual block with the
					      count'th Highlighting color.

	As a modification to the above: attempts to re-use a Highlighting
	color will result in the next available Highlighting Color.  With
	the maps above, repeatedly pressing <c-F11> will incrementing the
	Highlighting color.


==============================================================================
3. History						*Highlight-history* {{{1

   	v1	Nov 25, 2008	* The epoch
		Nov 26, 2008	* Added a ColorScheme autocmd so that changes
				  in the colorscheme don't wipe out the High-
				  lighting colors.

==============================================================================
Modelines: {{{1
vim:tw=78:ts=8:ft=help:fdm=marker:
autoload/Highlight.vim	[[[1
191
" Highlight.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Nov 26, 2008
"   Version: 1b	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_Highlight")
 finish
endif
if !has("gui") || !has("gui_running")
 finish
endif
let g:loaded_Highlight= "v1b"
let s:keepcpo      = &cpo
let s:hldict       = {}
set cpo&vim

" =====================================================================
"  Functions: {{{1

" ---------------------------------------------------------------------
" Highlight#Srch: {{{2
fun! Highlight#Srch(cnt,...) range
"  call Dfunc("Highlight#Srch(cnt=".a:cnt." ...) a:0=".a:0)
  let srchpat = @/
  let cnt     = (a:cnt <= 0)? 1 : a:cnt
  " set up default colors if needed
  if len(s:hldict) == 0
   call s:HighlightDefault()
  else
   " hascolor already -- try to find an incremented one
   for hlmtch in getmatches()
"	call Decho("hlmatch".string(hlmtch))
"	call Decho("(prv) id#". (hlmtch.id-3) . "<". (hlmtch.pattern) ."> curline#".line("."))
	if search(hlmtch.pattern,"ncW",line(".")+1) == line(".")
	 " handle incrementing color since characters under cursor are already Highlighted
	 call matchdelete(hlmtch.id)
	 let cnt= hlmtch.id - 3 + 1
	 while 1
"	  call Decho("cnt=".cnt." hlmtch.id=".(hlmtch.id))
	  if cnt == (hlmtch.id-3)
	   echohl WarningMsg|echo "(Highlight#Srch) all colors taken!"|echohl None
"       call Dret("Highlight#Srch : all colors taken")
	   return
	  endif
	  if cnt > len(s:hldict)
	   let cnt= 1
	  endif
"	  call Decho("try id#".cnt)
	  try
	   call matchadd("HL_".s:hldict[cnt],hlmtch.pattern,1,(cnt+3))
	  catch /^Vim\%((\a\+)\)\=:E801/
       let cnt= cnt + 1
       continue
	  endtry
"      call Dret("Highlight#Srch")
	  return
	 endwhile
	endif
   endfor
  endif

  " plain to newly colored
  while cnt <= len(s:hldict)
   if a:0 == 0
"	call Decho("(new1) id#".a:0.": pattern<".@/.">")
    try
	 call matchadd("HL_".s:hldict[cnt],@/,1,cnt+3)
     break
	catch /^Vim\%((\a\+)\)\=:E801/
     let cnt= cnt + 1
     continue
    endtry
   else
"	call Decho("(new2) id#".cnt.": pattern<".a:1.">")
    try
	 call matchadd("HL_".s:hldict[cnt],a:1,1,cnt+3)
     break
	catch /^Vim\%((\a\+)\)\=:E801/
     let cnt= cnt + 1
     continue
    endtry
   endif
  endwhile
  " restore and save matches
  let @/           = srchpat
  let b:curmatches = getmatches()
"  call Dret("Highlight#Srch")
endfun

" ---------------------------------------------------------------------
" Highlight#Color: set/display colors {{{2
"   For some reason, the ColorScheme event only seemed to handle one command; hence,
"   a SETMATCHES color actually invokes setmatches() instead of specifying a color.
fun! Highlight#Color(...)
"  call Dfunc("Highlight#Color() a:0=".a:0)
  if a:0 > 0
   " clear all current colors
   call Highlight#Clear(0)
   " set Highlight color list
   let colorlist = substitute(join(a:000),"SETMATCHES ","","")
   let hlcnt     = 1
   let acnt      = 1
   while acnt <= a:0
	if a:{acnt} == "SETMATCHES"
	 let acnt= acnt + 1
	 continue
	endif
	let s:hldict[hlcnt] = a:{acnt}
	exe "hi HL_".a:{acnt}." guifg=black guibg=".a:{acnt}
	let hlcnt= hlcnt + 1
	let acnt = acnt  + 1
   endwhile
   if acnt != hlcnt
	call setmatches(b:curmatches)
   endif
   if exists("colorlist")
"	call Decho("colorlist<".colorlist.">")
    augroup HighlightColors
     au!
	 exe "au ColorScheme * HLcolor SETMATCHES ".colorlist
    augroup END
   endif
  else
   if len(s:hldict) == 0
	call s:HighlightDefault()
   endif
   " display Highlight color list
   for key in keys(s:hldict)
	exe "echohl HL_".s:hldict[key]
	echo key.': '.s:hldict[key]
   endfor
   echohl NONE
   call inputsave()|call input("Press <cr> to continue")|call inputrestore()
  endif
"  call Dret("Highlight#Color")
endfun

" ---------------------------------------------------------------------
" Highlight#Clear: {{{2
"   0: clear match under cursor; if none, clear all
"   +: clear specified match#
"   -: clear match under cursor (if none, do nothing)
"   Note that the getmatches() ids are 3 greater than those reported by HLcolor,
"   because Highlight#Color doesn't count :match, :2match, and :3match which
"   reserve id#1-3
fun! Highlight#Clear(...)
"  call Dfunc("Highlight#Clear() a:0=".a:0.")")
  if a:0 == 0
   let cnt= -1
  else
   let cnt= a:1
  endif
  if cnt == 0
"   call Decho("clearing all matches")
   call clearmatches()
  elseif cnt > 0
"   call Decho("clearing match with id#".a:cnt)
   call matchdelete(a:cnt+3)
  else
   for hlmtch in getmatches()
"	call Decho("hlmatch".string(hlmtch))
"	call Decho("id#". (hlmtch.id-3) . "<". (hlmtch.pattern) ."> curline#".line("."))
	if search(hlmtch.pattern,"ncW",line(".")+1) == line(".")
"	 call Decho("deleting id#".((hlmtch.id)-3))
	 call matchdelete(hlmtch.id)
"     call Dret("Highlight#Clear")
	 return
	endif
   endfor
   if a:0 == 0
    call clearmatches()
   endif
  endif
"  call Dret("Highlight#Clear")
endfun

" ---------------------------------------------------------------------
" s:HighlightDefault: set up default colors {{{2
fun! s:HighlightDefault()
"  call Dfunc("s:HighlightDefault()")
    "       1         2       3      4          5              6              7          8             9          10
    HLcolor IndianRed orange3 khaki3 OliveDrab3 MediumSeaGreen CornflowerBlue turquoise3 MediumPurple3 burlywood4 grey72
"  call Dret("s:HighlightDefault")
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker