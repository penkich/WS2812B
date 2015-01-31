;
; Serial LED Tape (WS2818B) test program
; for AVR ATmega168,328
; clock 20MHz
; 2015-01-11 UART test by penkich
;
.include "m168def.inc"
.equ n1 = 8  ;
.equ n2 = 128 ;n1 * n2 = 1k byte
.org 0x00 jmp reset
reset:
    ldi r16,low(ramend)
    out spl,r16
    ldi r16,high(ramend)
    out sph,r16
    ldi r16,0b11111111
    out ddrb,r16
    ldi r20,0b11111110 ; low
    ldi r21,0b11111111 ; high
    ldi xh,0x01 ;x <- 0x0100
    ldi xl,0x00
    ldi r17, n1
    ldi r19, n2
datain:
    jmp main
led:
    push r16
    in r16,sreg
    push r16
    ldi r18,9       ;loop counter
loop:
    out portb,r20   ;1
    dec r18         ;1
    cpi r18,0       ;1
    breq return     ;1/2
    lsl r22         ;1
    brcs j1         ;1/2
j0:
    out portb,r21   ;1
    nop             ;1
    nop             ;1
    nop             ;1
    nop             ;1
    nop             ;1
    nop             ;1
    nop             ;1
    nop             ;8 nop total
    out portb,r20   ;1
j0_1:
    nop             ;1
    nop             ;1
    nop             ;1
    nop             ;1
    nop             ;1
    nop             ;1
    nop             ;1
    nop             ;1
    nop             ;1
    rjmp loop       ;2
j1:
    out portb,r21
    push r16        ;2
    ldi r16,2       ;1
j1_1:
    dec r16         ;1
    cpi r16,0       ;1
    brne j1_1       ;1/2
    pop r16         ;2
    nop
    nop
    nop
    out portb,r20
    nop
    rjmp loop
return:
    out portb,r20   ;1
    pop r16         ;2
    out sreg,r16    ;1
    pop r16         ;2
    ret             ;4
iloop:
    rjmp reset
                    ;rcall  ;3
delay10us:
    push r16        ;2
    in r16,sreg     ;1
    push r16        ;2
    ldi r16,26      ;1
loop_10us:
    nop             ;1
    nop             ;1
    nop             ;1
    dec r16         ;1
    cpi r16,0       ;1
    brne loop_10us  ;1/2
    pop r16         ;2
    out sreg,r16    ;1
    pop r16         ;2
    nop             ;1
    ret             ;4
uarts:
    lds r16, ucsr0a
    sbrs r16, udre0
    rjmp uarts
    sts udr0, r22
    ret
main:
    cli
    ldi r16, 10
    sts ubrr0l, r16
    ldi r16, 0
    sts ubrr0h, r16
    lds r16, ucsr0c
    sbr r16, ((1<<ucsz01)+(1<<ucsz00))
    sts ucsr0c, r16
    lds r16, ucsr0b
    sbr r16, ((1<<rxen0)+(1<<txen0))
    sts ucsr0b, r16
    sei
    ldi r17, n1
loop3:
    ldi r19, n2
main01:
loop4:
    lds r16, ucsr0a
    sbrs r16, rxc0
    rjmp main01
    lds r22, udr0

    mov r16, r22
	push r17
	rcall chaconv
    pop r17

    st x+, r16
    cpi r16, 0x0d
    breq loop_out 
    rcall uarts
    dec r19
    cpi r19,0
    brne loop4
    dec r17
    brne loop3
    ldi xh,0x01 ;x <- 0x0100
    ldi xl,0x00
loop_out:
	ldi r23, 0; flag
    ldi r17, n1
loop1:
    ldi r19, n2
loop2:
    ld r22,x+
    cpi r22, 0x0d
    breq out_led
;   ldi r16,0b00001111
;   and r22,r16
	cpi r23,1
	brne f0
	lsl r24
	lsl r24
	lsl r24
	lsl r24
	add r23,r24	
    rcall led
	ldi r23,0
	rjmp f1
f0:
	ldi r23,1
	mov r24,r22
f1:
    cpi r19,0
    brne loop2
    dec r17
    brne loop1
out_led:
    rcall delay10us
	rcall delay10us
	rcall delay10us
    jmp reset

;   r16('0','1',...'A','B',...'F')
;   -> r16(0,1,,,,10,11,...15)
chaconv:
    push r16
    andi r16, 0b00001111
	mov r17, r16
	pop r16
	andi r16, 0b01000000
	cpi r16,0
	brne ch1
	mov r16, r17
	ret
ch1:
    ldi r16, 0x9
    add r16, r17
	ret