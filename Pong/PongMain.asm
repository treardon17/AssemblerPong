; TITLE Pong game in assembler

INCLUDE Irvine32.inc

_kbhit PROTO C
getch PROTO C

.data

;INSTRUCTION QUEUE VARIABLES
IQ STRUCT
Countq DWORD 0						;The number of elements stored in the array
Startq DWORD 0						;The starting index of the queue
Endq DWORD 0						;The ending index of the queue
Dataq BYTE 1000 DUP(0)				;An array of 1000 characters initialized to 0
IQ ENDS
Queue IQ <>

;BOARD STATE VARIABLES
XCoords = 100						;the width of the board
YCoords = 25						;the height of the board
PaddleLength = 5					;the length of the paddle

;Board Borders
TopBorder = 1
BottomBorder = YCoords - 1
LeftBorder = 1
RightBorder = XCoords - 1

;Paddle borders
LPBorder = LeftBorder + 2
RPBorder = RightBorder - 2

;Paddles
Paddle STRUCT
XCoord BYTE 0
YCoord BYTE 0
Paddle ENDS

RPaddle Paddle <XCoords - 1, 1>
LPaddle Paddle <1, 1>

;SCORES OF PLAYERS
P1Score BYTE 0
P2Score BYTE 0

Ball STRUCT
XCoord BYTE XCoords/2				;set the xcoord to the middle of the board
YCoord BYTE YCoords/2				;set the ycoord to the middle of the board
BChar BYTE 233						;The copyright symbol
Run BYTE 1
Rise BYTE 1
Ball ENDS
TheBall Ball <>

.code

;Adds an item to the back of the queue
IQPushBack proc, instruction:BYTE

	xor eax, eax					;zero out the eax register
	mov esi,  Queue.Endq			;tell esi where the end of the array is
	mov al, instruction				;tell al what the instruction is
	mov Queue.Dataq[esi], al		;move the instruction to the last place in the array
	add Queue.Countq, 1				;increment the number of items we have stored in the array
	add Queue.Endq, 1
	
	.IF Queue.Endq > 1000			;if the end of the array is greater than the max size of the array
		mov Queue.Endq, 0			;set the end of the array to be the first item in the array
	.ENDIF

	ret
IQPushBack ENDP

;Takes the first item from the queue
IQPopFront proc
	xor eax, eax					;zero out the eax register
	.IF Queue.Countq > 0			;if there is an item in the array
		mov esi, Queue.Startq		;tell esi where the start of the queue is 
		mov al, Queue.Dataq[esi]	;get the first item in the queue
		mov Queue.Dataq[esi], 0		;zero out the first item in the queue
		inc esi						;increment esi to see if it's larger than the max size
		.IF esi > 1000				;if it's greater than the max size
			mov Queue.Startq, 0		;move the Startq to zero
		.ELSE
			mov Queue.Startq, esi	;otherwise increment the Startq of the array
		.ENDIF
		dec Queue.Countq			;decrease the count of the array
	.ENDIF

	;If the queue is empty, move the Startq of the queue to the first spot in the array
	.IF (Queue.Countq == 0)
		mov Queue.Startq, 0
		mov Queue.Endq, 0
	.ENDIF
	
	ret
IQPopFront ENDP

;This will clear the left paddle
ClearLP proc
	pushad						;save the registers
	xor eax, eax				

	mov ecx, PaddleLength + 1	;tell ecx how long the paddle is
	xor edx, edx				
	mov dl, 1					;x coordinate is 1
	mov dh, LPaddle.YCoord		;y coordinate is what was stored in LPCoordTop

	RemovePaddleLoop:
		call gotoxy				;go to the xy position
		mov al, " "				;put a space there
		call WriteChar			
		inc dh					;increment the y position
	Loop RemovePaddleLoop
	popad
	ret
ClearLP endp

;draws the left paddle to the screen
DrawLP proc
	pushad

	xor eax, eax
	mov al, LPaddle.YCoord					;tell al where left paddle starts
	add al, PaddleLength					;tell al where left paddle ends (for edge detection)

	.IF (eax >= BottomBorder)				;if the position exceeds the bounds of the board
		mov al, YCoords						;move to the last valid position on the edge (bottom)
		sub al, PaddleLength
		mov LPaddle.YCoord, BottomBorder
	.ELSEIF (LPaddle.YCoord <= TopBorder)
		mov LPaddle.YCoord, TopBorder		;otherwise move to the other last valid position on the edge (top)
	.ENDIF

	;draw the paddle to the console (see above comments for what the heck is going on)
	xor edx, edx
	mov dl, 1
	mov dh, LPaddle.YCoord
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

;See ClearLP for comments
ClearRP proc
	pushad
	xor eax, eax

	mov ecx, PaddleLength + 1
	xor edx, edx
	mov dl, RPaddle.XCoord
	mov dh, RPaddle.YCoord
	RemovePaddleLoop:
		call gotoxy
		mov al, " "
		call WriteChar
		inc dh
	Loop RemovePaddleLoop
	popad
	ret
ClearRP endp

