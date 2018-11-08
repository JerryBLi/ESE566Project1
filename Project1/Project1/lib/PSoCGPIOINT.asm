;  Generated by PSoC Designer 5.4.3191
;
;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME: PSoCGPIOINT.asm
;;   Version: 2.0.0.20, Updated on 2003/07/17 at 12:10:35
;;  @PSOC_VERSION
;;
;;  DESCRIPTION: PSoC GPIO Interrupt Service Routine
;;-----------------------------------------------------------------------------
;;  Copyright (c) Cypress Semiconductor 2015. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************

include "m8c.inc"
include "PSoCGPIOINT.inc"

;-----------------------------------------------
;  Global Symbols
;-----------------------------------------------
export   PSoC_GPIO_ISR


;-----------------------------------------------
;  Constant Definitions
;-----------------------------------------------


;-----------------------------------------------
; Variable Allocation
;-----------------------------------------------
	

;@PSoC_UserCode_INIT@ (Do not change this line.)
;---------------------------------------------------
; Insert your custom declarations below this banner
;---------------------------------------------------

;---------------------------------------------------
; Insert your custom declarations above this banner
;---------------------------------------------------
;@PSoC_UserCode_END@ (Do not change this line.)


;-----------------------------------------------------------------------------
;  FUNCTION NAME: PSoC_GPIO_ISR
;
;  DESCRIPTION: Unless modified, this implements only a null handler stub.
;
;-----------------------------------------------------------------------------
;
PSoC_GPIO_ISR:


   ;@PSoC_UserCode_BODY@ (Do not change this line.)
	;---------------------------------------------------
	; GPIO ISR:
	; We check if it's a down press of up press
	; If down press, we start timer to see how long 
	; If up press, we calculate how long the press is
	;---------------------------------------------------
	;preserve registers
	push A
	push X
	mov A, reg[CUR_PP]
	push A
	
	mov A, reg[PRT1DR] ;read state
	and A,0x01 ; mask only port 1_0
	cmp A, 1 ; Is this a down push?
	jz downPush
	;------ BUTTON RELEASED ------;
	lcall PushButtonTimer_Stop
	cmp [pushButtonDownTime], 6 ; Is downTime - 5 < 0? (i.e. is downTime < 5?)
	jnc longButtonPush ; The button push is longer than 0.5 seconds
	; ----- SHORT BUTTON PRESS
	; Change substate in subFSM
	shortButtonPush:
		; Light up LEDs with 1-001 for long press
		mov A, [Port_1_Data_SHADE]
		and A, 0b11100001 ; Only reset LED pins
		or A,  0b00010010 ; Bit mask LEDs we wanna light up
		mov reg[PRT1DR], A
		; Short buttons are complicated enough to require FSM table
		; Row offset is currState * (max columns), so do this multiplication manually.
		; CURRENTLY the max number of columns is 4.
		mov A, [currState]
		add A, [currState] 
		add A, [currState]
		add A, [currState]
		; Column offset is current substate
		add A, [currSubState]
		index subStateTable ; A now gets next substate
		mov [currSubState], A ; Move it into current substate.
		mov [tempInit], 0 ; for soundMode
		jmp restore_GPIO_ISR ; Restore from ISR
	; ----- LONG BUTTON PRESS
	; Change main FSM state
	longButtonPush:
		; Light up LEDs with 1-110 for long press
		mov A, [Port_1_Data_SHADE]
		and A, 0b11100001 ; Only reset LED pins
		or A,  0b00011100 ; Bit mask LEDs we wanna light up
		mov reg[PRT1DR], A
		; subState resets between main FSM state changes, of course
		mov [currSubState], 0
		; Since we cycle between states (0 -> 1 -> 2 -> 3 -> 4 -> 0), we can just increment currentState
		inc [currState]
		cmp [currState], 5 ; Carry flag will NOT be set if currState >= 5. 
		jc restore_GPIO_ISR ; If carry flag is set, currState is a valid value, so skip this rollover step
		mov [currState], 0 ; If we get here, we got 5: means 4 was incrd - rollover to 0.
		mov [tempInit], 0 ; for soundMode
		jmp restore_GPIO_ISR ; NOW go to restore
	;------ BUTTON PRESSED ------;
	downPush:
		; Light up LEDs with 1-000 for downPress
		mov A, [Port_1_Data_SHADE]
		and A, 0b11100001 ; Only reset LED pins
		or A,  0b00010000 ; Bit mask LEDs we wanna light up
		mov reg[PRT1DR], A
		lcall PushButtonTimer_Start ; start the pushbutton timer
		;cmp [pushButtonDownTime], 5
		; No need for a jump, just continue to restore
	restore_GPIO_ISR:
		mov [pushButtonDownTime], 0 ; Reset this time back to 0.
		; Restore registers
		pop A
		mov reg[CUR_PP],A
		pop X
		pop A
		
   ;@PSoC_UserCode_END@ (Do not change this line.)

   reti


; end of file PSoCGPIOINT.asm
