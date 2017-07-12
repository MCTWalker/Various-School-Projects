;*******************************************************************************
;   CS 224 Lab 3 - blinky.asm: Software Toggle P1.0 (02/15/2017)
;
;        Author:  Maura Walker, Brigham Young University
;   Description:  Quickly blink LED1 (P1.0) every 10 seconds.
;                 Calculate MCLK, CPI, MIPS
;    Disclaimer:  This code is the work of Maura Walker.  I certify this to be my
;                 source code and not obtained from any student, past or current.
;
;             MSP430G5223
;             -----------
;            |       P1.0|-->LED1-RED LED
;            |       P1.3|<--S2
;            |       P1.6|-->LED2-GREEN LED
;
; Show all calculations:

;mainloop:   bis.b   #0x01,&P1OUT            ;    turn on P1.0 - 4 cycles
;            mov.w   #COUNT,r15              ;    use R15 as delay counter - 2 cycles
;            mov.w   #TENTHCOUNT, r14        ;    use R14 as tenth count delay counter - 2 cycles. total cycles for main loop = 4 + 2 + 2 = 8 cycles
;
;delayloop:  sub.w   #1,r15                  ;    1 cycle * 33000 = 33000 cycles
;            jne     delayloop               ;    2 cycles * 33000 = 66000 cycles
;            bic.b   #0x01,&P1OUT            ;    turn off P1.0 (makes it appear to blink) - 4 cycles
;            jmp     outerloop               ;    2 cycles. total cycles for delay loop = 33000 + 66000 + 4 + 2 = 99006 cycles
;
;outerloop:  sub.w   #1, r14                 ;    1 cycle * 100 = 100 cycles
;			mov.w   #COUNT,r15              ;    2 cycles * 100 = 200 cycles
;			jne     delayloop               ;    (2 cycles for jne + 99006 cycles for delay loop) * 100 = 9900800 cycles
;			jmp     mainloop                ;    2 cycles. total cycles for outerloop = 100 + 200 + 9900800 + 2 = 9901102 cycles
;Assuming MCLK starts from main loop
;# of cycles = mainloop cycles + delayloop cycles + outerloop cycles = 8 + 99006 + 9901102 = 10000116
;# of instructions = mainloop instructions + delayloop instructions + outerloop instructions = (1 + 1 + 1) + (33000 + 33000 + 1 + 1) + (100 + 100 + 100 * 66002 + 1) =
;
;   MCLK = __10000116_____ cycles / ___1____ interval = ___10000116____ Hz
;    CPI = __10000116_____ cycles/ ____6666406___ instructions = ___1.5001____ Cycles/Instruction
;   MIPS = MCLK / CPI / 1000000 = ____6.66630___ MIPS
;
;*******************************************************************************
           .cdecls  C,"msp430.h"            ; MSP430
           .def     RESET

COUNT      .equ     33000                     ; delay count
TENTHCOUNT .equ		100
;------------------------------------------------------------------------------
            .text                           ; beginning of executable code
;------------------------------------------------------------------------------
RESET:      mov.w   #0x0280,SP              ;    init stack pointer
            mov.w   #WDTPW|WDTHOLD,&WDTCTL  ;    stop WDT
            bis.b   #0x01,&P1DIR            ;    set P1.0 as output


mainloop:   bis.b   #0x01,&P1OUT            ;    turn on P1.0 - 4 cycles
            mov.w   #COUNT,r15              ;    use R15 as delay counter - 2 cycles
            mov.w   #TENTHCOUNT, r14        ;    use R14 as tenth count delay counter - 2 cycles. total for main loop = 4 + 2 + 2 = 8 cycles

delayloop:  sub.w   #1,r15                  ;    1 cycle * 33000 = 33000 cycles
            jne     delayloop               ;    2 cycles * 33000 = 66000 cycles
            bic.b   #0x01,&P1OUT            ;    turn off P1.0 (makes it appear to blink) - 4 cycles
            jmp     outerloop               ;    2 cycles. total for delay loop = 33000 + 66000 + 4 + 2 = 99006 cycles

outerloop:  sub.w   #1, r14                 ;    1 cycle * 100 = 100 cycles
			mov.w   #COUNT,r15              ;    2 cycles * 100 = 200 cycles
			jne     delayloop               ;    (2 cycles for jne + 99006 cycles for delay loop) * 100 = 9900800 cycles
			jmp     mainloop                ;    2 cycles + 8 cycles for main loop = 10 cycles



;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .word   RESET                   ; start address
            .end
