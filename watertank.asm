.model tiny
.data
	porta equ 00h
	portb equ 02h
	portb equ 04h
	portcon equ 06h
	
	cnt0 equ 08h
	cnt1 equ 0Ah
	cnt2 equ 0Ch
	timecon equ 0Eh
	time equ 0h
	slot db ?
	
	intadd1 equ 10h
	intadd2 equ 12h
	
	
.code
;;initialise
	
	
	;;intialise interrupts
	call init_8259_icw 
	call init_8259_ocw
    call init_table
	
	
	
	mov al, 00110100b
	out timecon,al
	mov al, 01110100b
	out timecon,al
	mov al, 10010110b
	out timecon,al
	
	
	;;set cnt0 = 25000
	mov al,10100000b
	out cnt0,al
	mov al,10001100b
	out cnt0,al
	mov al,10101000b
	
	;;set cnt1 = 360000
	out cnt1,al
	mov al,01100001b
	out cnt1,al
	
	;;set cnt2 = 10
	mov al,10h
	out cnt2,al

	;;set ports as input/output
	mov al,10011001b
	out portcon,al
	

x1 : jmp x1
;;blocking function

	
isr0:
	mov al,time
	inc al
	cmp al,24
    jnz xx1
	mov al,0
	xx1:
	mov time,al

	.if al<=0 and al <= 5
	mov slot,0
	.elseif 06<=al and al <= 10
	mov slot,2
	.elseif 11<= al and al <= 16
	mov slot,1
	.elseif 17<= al and al <=19
	mov slot,2
	.else
	mov slot,1
	.endif
	
	mov cl,slot
	
	.if cl==0
	mov bl,00000000b
	out portb,bl
	.else if cl==1
	mov bl,00000001b
	out portb,bl
	.else
	mov bl,00000010b
	out portb,bl
	.endif
	
	in bl,porta
	and bl,00000001b
	cmp bl,1
	jnz xx2
	call motor1on
	jmp xx3
xx2:call valveouton
xx3:

iret
	
;; ir0 per hour

isr1:
	call valveoutoff
	call motor1on

iret
;;ir1 sookh gaya upar

isr2:
	call motor1off
iret
;;ir2 bhar gaya upar

isr3:
	call motor2on
iret 
;;ir3 sookh gaya neeche

isr4:
	call motor2off
iret
;;ir4 bhar gaya neeche


.exit



motor1on proc near 
	mov bl,00000001b
	out portcon,bl
	ret
motor1on endp
	
motor1off proc near 
	mov bl,00000000b
	out portcon,bl
	ret
motor1off endp

outvalveon proc near 
	mov bl,00000011b
	out portcon,bl
	ret
outvalveon endp

outvalveoff proc near
	mov bl,00000010b
	out portcon,bl
	ret
outvalveoff endp

motor2on proc near 
	mov bl,00000101b
	out portcon,bl
	ret
motor2on endp

motor2off proc near 
	mov bl,00000100b
	out portcon,bl
	ret
motor2off endp


;;initialise ocw
init_8259_icw proc near
 
	;icw1
	mov al,00010011b
	out intadd1,al
	 
	;icw2
	mov al,10000000b
	out intadd2,al
	 
	;icw4
	mov al,00000011b
	out indadd2,al
 
ret
init_8259_icw endp
 
;;intialise ocw
init_8259_ocw proc near 
	;ocw1
	mov al,11100000b
	out intadd2,al
ret
init_8259_ocw endp



;;generate vector table

init_table proc near
	mov ax, offset isr0
	mov 200h,ax
	mov ax, seg isr0
	mov 202h,ax
	 
	 
	mov ax, offset isr1
	mov 204h,ax
	mov ax, seg isr1
	mov 206h,ax
	 
	mov ax, offset isr2
	mov 208h,ax
	mov ax, seg isr2
	mov 20Ah,ax
	 
	mov ax, offset isr3
	mov 20Ch,ax
	mov ax, seg isr3
	mov 20Eh,ax
	 
	mov ax, offset isr4
	mov 210h,ax
	mov ax, seg isr4
	mov 212h,ax
ret
init_table endp

end
  