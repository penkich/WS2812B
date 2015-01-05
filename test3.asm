;
; Serial LED Tape (WS2818B) test program
; for AVR ATmega168,328
; clock 20MHz
; 2015-01-05 by penkich
;
.include "m168def.inc"
.org 0x00 jmp reset
reset:
    ldi r16,low(ramend)
    out spl,r16
    ldi r16,high(ramend)
    out sph,r16
    ldi r16,0b11111111
    out ddrb,r16
datain:
    ldi r20,0b11111110 ; low
    ldi r21,0b11111111 ; high
    ldi r22,0b00000111
    rcall led
    rcall led
    ldi r22,0b00000111
    rcall led
    ldi r22,0b00000111
    rcall led
    rcall led
    rcall led
    rcall led
    rcall led
    ldi r22,0b00000111
    rcall led
    ldi r22,0b00000111
    rcall led
    ldi r22,0b00000111
    rcall led
    rcall led
    rcall delay10us
    rjmp iloop  
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
 ldi r16,2          ;1
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
