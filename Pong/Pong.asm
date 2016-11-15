; 32-bit assembly language template

INCLUDE Irvine32.inc

.data

IQueue BYTE 1000 DUP(0)				;An array of 1000 characters initialized to 0
IQCount DWORD 0						;The number of elements stored in the array
IQStart DWORD 0						;The starting index of the queue
IQEnd DWORD 0						;The ending index of the queue

ArraySize = 100
NumArrays = 28

.code

;We should eventually make this into a queue listener
InstructionListener proc
	push ecx
	mov ecx, 500000000

	L1:
		;Do listening stuff here
	Loop L1

	pop ecx
	ret
InstructionListener ENDP

ClearScreen proc
	;tell the console to clear the screen before printing
	pushad

	mov ecx, NumArrays + 10

	L1:
		call crlf
	Loop L1

	popad
	ret
ClearScreen ENDP

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
DrawBoard proc

	;Save the registers
	pushad
	
	mov dl, 0						;initial x value is 0
	mov dh, 0						;initial y value is 0
	call gotoxy						;set the cursor position to the xy position
	
	;First loop is rows
	;Second loop is columns
	mov ecx, NumArrays + 1
	
	L1:
		push ecx
		mov ecx, ArraySize + 1
		L2:
			
			.IF (dl == 0) || (dl == ArraySize)
				mov al, "|"
				call WriteChar
			.ELSEIF (dh == 0) || (dh == NumArrays)
				mov al, "-"
				call WriteChar
			.ENDIF
			
			inc dl
			call gotoxy
			
		Loop L2
		
		mov dl, 0
		inc dh
		call gotoxy
		
		pop ecx
	Loop L1

	;Restore the registers
	popad

	ret
drawBoard endp


main proc

	;mov ecx, 100000000
	;L1:
		call DrawBoard
		;call InstructionListener
		;call ClearScreen
	;Loop L1

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