.include "m168def.inc"

.org 0x00	jmp reset

reset:
	ldi r16,low(ramend)
	out spl,r16
	ldi r16,high(ramend)
	out sph,r16
	ldi r16,0b11111111
	out ddrb,r16

	ldi r20,0b11111110	; low
	ldi r21,0b11111111	; high

	jmp main
datain:

	ldi r22,0b00000111
	rcall led
	rcall led
	ldi r22,0b00000111
	rcall led
	rcall delay10us

	rjmp iloop	 

led:
	push r16
	in r16,sreg
	push r16
	ldi r18,9		; loop counter
loop:
	out portb,r20	;1
	dec r18			;1
	cpi r18,0		;1
	breq return		;1/2
	lsl r22			;1
	brcs j1			;1/2
j0:
	out portb,r21	;1
	nop				;1
	nop				;1
	nop				;1
	nop				;1
	nop				;1
	nop				;1
	nop				;1
	nop				;8
	out portb,r20	;1
j0_1:
	nop		;1
	nop		;1
	nop		;1
	nop		;1
	nop		;1
	nop		;1
	nop		;1
	nop		;1
	nop		;1
	rjmp loop	;2
j1:
	out portb,r21
	push r16	;2
	ldi r16,2	;1
j1_1:
	dec r16		;1
	cpi r16,0	;1
	brne j1_1	;1/2
	pop r16		;2
	nop
	nop
	nop
	out portb,r20
	nop
	rjmp loop

return:
	out portb,r20	;1
	pop r16			;2
	out sreg,r16	;1
	pop r16			;2
	ret				;4

iloop:
	rjmp iloop
	

	;rcall		;3
delay10us:
	push r16	;2
	in r16,sreg	;1
	push r16	;2
	ldi r16,26	;1
loop_10us:
	nop			;1
	nop			;1
	nop			;1
	dec r16		;1
	cpi r16,0	;1
	brne loop_10us	;1/2
	pop r16		;2
	out sreg,r16;1
	pop r16		;2
	nop			;1
	ret			;4

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

main01:
	lds r16, ucsr0a
	sbrs r16, rxc0
	rjmp main01
	lds r22, udr0
	cpi r22, 'a'
	breq main02
	rcall uarts
	rjmp main01
main02:
	ldi r22, 0b00001111
	rcall led
	rcall delay10us
	rcall uarts
	rjmp main01
