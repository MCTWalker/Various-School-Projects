;    threadsISR.asm    08/07/2015
;*******************************************************************************
;  STATE        Task Control Block        Stacks (malloc'd)
;                          ______                                       T0 Stack
;  Running tcbs[0].thread | xxxx-+------------------------------------->|      |
;                 .stack  | xxxx-+-------------------------------       |      |
;                 .block  | 0000 |                               \      |      |
;                 .retval |_0000_|                       T1 Stack \     |      |
;  Ready   tcbs[1].thread | xxxx-+---------------------->|      |  \    |      |
;                 .stack  | xxxx-+------------------     |      |   \   |      |
;                 .block  | 0000 |                  \    |      |    -->|(exit)|
;                 .retval |_0000_|        T2 Stack   --->|r4-r15|       |------|
;  Blocked tcbs[2].thread | xxxx-+------->|      |       |  SR  |
;                 .stack  | xxxx-+---     |      |       |  PC  |
;                 .block  |(sem) |   \    |      |       |(exit)|
;                 .retval |_0000_|    --->|r4-r15|       |------|
;  Free    tcbs[3].thread | 0000 |        |  SR  |
;                 .stack  | ---- |        |  PC  |
;                 .block  | ---- |        |(exit)|
;                 .retval |_----_|        |------|
;
;*******************************************************************************

            .cdecls C,"msp430.h"            ; MSP430
            .cdecls C,"pthreads.h"          ; threads header

            .def    TA_isr
            .ref    ctid
            .ref    tcbs

tcb_thread  .equ    (tcbs + 0)
tcb_stack   .equ    (tcbs + 2)
tcb_block   .equ    (tcbs + 4)

; Code Section ------------------------------------------------------------

			.bss     counter, 2
            .text                           ; beginning of executable code

; Timer A ISR -------------------------------------------------------------
TA_isr:     bic.w   #TAIFG|TAIE,&TACTL      ; acknowledge & disable TA interrupt
;
; >>>>>> 1. Save current context on stack
; >>>>>> 2. Save SP in task control block
; >>>>>> 3. Find next non-blocked thread tcb
; >>>>>> 4. If all threads blocked, enable interrupts in LPM0
; >>>>>> 5. Set new SP
; >>>>>> 6. Load context from stack
;
            bis.w    #TAIE,&TACTL           ; enable TA interrupts
            push.w   r15
            push.w   r14
            push.w   r13
            push.w   r12
            push.w   r11
            push.w   r10
            push.w   r9
            push.w   r8
            push.w   r7
            push.w   r6
            push.w   r5
            push.w   r4

saveSP:     mov.w    ctid, r4
            add.w    r4, r4
            add.w    r4, r4
            add.w    r4, r4

			mov.w    SP, tcb_stack(r4)
			clr.w    &counter

findOnBlock:cmp.w    #MAX_THREADS, &counter
				jeq  enableInterrupts
			inc.w    ctid
			mov.w    ctid, r15
			add.w	 r15, r15
			add.w	 r15, r15
			add.w	 r15, r15
			cmp.w    #0, tcb_thread(r15)
				jne	 findOnBlock
			cmp.w    #0, tcb_block(r15)
				jeq  findOnBlock

step5:      mov.w     ctid, r14
		    add.w	 r14, r14
		    add.w	 r14, r14
		    add.w	 r14, r14
		    mov.w    tcb_stack(r14), SP
		    jmp      step6

enableInterrupts:
			bis.w   #(LPM0|GIE),SR                 ; enable interrupts
			clr     &counter
			jmp     findOnBlock

step6:      pop.w   r4
			pop.w   r5
			pop.w   r6
			pop.w   r7
			pop.w   r8
			pop.w   r9
			pop.w   r10
			pop.w   r11
			pop.w   r12
			pop.w   r13
			pop.w   r14
			pop.w   r15

            reti


; Interrupt Vector --------------------------------------------------------
            .sect   ".int08"                ; timer A section
            .word   TA_isr                  ; timer A isr
            .end
