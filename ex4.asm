; Asaf Ben Or 209381599
.model small
.stack 100h
.data
place dw 2000
counter3 dw 0
lastkey db 158
msg db 'score: $'
scores dw 0

.code

 ;in all the code the place of the symbol 'X' is in cx 

    mov ax, @data
    mov ds, ax 

    ;this function get the scores and print it by a decimal number 
    printscores proc uses ax bx dx cx 
	mov dx, ' '
    mov bx, place
	mov es:[bx], dx ;clear the o 
	mov bx, cx
	mov es:[bx], dx ;clear the x 
	mov ax, scores
	sub ax, 1h ;because when we called the random in the first time it started to be counted 
	mov bh, 10
	div bh ;divide by 10 make ah to be the unit didits and ah to be the tens digit 
	add al, 30h ;make it an ascii number
	add ah, 30h ;make it an ascii number 
	mov ch, ah 
	
	;print the massge and the score 
	mov dx, offset msg
		mov ah, 9h
		int 21h
		
		mov dl, al
		mov ah, 02h
		int 21h
		
		mov dl, ch
		mov ah, 02h
		int 21h
		
		;move down 1 line
		mov dh, 1 
		mov dl, 0
		mov bh, 0
		mov ah, 2
		int 10h
		
	ret
	printscores endp
	
    ;this function prints O on the middle of the screen, X in a randomized pleace and make all the sreen to be black 
	CLNscr proc uses bx 
		mov bx, 4000
		loop_cln:
			mov cx , ' '
			mov es:[bx], cx 	;print black space
			sub bx, 2
			cmp bx, -2
			jnz loop_cln
		call random		;print X in a random place		
		mov dl, 'O'	
		mov dh, 4 ;red color 
		mov bx, 2000
		mov es:[bx], dx ;print O red in middle 
		ret
	CLNscr endp
	
	
	
	
	;this function gets the place of O and prit it their
	printplace proc uses bx dx
		mov bx, place
		mov dl, 'O'	
		mov dh, 4
		mov es:[bx], dx ;print O red in new place 
		
		ret
		
	printplace endp	
	
	
	;we can get to this function only from the inturpt of the ckock 1ch and it checks and get what is the last key that was prassed and go in his direction
	pressclock proc uses ax bx dx 
	
		cmp lastkey, 158 ; A was prassed 
		jz pressA1
		
		cmp lastkey, 160 ;D was prassed 
		jz pressD1

		cmp lastkey, 145 ;W was prasssed 
		jz pressW1
		
		cmp lastkey, 159 ;S was prassed 
		jz pressS1
		
		jmp done1 ;any other key was prassed 
		
		pressA1:
	    mov ax, place
		mov dh, 160
	    div dh
		cmp ah, 0
		jz done1 ;if its on the beganing of the line 
		mov bx, place	;clr screen
		mov dx, ' '
		mov es:[bx], dx 
		
		sub place, 2 ;take it left 
		
		call printplace
		cmp cx, place 
        jne done1
        call random ;if o got x 
		jmp done1
		
		pressD1:
	    mov ax, place
		mov dh, 160
		div dh
		cmp ah, 158
		jz done1 ;if its on the end of the line 
		mov bx, place	;clr screen
		mov dx, ' '
		mov es:[bx], dx
		
		add place, 2 ;take it right 
		call printplace
		cmp cx, place 
        jnz done1
        call random ;if o got x 
		jmp done1
		
		pressW1:
		cmp place, 159
		jbe done1 ;if its in the upper line 
		
		mov bx, place	;clr screen
		mov dx, ' '
		mov es:[bx], dx
		
		sub place, 160
		call printplace
		cmp cx, place 
        jne done1 ;if o got x 
        call random
		
		jmp done1
		
		pressS1:
		cmp place, 3840
		jae done1 ;if its in the last line 
		
		mov bx, place	;clr screen
		mov dx, ' '
		mov es:[bx], dx
		
		add place, 160
		call printplace
		cmp cx, place 
        jne done1 ;if o got x 
        call random
		
		jmp done1
		
		done1:
		ret
	pressclock endp 
	
	
	
	
	
	;this function is exactly same as the pressclock one but here in the and of every check it jumps back to the beganing and looping untill the pressung of an other key 
	press proc uses ax bx dx 
		MOV AX, 0
		pollKey:
			in al, 64h	;did you press
			test al,1
			jz pollKey
		
		in al, 60h	;yes, i pressed
		
		cmp al, 144
		jz pressQ
		
		cmp al, 158
		jz pressA
		
		cmp al, 160
		jz pressD

		cmp al, 145
		jz pressW
		
		cmp al, 159
		jz pressS
		
		jmp pollkey 


	pressQ:
		jmp endfunc
	
	pressA:
	    mov lastkey, al 
	    mov ax, place
		mov dh, 160
	    div dh
		cmp ah, 0
		jz pollkey
		mov bx, place	;clr screen
		mov dx, ' '
		mov es:[bx], dx
		
		sub place, 2
		
		call printplace
		cmp cx, place 
        jne pollKey
        call random
		jmp pollKey

		
	pressD:
	    mov lastkey, al
	    mov ax, place
		mov dh, 160
		div dh
		cmp ah, 158
		jz pollkey
		mov bx, place	;clr screen
		mov dx, ' '
		mov es:[bx], dx
		
		add place, 2
		call printplace
		cmp cx, place 
        jnz pollKey
        call random
		
		jmp pollKey

		
		
	pressW:
	    mov lastkey, al
		cmp place, 159
		jbe pollkey
		
		mov bx, place	;clr screen
		mov dx, ' '
		mov es:[bx], dx 
		
		sub place, 160
		call printplace
		cmp cx, place 
        jne pollkey
        call random
		
		jmp pollKey
	
	
	pressS:
	    mov lastkey, al
		cmp place, 3840
		jae pollkey
		
		mov bx, place	;clr screen
		mov dx, ' '
		mov es:[bx], dx
		
		add place, 160
		call printplace
		cmp cx, place 
        jne pollKey
        call random
		
		jmp pollKey
		
		
		
	endfunc:
		ret 
    press endp


    ;this randomize find a new place for x if x got ny the o, it gets the place of o 
    random proc uses ax di dx bx
	add scores, 1h ;because if we jumped to this function it means tge the o got the x and wo got a score 
		
		startrandfunc:
		mov al, 02h
		out 70h, al
		in al, 71h ;minutes
		mov cl, al
		mov al,00h
		out 70h, al
		in al, 71h ;seconds
		mov ch, al
		
		;check if the place of x is in even place and in the place 
	
	    mov ax, cx 
		mov di, 1999
		div di ;now in Dx is gonna be the mudolo 1999 of AX 
		shl dx, 1 ; double it in 2 because the screen is between 0 to 3998 
		mov cx, dx ;make cx back to be the place of x 
		
	    ;check if the new place of x doesnt equal to the prevent one 
		cmp cx, place
		jnz endrandfunc 
	    jmp startrandfunc ;start again if its equal 

		endrandfunc:
		mov bx, cx
		mov ax, 0B800h
		mov es, ax  
		mov dl, 'X'
	    mov dh, 04h ;red clor 
		mov es:[bx], dx ;print the res X in its new place 
        ret
    random endp 
	
	;this function makes the new interaptor for 1ch the clock to move the 0 in every 3 times, it gets the counter 3 which count the tree times 
	isrnew proc far
    add counter3, 1h
	cmp counter3, 3h ;check if we passrd 3 ticks of the clock 
	jnz done 
	mov counter3, 0h
	call pressclock 
	done:
	int 83h ;call to the old interput that we put as 83h 
	iret
	isrnew endp 
	
