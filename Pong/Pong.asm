; 32-bit assembly language template

INCLUDE Irvine32.inc

.data

IQueue BYTE 1000 DUP(0)				;An array of 1000 characters initialized to 0
IQCount DWORD 0						;The number of elements stored in the array
IQStart DWORD 0						;The starting index of the queue
IQEnd DWORD 0						;The ending index of the queue

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


;Adds an item to the back of the queue
IQPushBack proc, instruction:BYTE

	;If the queue is empty, move the start of the queue to the first spot in the array
	.IF IQCount == 0
		mov IQStart, 0
	.ENDIF

	xor eax, eax				;zero out the eax register
	mov esi, IQEnd				;tell esi where the end of the array is
	mov al, instruction			;tell al what the instruction is
	mov IQueue[esi], al			;move the instruction to the last place in the array
	inc IQCount					;increment the number of items we have stored in the array
	inc IQEnd

	
	.IF IQEnd > 1000			;if the end of the array is greater than the max size of the array
		mov IQEnd, 0			;set the end of the array to be the first item in the array
	.ENDIF

	ret
IQPushBack ENDP

;Takes the first item from the queue
IQPopFront proc
	xor eax, eax				;zero out the eax register
	.IF IQCount > 0				;if there is an item in the array
		mov esi, IQStart		;tell esi where the start of the queue is 
		mov al, IQueue[esi]		;get the first item in the queue
		mov IQueue[esi], 0		;zero out the first item in the queue
		inc esi					;increment esi to see if it's larger than the max size
		.IF esi > 1000			;if it's greater than the max size
			mov IQStart, 0		;move the start to zero
		.ELSE
			mov IQStart, esi	;otherwise increment the start of the array
		.ENDIF
		dec IQCount				;decrease the count of the array
	.ENDIF
	
	ret
IQPopFront ENDP

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
			mov al,Array2d[esi]	;Mov value of Array2d into lower half of register eax
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

	;call drawBoard


	push 'b'
	call IQPushBack

	push 'a'
	call IQPushBack

	push 'c'
	call IQPushBack

	call IQPopFront
	call IQPopFront
	call IQPopFront

	invoke ExitProcess,0
main endp
end main