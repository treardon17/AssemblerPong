; 32-bit assembly language template

INCLUDE Irvine32.inc
;INCLUDE Utility.inc

.data

;INSTRUCTION QUEUE VARIABLES
IQueue BYTE 1000 DUP(0)				;An array of 1000 characters initialized to 0
IQCount DWORD 0						;The number of elements stored in the array
IQStart DWORD 0						;The starting index of the queue
IQEnd DWORD 0						;The ending index of the queue

;BOARD STATE VARIABLES
XCoords = 100						;the width of the board
YCoords = 25						;the height of the board
PaddleLength = 5					;the length of teh paddle
LPCoords BYTE 0						;coordinates for the left paddle
RPCoords BYTE 0						;coordinates for the right paddle

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

DrawLP proc
	pushad

	xor eax, eax
	mov al, LPCoords
	add al, PaddleLength

	.IF (eax >= YCoords)
		mov al, YCoords
		sub al, PaddleLength
		sub al, 1
		mov LPCoords, al
	.ELSEIF (LPCoords <= 1)
		mov LPCoords, 1
	.ENDIF

	xor edx, edx
	mov dl, 1
	mov dh, LPCoords
	mov ecx, PaddleLength + 1
	L1:
		call gotoxy
		mov al, "]"
		call WriteChar
		inc dh
	Loop L1

	call SetCursorToRead

	popad
	ret
DrawLP endp

DrawRP proc
	pushad

	xor eax, eax
	mov al, RPCoords
	add al, PaddleLength

	.IF (eax >= YCoords)
		mov al, YCoords
		sub al, PaddleLength
		sub al, 1
		mov RPCoords, al
	.ELSEIF (RPCoords <= 1)
		mov RPCoords, 1
	.ENDIF

	xor edx, edx
	mov dl, XCoords - 1
	mov dh, RPCoords
	mov ecx, PaddleLength + 1
	L1:
		call gotoxy
		mov al, "["
		call WriteChar
		inc dh
	Loop L1

	call SetCursorToRead

	popad
	ret
DrawRP endp

;This function draws the board to the screen
DrawBoard proc
	;Save the registers
	pushad
	mov dl, 0						;initial x value is 0
	mov dh, 0						;initial y value is 0
	call gotoxy						;set the cursor position to the xy position
	
	;First loop is rows
	;Second loop is columns
	mov ecx, YCoords + 1
	
	L1:
		push ecx
		mov ecx, XCoords + 1
		L2:
			.IF (dl == 0) || (dl == XCoords)
				mov al, "|"
				call WriteChar
			.ELSEIF (dh == 0) || (dh == YCoords)
				mov al, "-"
				call WriteChar
			.ELSE
				mov al, " "
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
	
	call SetCursorToRead

	;Restore the registers
	popad
	ret
DrawBoard endp

DrawFullBoard proc
	call DrawBoard
	call DrawLP
	call DrawRP
	ret
DrawFullBoard endp

SetCursorToRead proc
	pushad
	mov dl, 0
	mov dh, YCoords
	add dh, 2
	call gotoxy
	popad
	ret
SetCursorToRead endp

main proc

	L1:
		call DrawFullBoard
		call ReadInt
		.IF (eax == 1)
			inc RPCoords
		.ELSEIF (eax == 2)
			dec RPCoords
		.ENDIF
		;call InstructionListener
	Loop L1

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