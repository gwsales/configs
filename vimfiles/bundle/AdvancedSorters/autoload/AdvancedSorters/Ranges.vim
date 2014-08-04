" AdvancedSorters/Ranges.vim: Sorting of whole ranges as one unit.
"
" DEPENDENCIES:
"   - ingo/cmdargs/pattern.vim autoload script
"   - ingo/cmdargs/range.vim autoload script
"   - ingo/collections.vim autoload script
"   - ingo/compat.vim autoload script
"   - ingo/err.vim autoload script
"   - ingo/join.vim autoload script
"   - ingo/range/lines.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.01.004	11-Jun-2014	Make :SortRangesByRange work for Vim versions
"				before 7.4.218 that don't have uniq().
"   1.00.003	10-Jun-2014	Implement :SortRangesByRange command.
"				Pass a:ArgumentParser to s:JoinRanges() to
"				accommodate the different parsing for
"				:SortRangesByRange.
"	002	09-Jun-2014	Account for the reduced end line number when the
"				"u" flag is passed and there are duplicate lines.
"	001	08-Jun-2014	file creation from ingocommands.vim

function! s:SortRanges( bang, startLnum, endLnum, sortArgs, rangeName, rangeNum, joinCnt )
    if empty(a:rangeNum)
	call ingo#err#Set(printf('No %s found', a:rangeName))
	return 0
    endif

    let l:reducedEndLnum = a:endLnum - a:joinCnt
    let l:lastLnum = line('$')  " When the "u" flag is passed, duplicate lines reduce the number of lines.
    let l:sortOffset = 0        " Account for the reduced end line number when undoing the join.
    try
	execute printf('%d,%dsort%s %s', a:startLnum, l:reducedEndLnum, a:bang, a:sortArgs)
	let l:sortOffset = line('$') - l:lastLnum
	return 1
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return 0
    finally
	silent execute printf('%d,%dsubstitute/\%%d0/\r/ge', a:startLnum, l:reducedEndLnum + l:sortOffset)
	call histdel('search', -1)
    endtry
endfunction
function! AdvancedSorters#Ranges#Unfolded( bang, startLnum, endLnum, sortArgs )
    let [l:foldNum, l:joinCnt] = ingo#join#FoldedLines(1, a:startLnum, a:endLnum, "\<C-v>\<C-j>")
    return s:SortRanges(a:bang, a:startLnum, a:endLnum, a:sortArgs, 'folds', l:foldNum, l:joinCnt)
endfunction

let s:sortFlagsExpr = '[iurnxo[:space:]]'
function! s:GetSortArgumentsExpr( captureNum, flagsCardinality, ... )
    return '\s*\(' . s:sortFlagsExpr . a:flagsCardinality . '\%(\([[:alnum:]\\"|]\@![\x00-\xFF]\)\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\' . a:captureNum . '\)\?\)' . (a:0 ? a:1 : '')
endfunction
function! s:ParseExpressionAndSortArguments( arguments )
    return ingo#cmdargs#pattern#ParseUnescaped(a:arguments, s:GetSortArgumentsExpr(4, '*'))
endfunction
function! s:JoinRanges( bang, startLnum, endLnum, arguments, ArgumentParser, rangeName, RangeCreator )
    let [l:expr, l:sortArgs] = call(a:ArgumentParser, [a:arguments])

    let l:ranges = call(a:RangeCreator, [a:startLnum, a:endLnum, l:expr])

    let [l:rangeNum, l:joinCnt] = ingo#join#Ranges(1, a:startLnum, a:endLnum, "\<C-v>\<C-j>", l:ranges)

    return s:SortRanges(a:bang, a:startLnum, a:endLnum, l:sortArgs, a:rangeName, l:rangeNum, l:joinCnt)
endfunction



