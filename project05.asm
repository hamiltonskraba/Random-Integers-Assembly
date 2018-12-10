TITLE Random Integers    (proj05.asm)

INCLUDE Irvine32.inc

MIN = 10
MAX = 200
LO = 100
HI = 999

.data

header		BYTE		"Random Integers written by Hamilton Skrabanek", 0
instrucs1	BYTE		"This program generates a list of random numbers between 100 and 999.", 0
instrucs2	BYTE		"Please select how many integers you'd like to see, but keep it between 10 and 200.", 0
select		BYTE		"How many ints you want, Choppa? ", 0
oorErr		BYTE		"Oops! That's not between 10 and 200. Try again.", 0
unsorted	BYTE		"The unsorted list: ", 0
sorted		BYTE		"The sorted list: ", 0
median		BYTE		"The median of the list is ", 0
spacing		BYTE		"    ", 0
request		DWORD		?
array		DWORD		MAX		DUP(?)




.code
main PROC
	call	Randomize						;enable RandomRange

	call	introduction					;display intro

	push	OFFSET request
	call	getData							;validate selection

	push	OFFSET array
	push	request	
	call	fillArray						;generate random array

	push	OFFSET spacing
	push	OFFSET unsorted
	push	OFFSET array
	push	request
	call	displayList						;display unsorted list
	call	CrLf

	push	OFFSET array
	push	request
	call	sortList						;sort list

	mov		edx, OFFSET median				;display median title
	call	WriteString

	push	OFFSET array
	push	request
	call	calcMedian						;calculate and display median
	call	CrLf

	push	OFFSET sorted
	push	OFFSET array
	push	request
	call	displayList						;display sorted list



	exit	; exit to operating system
main ENDP

;-----------------------Begin Intro------------------------
;----------------------------------------------------------
;This procedure welcomes the user and displays instructions
;recieves: none
;returns: none
;preconditions: none
;registers changed: edx

introduction	PROC
;display program headline
	mov		edx, OFFSET header
	call	WriteString
	call	CrLf
	call	CrLf	

;display instructions
	mov		edx, OFFSET instrucs1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instrucs2
	call	WriteString
	call	CrLf
	call	CrLf
	ret
introduction	ENDP
;-----------------------End Intro--------------------------
;----------------------------------------------------------


;-----------------------Begin getData----------------------
;----------------------------------------------------------
;This procedure gets the number of ints to generate and 
;validates the entry as being within range

;recieves: request (reference)
;returns: request
;preconditions: request must be inclusive between 10 and 200
;registers changed: eax, edx

getData		PROC

	push	ebp
	mov		ebp, esp
validate:
	mov		edx, OFFSET select
	call	WriteString
	call	ReadInt
	call	CrLf

	mov		ebx, [ebp+8]					;move user input to request variable
	mov		[ebx], eax

	cmp		eax, MAX						;compare to the high limit
	jg		rangeErr
	cmp		eax, MIN						;compare to low limit
	jl		rangeErr
	jmp		valid

rangeErr:									;notify user and restart loop
	mov		edx, OFFSET oorErr
	call	WriteString
	call	CrLf
	call	CrLf
	jmp		validate

valid:										;input validated
	pop		ebp
	ret		
getData		ENDP
;-----------------------End getData------------------------
;----------------------------------------------------------



;--------------------Begin fillArray-----------------------
;----------------------------------------------------------
;This procedure generates a specified number of random
;integers and fills the array with them
;adapted from Irvine ArrayFill pg 297
;recieves: array (reference), request (value)
;returns: an array filled with random integers between 100 and 999
;preconditions: request must be between 10 and 200
;registers changed: none (saved and restored in call)

fillArray	PROC

	push	ebp
	mov		ebp, esp
	pushad
	mov		esi, [ebp+12]					;@array
	mov		ecx, [ebp+8]					;request into ecx for loop
more:
	mov		eax, HI							;hi val into eax
	sub		eax, LO							;subtract difference
	inc		eax
	call	RandomRange
	add		eax, LO							;add back low range
	mov		[esi], eax						;insert into array
	add		esi, 4							;next index
	loop	more
moreEnd:
	popad
	pop		ebp
	ret		8
fillArray	ENDP
;---------------------End fillArray------------------------
;----------------------------------------------------------



;--------------------Begin displayList---------------------
;----------------------------------------------------------
;This procedure displays the contents of an array, 10 numbers per line
;adapted from lecture 20
;recieves: array (ref), request (value), title (ref), spacing (ref)
;preconditions: request must be inclusive between 10 and 200
;registers changed: none

displayList		PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp+16]					;@unsorted title
	mov		esi, [ebp+12]					;@array
	mov		ecx, [ebp+8]					;request
	call	WriteString						;display title
	call	CrLf
	mov		edx, [ebp+20]					;move spacing to edx
	mov		ebx, 0							;use ebx as line count
more:
	mov		eax, [esi]
	call	WriteDec
	call	WriteString
	inc		ebx								;increment line count
	cmp		ebx, 10							;check if 10 lines have been written
	je		newLine
	add		esi, 4							;next element
	loop	more
	jmp		endMore
newLine:
	call	CrLf
	mov		ebx, 0							;reset line count
	cmp		ecx, 1							;check if last iteration
	je		endMore
	dec		ecx
	add		esi, 4
	jmp		more
endMore:
	call	CrLf
	pop		ebp
	ret		12		
displayList		ENDP
;---------------------End displayList----------------------
;----------------------------------------------------------


;--------------------Begin sortList------------------------
;----------------------------------------------------------
;This procedure sorts and array in descending order
;adapted from BubbleSort in Irvine pg 375
;recieves: array (ref), request (value)
;preconditions: none
;registers changed: none

sortList	PROC 
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+8]			;count
	dec		ecx
L1:
	push	ecx
	mov		esi, [ebp+12]			;@array
L2:
	mov		eax, [esi]				;get array value
	cmp		[esi+4], eax
	jl		L3
	xchg	eax, [esi+4]
	mov		[esi], eax
L3:
	add		esi, 4
	loop	L2

	pop		ecx
	loop	L1
L4:
	pop		ebp
	ret		8
sortList	ENDP
;----------------------End sortList------------------------
;----------------------------------------------------------


;------------------Begin calcMedian------------------------
;----------------------------------------------------------
;This procedure calculates and displays the median value of 
;a sorted array

;recieves: array (ref), request (value)
;preconditions: none
;registers changed: none

calcMedian	PROC
	push	ebp
	mov		ebp, esp
	xor		edx, edx				;clear remainder register
	mov		esi, [ebp+12]			;@array
	mov		eax, [ebp+8]			;count into eax
	mov		ebx, 2
	div		ebx						;check if even
	cmp		edx, 0
	jne		oddRem
	je		evenRem
oddRem:
	mov		ebx, 4					;move dword size to ebx
	mul		ebx						;multiply by eax to get element number
	add		esi, eax				;get array element[eax]
	mov		eax, [esi]
	call	WriteDec
	jmp		term
evenRem:
	mov		ebx, 4					;move dword size to ebx
	mul		ebx
	add		esi, eax				;get array element[eax]
	mov		ebx, [esi]
	mov		eax, [esi-4]			;get array element[eax - 1]
	add		eax, ebx				;add values
	mov		ebx, 2					
	div		ebx						;average
	call	WriteDec
term:
	call	CrLf
	pop		ebp
	ret		8
calcMedian	ENDP
;--------------------End calcMedian------------------------
;----------------------------------------------------------


END main