;See Draw LP for comments
DrawRP proc
	pushad

	xor eax, eax
	mov al, RPaddle.YCoord
	add al, PaddleLength

	.IF (eax >= BottomBorder)
		mov al, BottomBorder
		sub al, PaddleLength
		mov RPaddle.YCoord, al
	.ELSEIF (RPaddle.YCoord <= 1)
		mov RPaddle.YCoord, 1
	.ENDIF

	xor edx, edx
	mov dl, XCoords - 1
	mov dh, RPaddle.YCoord
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

;Draws the paddles to the screen
DrawPaddles proc
	call DrawLP
	call DrawRP
	ret
DrawPaddles endp

BallMath proc
	;PADDLE COLLISION LOGIC---------------------------------------
	;LEFT--------------
	;If the ball is in front of the left paddle
	mov al, LPBorder
	.IF (TheBall.XCoord == al)
		xor al, al
		mov al, LPaddle.YCoord
		add al, PaddleLength
		sub al, TheBall.YCoord
		;If the ball is in the range of the paddle
		.IF (al >= 0) && (al <= PaddleLength)
			mov TheBall.Run, 1
		.ENDIF
	.ENDIF
	;RIGHT--------------
	mov al, RPBorder
	.IF (TheBall.XCoord == al)
		xor al, al
		mov al, RPaddle.YCoord
		add al, PaddleLength
		sub al, TheBall.YCoord
		;If the ball is in the range of the paddle
		.IF (al >= 0) && (al <= PaddleLength)
			mov TheBall.Run, -1
		.ENDIF
	.ENDIF
	;TOP--------------
	mov al, TopBorder
	.IF (TheBall.YCoord == al)
		mov TheBall.Rise, 1
	.ENDIF
	;BOTTOM--------------
	mov al, BottomBorder
	.IF (TheBall.YCoord == al)
		mov TheBall.Rise, -1
	.ENDIF
	;END PADDLE COLLISION LOGIC---------------------------------------
	
	mov al, TheBall.YCoord
	add al, TheBall.Rise
	mov TheBall.YCoord, al
	
	mov al, TheBall.XCoord
	add al, TheBall.Run
	mov TheBall.XCoord, al
	
	ret
BallMath endp

;Draws the ball to the screen (including logic)
DrawBall proc
	pushad
	xor edx, edx
	
	;Erase the ball
	mov dl, TheBall.XCoord
	mov dh, TheBall.YCoord
	call gotoxy
	mov al, " "
	call WriteChar
	
	call BallMath
	
	;SCORING FUNCTION
	.IF (TheBall.XCoord == LeftBorder)
		inc P2Score
	.ELSEIF (TheBall.XCoord == RightBorder)
		inc P1Score
	.ENDIF
	
	mov dl, TheBall.XCoord
	mov dh, TheBall.YCoord
	call gotoxy
	mov al, TheBall.BChar
	call WriteChar
	call SetCursorToRead
	popad
	ret
DrawBall endp

;This function draws the board to the screen
DrawBoard proc
	;Save the registers
	pushad
	mov dl, 0											;initial x value is 0
	mov dh, 0											;initial y value is 0
	call gotoxy											;set the cursor position to the xy position
	
	;First loop is rows
	;Second loop is columns
	mov ecx, YCoords + 1
	
	L1:
		push ecx
		mov ecx, XCoords + 1
		L2:
			.IF (dl == 0) || (dl == XCoords)			;Draws a | on the sides of the screen
				mov al, "|"
				call WriteChar
			.ELSEIF (dh == 0) || (dh == YCoords)		;Draws a - on the top and bottom
				mov al, "-"
				call WriteChar
			.ELSE										;Draws a space everywhere else
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

;Sets the cursor to be below the board to make inputting stuff look better
SetCursorToRead proc
	pushad
	mov dl, 0
	mov dh, YCoords
	add dh, 2
	call gotoxy
	popad
	ret
SetCursorToRead endp

PaddleLogic proc
	pushad
	xor ecx, ecx

	;If there are instructions in the queue, then clear out all of the instructions
	.IF (Queue.Countq > 0)
		mov ecx, Queue.Countq
		L1:
			call IQPopFront
			.IF (eax == 49)
				call ClearLP
				inc LPaddle.YCoord
				call DrawLP
			.ELSEIF (eax == 50)
				call ClearLP
				dec LPaddle.YCoord
				call DrawLP
			.ELSEIF (eax == 57)
				call ClearRP
				inc RPaddle.YCoord
				call DrawRP
			.ELSEIF (eax == 48)
				call ClearRP
				dec RPaddle.YCoord
				call DrawRP
			.ENDIF
		Loop L1
	.ENDIF
	
	popad
	ret
PaddleLogic endp

PongMain proc C
	xor eax, eax
	call DrawBoard
	call DrawPaddles
	call DrawBall
	
	L1:
		call DrawBall
		call PaddleLogic
		xor eax, eax
		mov ecx, 10000
		L2:
			push ecx
			call _kbhit
			.IF (eax != 0)
				call getch
				push eax
				call IQPushBack
			.ENDIF
			pop ecx
		Loop l2
	Loop L1

	ret
PongMain endp
end