start:	

    mov ax, @data
    mov ds, ax

    mov ax, 0h
    mov es, ax
    ;first we put the new interput on the 1ch clock int and the old one in 81h and actually change their places in the IVT 
	cli
    mov ax, es:[1ch*4]
	mov es:[83h*4], ax
	mov ax, es:[1ch*4+2]
	mov es:[83h*4+2],ax
	mov ax, offset isrnew 
	mov es:[1ch*4], ax
	mov ax, cs
	mov es:[1ch*4+2], ax
	sti 
	
	
	;masking keyboard
	cli
	in al, 21h
	or al, 02h
	out 21h, al
	sti ;unmasking 
	
	xor ax, ax
	xor bx, bx
	xor cx, cx
	
	mov ax, 0b800h
	mov es, ax 
	
	call CLNscr	
	
	call press
	
	call printscores ;print the scores in the end 

	;undu masking keyboard
	cli
	mov al,0
	out 21h,al
	sti
	
	mov ax, 0
	mov es, ax
	
	;here we are making the IVT as it was originally
	cli 
	mov ax,es:[83h*4]
	mov es:[1Ch*4],ax
	mov ax,es:[83h*4+2]
	mov es:[1Ch*4+2],ax
	sti
	
	
   mov ax, 4c00h
   int 21h
 
 end START