function! s:ByHeader( startLnum, endLnum, expr )
    let l:headerLnums = []
    call cursor(a:startLnum, 1)
    while line('.') <= a:endLnum
	let l:lnum = search(a:expr, 'cW', a:endLnum)
	if l:lnum == 0
	    break
	endif

	call add(l:headerLnums, l:lnum)

	if l:lnum == a:endLnum
	    break
	else
	    call cursor(l:lnum + 1, 1)
	endif
    endwhile

    let l:ranges = []
    for l:i in range(len(l:headerLnums))
	call add(l:ranges, [l:headerLnums[l:i], get(l:headerLnums,l:i + 1, a:endLnum + 1) - 1])
    endfor
    return l:ranges
endfunction
function! AdvancedSorters#Ranges#ByHeader( bang, startLnum, endLnum, arguments )
    return s:JoinRanges(a:bang, a:startLnum, a:endLnum, a:arguments, function('s:ParseExpressionAndSortArguments'), 'headers', function('s:ByHeader'))
endfunction

function! s:ByMatch( startLnum, endLnum, expr )
    let l:ranges = []
    call cursor(a:startLnum, 1)
    while line('.') <= a:endLnum
	let l:startLnum = search(a:expr, 'cW', a:endLnum)
	if l:startLnum == 0
	    break
	endif
	let l:endLnum = search(a:expr, 'ceW', a:endLnum)
	if l:endLnum == 0
	    break
	endif

	call add(l:ranges, [l:startLnum, l:endLnum])

	if l:endLnum == a:endLnum
	    break
	else
	    call cursor(l:endLnum + 1, 1)
	endif
    endwhile
    return l:ranges
endfunction
function! AdvancedSorters#Ranges#ByMatch( bang, startLnum, endLnum, arguments )
    return s:JoinRanges(a:bang, a:startLnum, a:endLnum, a:arguments, function('s:ParseExpressionAndSortArguments'), 'matches', function('s:ByMatch'))
endfunction

function! s:ParseRangeAndSortArguments( arguments )
    " Since both the range and the sort arguments can contain a /{pattern}/,
    " parsing is difficult. It's easier when there's a sort flag or whitespace
    " in between, so look for such first.
    let l:parsedRange = ingo#cmdargs#range#Parse(a:arguments, {'isParseFirstRange': 1, 'commandExpr': s:GetSortArgumentsExpr(5, '\+', '$')})
    if empty(l:parsedRange)
	" Else, take the entire arguments as a range, with only optional sort
	" flags allowed (but no sort pattern). This means that here, there
	" *must* be a space or a sort flag between the /{pat1}/,/{pat2}/ range
	" and the /{pattern}/ sort argument.
	let l:parsedRange = ingo#cmdargs#range#Parse(a:arguments, {'isParseFirstRange': 1, 'commandExpr': '\s*\(' . s:sortFlagsExpr . '*\)$'})
    endif

    if empty(l:parsedRange)
	return ['', '']
    endif
    return l:parsedRange[3:4]
endfunction
function! s:ByRange( startLnum, endLnum, expr )
    if empty(a:expr) | return [] | endif

    " With ranges, there can be overlapping regions. To emulate a fold-like
    " behavior (where folds can be contained in others), go through the list of
    " unique line numbers and the list of lines where ranges end, and build the
    " [startLnum, endLnum] list out of that.
    let [l:recordedLines, l:startLines, l:endLines, l:didClobberSearchHistory] = ingo#range#lines#Get(a:startLnum, a:endLnum, a:expr)
    let l:linesInRange = sort(map(keys(l:recordedLines), 'str2nr(v:val)'), 'ingo#collections#numsort')
    call ingo#compat#uniq(l:endLines)
    let l:ranges = []
    while ! empty(l:endLines)
	let l:startLnum = remove(l:linesInRange, 0)
	let l:endLnum = remove(l:endLines, 0)
	if l:startLnum < l:endLnum
	    call add(l:ranges, [l:startLnum, l:endLnum])
	    call remove(l:linesInRange, 0, index(l:linesInRange, l:endLnum))
	endif
    endwhile

    return l:ranges
endfunction
function! AdvancedSorters#Ranges#ByRange( bang, startLnum, endLnum, arguments )
    return s:JoinRanges(a:bang, a:startLnum, a:endLnum, a:arguments, function('s:ParseRangeAndSortArguments'), 'ranges', function('s:ByRange'))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :