; 32-bit assembly language template

INCLUDE Irvine32.inc

.data

COUNT DWORD ?

Array2d		BYTE 100 DUP('-')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP(' ')
			BYTE 100 DUP('-')

ArraySize = 100
NumArrays = 28

.code

;This function draws the board to the screen
drawBoard proc
	;Save the registers
	push esi
	push ecx
	push eax

	mov esi,0						;Set the index to be zero
	mov ecx, NumArrays				;Loop through the first loop the # of outer arrays we have

	L1:
		push ecx					;Maintain the state of ecx while we go into the next loop
		mov ecx, ArraySize			;Loop through the size of the sub array
		mov al, '|'
		call WriteChar
		L2:
			mov al,Array2d+[esi]	;Mov value of Array2d into lower half of register eax
			call WriteChar			;Write the character to the screen
			inc esi					;This needs to only be incremented here because it's technically a linear array
		LOOP L2
		pop ecx						;Restore the state of ecx so we can continue looping through L1
		mov al, '|'
		call WriteChar
		call crlf					;Get a new line

	LOOP L1

	;Restore the registers
	pop eax
	pop ecx
	pop esi

	ret
drawBoard endp


main proc

	call drawBoard

	invoke ExitProcess,0
main endp
end main