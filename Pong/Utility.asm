; Listing generated by Microsoft (R) Optimizing Compiler Version 19.00.24213.1 

	TITLE	c:\users\rsexton17\desktop\utility\utility\utility.c
	.686P
	.XMM
	include listing.inc
	.model	flat

INCLUDELIB OLDNAMES

EXTRN	__imp__getch:PROC
EXTRN	__imp___kbhit:PROC
EXTRN	@__security_check_cookie@4:PROC
PUBLIC	_main
PUBLIC	_GetKeyboardChar
PUBLIC	_KeyboardResponse
; Function compile flags: /Ogtp
; File c:\users\rsexton17\desktop\utility\utility\utility.c
;	COMDAT _KeyboardResponse
_TEXT	SEGMENT
_KeyboardResponse PROC					; COMDAT

; 4    : 	return _kbhit();

	jmp	DWORD PTR __imp___kbhit
_KeyboardResponse ENDP
_TEXT	ENDS
; Function compile flags: /Ogtp
; File c:\users\rsexton17\desktop\utility\utility\utility.c
;	COMDAT _GetKeyboardChar
_TEXT	SEGMENT
_GetKeyboardChar PROC					; COMDAT

; 8    : 	return getch();

	jmp	DWORD PTR __imp__getch
_GetKeyboardChar ENDP
_TEXT	ENDS
; Function compile flags: /Ogtp
; File c:\users\rsexton17\desktop\utility\utility\utility.c
;	COMDAT _main
_TEXT	SEGMENT
_main	PROC						; COMDAT

; 4    : 	return _kbhit();

	call	DWORD PTR __imp___kbhit

; 8    : 	return getch();

	call	DWORD PTR __imp__getch

; 12   : 	KeyboardResponse();
; 13   : 	GetKeyboardChar();
; 14   : 	return 0;

	xor	eax, eax

; 15   : }

	ret	0
_main	ENDP
_TEXT	ENDS
END
