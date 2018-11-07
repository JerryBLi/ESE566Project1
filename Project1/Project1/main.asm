;-----------------------------------------------------------------------------
; Assembly main line
;-----------------------------------------------------------------------------

include "m8c.inc"       ; part specific constants and macros
include "memory.inc"    ; Constants & macros for SMM/LMM and Compiler
include "PSoCAPI.inc"   ; PSoC API definitions for all User Modules

export _main

;---------------------------------------------;
;---------------------------------------------;
;----------------- VARIABLES -----------------;
;---------------------------------------------;
;---------------------------------------------;

;-------- EXPORTS -------
; We update pushButtonDownTime in PushButtonTimerINT (when the push button's timer detects 1/10th second increment)
export pushButtonDownTime

;We update the variables currNumHours, currNumMins, currNumSecs, and currNumDeciSecs in the StopwatchTimerINT.asm. 
export currNumHours
export currNumMins
export currNumSecs
export currNumDeciSecs

;We update the main FSM and sub FSM states in PSoCGPIOINT.asm, upon button presses.
export currState
export currSubState
export subStateTable


;-------- ALLOCATIONS ------
area bss(ram) ;What is the name field??? What should I put?
currState: blk 1 ; 1 byte for current main state
currSubState: blk 1 ; 1 byte for current substate (internal states in main states)
soundAvg: blk 1 ; ???? HOW MANY BYTES TO STORE SOUND AVG??
currRes: blk 1 ; 1 byte to store the current resolution of timer

;Variables to store the current stopwatch time
currNumHours: blk 1 ; 1 byte to store number of hours
currNumMins: blk 1 ; 1 byte to store number of minutes
currNumSecs: blk 1 ; 1 byte to store number of seconds
currNumDeciSecs: blk 1 ; 1 byte to store number of deci-seconds


;this section is for the metrics
;WE NEED TO TALK ABOUT HOW TO STORE THIS
shortestTime: blk 2 ; 2 shortest time recorded
averageTime: blk 2 ; 2 average time recorded
longestTime: blk 2 ; 2 longest time recorded

;variables for multiplication
multiplicationResult: blk 4
xValue: blk 2
yValue: blk 2

pushButtonDownTime: blk 1;how long has the pushbutton been pressed in 1/10th of sec?

tempVar: blk 4
tempByte: blk 1

;Let's just store everything in seconds
memData0: blk 2
memData1: blk 2
memData2: blk 2
memData3: blk 2
memData4: blk 2

;variables for sound measurements
thresholdValue: blk 2	; 16 bits set initially or by microphoneCalibrationMode
soundValue: 	blk 2 	; 16 bits from ADC

;----------------------------------------------;
;----------------------------------------------;
;----------------- MAIN ENTRY -----------------;
;----------------------------------------------;
;----------------------------------------------;

area text(ROM,REL)
_main:
	
	; ---------------------
	; INIT
	; ---------------------
	
	;----Enable Interrupt for Port1 Pin 0----;
	;Check out http://www.cypress.com/file/67321/download
	or REG[PRT1IC0],0x80 ;P0_7 configured as change from read part 1
	or REG[PRT1IC1],0x80 ;P0_7 configured as change from read part 2
	or REG[PRT1IE], 0x80 ;enable P0_7
	
	M8C_EnableIntMask INT_MSK0, INT_MSK0_GPIO ; Enable GPIO Interrupt 
    M8C_EnableGInt ; enable Global Interrupts
	 
	; Insert your main assembly code here.
	lcall PushButtonTimer_EnableInt ;enable the pushbutton timer interrupt
	lcall StopwatchTimer_EnableInt ;enable the stopwatch timer interrupt
	
	; Initialize LCD and display splash screen
	lcall _LCD_Init
	
	; Initialize PGA's and Dual ADC's
	mov   A, PGA_1_HIGHPOWER 		; enable PGA 1 in high power mode
    lcall PGA_1_Start			
	
	mov   A, PGA_2_HIGHPOWER 		; enable PGA 2 in high power mode
    lcall PGA_2_Start
	
    mov   A, LPF2_1_HIGHPOWER 		; enable LPF2 in high power mode
    lcall LPF2_1_Start
	
    mov   A, 7   					; set resolution to 7 Bits
    lcall  DUALADC_1_SetResolution

    mov   A, DUALADC_1_HIGHPOWER  	; enable ADC in high power mode
    lcall  DUALADC_1_Start

    mov   A, 00h          			; use ADC in continuous sampling mode
    lcall  DUALADC_1_GetSamples
	
	; Initialize variables in RAM
	mov [currNumHours], 0
	mov [currNumMins], 0
	mov [currNumSecs], 0
	mov [currNumDeciSecs], 0
	
	mov [thresholdValue+1], 3Ch		; LSB of thresholdValue
	mov [thresholdValue+0], 00h		; MSB of thresholdValue
	
	; ---------------------
	; SPLASH SCREEN
	; ---------------------
	;;;;; Display first row of splash screen
	mov A, 0 ; Set LCD Position: Row (A) = 0
	mov X, 0 ; Col (X) = 0
	lcall _LCD_Position
	mov A, >SPLASH_SCREEN_A ; Move MSB of ROM string address into A
	mov X, <SPLASH_SCREEN_A ; Move LSB into X
	lcall _LCD_PrCString
	;;;;; Now display second row
	mov A, 1 ; Move to row 2
	mov X, 0
	lcall _LCD_Position
	mov A, >SPLASH_SCREEN_B
	mov X, <SPLASH_SCREEN_B
	lcall _LCD_PrCString
	;;;; Show for two seconds
	splash_delay:
		lcall StopwatchTimer_Start
		cmp [currNumSecs], 2
		jc splash_delay ; If carry, that means currNumSecs < 2, so loop
		
	call StopwatchTimer_Stop
	mov [currNumSecs], 0
	mov [currNumDeciSecs], 0
	
	; ---------------------
	; ENTER MAIN FSM
	; ---------------------
	; go to soundMode(0) first
	mov [currState], 0 
	mov [currSubState], 0
	jmp soundMode 
	
	
	; go to pushButtonMode(1) first
;	mov [currState], 1 
;	mov [currSubState], 0
;	jmp pushButtonMode 
	
	;----------------------------------------------
	;----------------------------------------------
	; FOR YURIY, THIS IS TO START THE TIMER
	;----------------------------------------------
	;----------------------------------------------
	lcall StopwatchTimer_Start
	
	
test:
nop
jmp test

;-------------------------------------------------------------;
;----------------- MAIN FINITE STATE MACHINE -----------------;
;-------------------------------------------------------------;
; Each procedure will have to check if "currentState" matches the procedure
; If currentState indictes a different state, call procedure to change states.

; --------------------------------------------
; ----- Sound Mode (STATE 0):
; --------------------------------------------
; we determine if the sound level is 2x the average
; If it is, then start the timer
; SUBSTATES:
; 0 = waiting for whistle
; 1 = started timer (whistle detected)
soundMode:
	; Check that we're in the right state
	cmp [currState], 0
	jnz changeState

	; Go to correct substate
	cmp [currSubState], 0
	jz waitForADC_1
	; If we eschew error handling, we can just make this jump to _run
	cmp [currSubState], 1
	jz startTimer
	
	waitForADC_1: 
		; waiting for sound
		lcall LCD_Wipe ; TODO: lcall necessary, or just call?
		mov A, >SOUND_MODE
		mov X, <SOUND_MODE
		lcall _LCD_PrCString
		
		mov A, [thresholdValue + 0] ; display MSB 
		lcall _LCD_PrHexByte
		mov A, [thresholdValue + 1]	; display LSB
		lcall _LCD_PrHexByte


		lcall StopwatchTimer_Stop 					; start stop watch
		lcall  DUALADC_1_fIsDataAvailable	; check if there is data available from the ADC
	    jz    waitForADC_1					; poll until data is ready

	dataReadyADC_1:
		; data is ready, display on LCD
		mov A, 1
		mov X, 0
		lcall _LCD_Position
		mov A, >SOUND_VAL
		mov X, <SOUND_VAL
		lcall _LCD_PrCString
		
		M8C_DisableGInt   					; we want to temporarily disable global interrupts
	    lcall DUALADC_1_iGetData1        	; Get ADC1(P01) Data (X = MSB A=LSB)
		M8C_EnableGInt 						; re-enable global interrupts 
		
		; clear flags
		lcall DUALADC_1_ClearFlag 			; clear ADC1 flags 
		and F, FBh							; clear the CF
		
		; save ADC readings
		
		mov [soundValue + 0], X				; save MSB of ADC1 data
		mov [soundValue + 1], A				; save LSB of ADC1 data
		
		; display ADC readings onto LCD
		mov A, [soundValue + 0]
		lcall _LCD_PrHexByte
		mov A, [soundValue + 1]
		lcall _LCD_PrHexByte
	
	compareSound_MSB:
		mov A, [soundValue + 0]
		cmp A, [thresholdValue + 0]					; compare MSB
		jz compareSound_LSB							; if the MSB's are 0, then check LSB
		jnc startTimer								; if there was no carry, 
													; 	then soundValue MSB is greater than thresholdValue MSB,
													;	so start timer
		jmp waitForADC_1							; if there was a carry, 
													;	then soundValue MSB is less than thresholdValue MSB,
													;	so keep waiting for more sound data
	compareSound_LSB:
		mov A, [soundValue + 1]
		cmp A, [thresholdValue + 1]					; compare LSB
		jnc startTimer								; if there was no carry,
													;	soundValue LSB is greater than thresholdValue LSB,
													;	so start the timer
		jmp waitForADC_1							; if there was a carry, 
													;	then soundValue MSB is less than thresholdValue MSB,
													;	so keep waiting for more sound data
	startTimer:
		mov [currSubState], 1 
		lcall LCD_Wipe								; wipe the screen
		lcall displayTime							; display time
		mov A, 1									; move to second row of LCD
		mov X, 0
		lcall _LCD_Position	
		mov A, >GOT_WHISTLE							
		mov X, <GOT_WHISTLE
		lcall _LCD_PrCString						; display WHISTLE!
		
		lcall StopwatchTimer_Start 					; start stop watch
		
		jmp soundMode
; --------------------------------------------
; ----- Pushbutton Mode (STATE 1):
; --------------------------------------------
;we determine if the pushbutton has been pushed less than .5s
;if so, we start the timer
pushButtonMode:
	; Check that we're in the right state (TODO: replace with macro?)
	cmp [currState], 1
	jnz changeState
	; Go to correct substate
	cmp [currSubState], 0
	jz pushButtonMode_stop
	; If we eschew error handling, we can just make this jump to _run
	cmp [currSubState], 1
	jz pushButtonMode_run
	; If we get here - DISPLAY ERROR MESSAGE
	lcall LCD_Wipe ; TODO: lcall necessary, or just call?
	mov A, >BAD_SUBSTATE_ERR
	mov X, <BAD_SUBSTATE_ERR
	lcall _LCD_PrCString
	jmp pushButtonMode
	
	pushButtonMode_stop:
		; Timer is stopped!
		; -- DISPLAY -- 
		lcall LCD_Wipe ; TODO: lcall necessary, or just call?
		lcall displayTime ; First row: display time
		; Move to second row (TODO: replace with macro?)
		mov A, 1
		mov X, 0
		lcall _LCD_Position
		mov A, >STOPPED
		mov X, <STOPPED
		lcall _LCD_PrCString
		; -- CONTROL --
		lcall StopwatchTimer_Stop ; Make sure the stopwatch is stopped
		; TODO: We can loop forever and check for a switched state/substate manually
		; Or we can go to pushButtonMode, but this means this code will be called repeatedly
		jmp pushButtonMode
		
	pushButtonMode_run:
		; Timer is running!
		; -- DISPLAY -- (TODO: redundant code, maybe move to psuhButton?)
		lcall LCD_Wipe ; TODO: lcall necessary, or just call?
		lcall displayTime ; First row: display time
		; Move to second row (TODO: replace with macro?)
		mov A, 1
		mov X, 0
		lcall _LCD_Position
		mov A, >RUNNING
		mov X, <RUNNING
		lcall _LCD_PrCString
		; -- CONTROL --
		lcall StopwatchTimer_Start ; Make sure the stopwatch is stopped
		; TODO: We can loop forever and check for a switched state/substate manually
		; Or we can go to pushButtonMode, but this means this code will be called repeatedly
		jmp pushButtonMode

; --------------------------------------------
; ----- Microphone Calibration Mode (STATE 2):
; --------------------------------------------
;we record the current noise level for an [UNDETERMINED] number of seconds
;Take the average of the noise levels recorded
;Set that average as the new average
microphoneCalibrationMode:
	; Check that we're in the right state
	cmp [currState], 2
	jnz changeState
	; Go to correct substate
	cmp [currSubState], 0
	jz microphoneCalibrationMode_stop
	; If we eschew error handling, we can just make this jump to _run
	cmp [currSubState], 1
	jz microphoneCalibrationMode_run
	; If we get here - DISPLAY ERROR MESSAGE
	lcall LCD_Wipe ; TODO: lcall necessary, or just call?
	mov A, >BAD_SUBSTATE_ERR
	mov X, <BAD_SUBSTATE_ERR
	lcall _LCD_PrCString
	jmp pushButtonMode
	
	microphoneCalibrationMode_stop:
		; Timer is stopped!
		; -- DISPLAY -- 
		lcall LCD_Wipe ; TODO: lcall necessary, or just call?
		lcall displayTime ; First row: display time
		; Move to second row (TODO: replace with macro?)
		mov A, 1
		mov X, 0
		lcall _LCD_Position
		mov A, >TEST_STR_A
		mov X, <TEST_STR_A
		lcall _LCD_PrCString
		; -- CONTROL --
		lcall StopwatchTimer_Stop ; Make sure the stopwatch is stopped
		; TODO: We can loop forever and check for a switched state/substate manually
		; Or we can go to pushButtonMode, but this means this code will be called repeatedly
		jmp pushButtonMode
		
	microphoneCalibrationMode_run:
		; Timer is running!
		; -- DISPLAY -- (TODO: redundant code, maybe move to psuhButton?)
		lcall LCD_Wipe ; TODO: lcall necessary, or just call?
		lcall displayTime ; First row: display time
		; Move to second row (TODO: replace with macro?)
		mov A, 1
		mov X, 0
		lcall _LCD_Position
		mov A, >TEST_STR_B
		mov X, <TEST_STR_B
		lcall _LCD_PrCString
		; -- CONTROL --
		lcall StopwatchTimer_Start ; Make sure the stopwatch is stopped
		; TODO: We can loop forever and check for a switched state/substate manually
		; Or we can go to pushButtonMode, but this means this code will be called repeatedly
		jmp pushButtonMode

; --------------------------------------------
; ----- Resolution Setting Mode (STATE 3):
; --------------------------------------------
;Set the resolution of the timer between 1s, 1/2s, 1/10s
;modes: 0 = 1s; 1 = 1/2s; 2 = 1/10s
resolutionSettingMode:
	; Check that we're in the right state
	cmp [currState], 3
	jnz changeState

	;Display the current resolution
	resolutionSettingMode_displayMode:
	;todo - we need to test if this works
	lcall LCD_Wipe
	mov A, 0 ; Set LCD Position: Row (A) = 0
	mov X, 0 ; Col (X) = 0
	lcall _LCD_Position
	;choose which string to display
	cmp [currRes], 0
	jz resolutionSettingMode_display0P1
	cmp [currRes], 1
	jz resolutionSettingMode_display0P5
	cmp [currRes], 2
	jz resolutionSettingMode_display1P0
	resolutionSettingMode_display0P1:
	mov A, >CURRENT_RES_0P1 ; Move MSB of ROM string address into A
	mov X, <CURRENT_RES_0P1 ; Move LSB into X
	lcall _LCD_PrCString
	jmp resolutionSettingMode
	resolutionSettingMode_display0P5:
	mov A, >CURRENT_RES_0P5 ; Move MSB of ROM string address into A
	mov X, <CURRENT_RES_0P5 ; Move LSB into X
	lcall _LCD_PrCString
	jmp resolutionSettingMode
	resolutionSettingMode_display1P0:
	mov A, >CURRENT_RES_1P0 ; Move MSB of ROM string address into A
	mov X, <CURRENT_RES_1P0 ; Move LSB into X
	lcall _LCD_PrCString
	jmp resolutionSettingMode

	;DO THE FOLLOWING IF THERE IS A SHORT BUTTON PRESS
	resolutionSettingMode_changeMode:
	;increment the currRes variable
	;if the variable is greater than 2 then set back to 0
	inc [currRes]
	cmp [currRes],3
	jz resolutionSettingMode_resetRes
	jmp resolutionSettingMode_displayMode
	
	resolutionSettingMode_resetRes:
	mov [currRes],0
	jmp resolutionSettingMode_displayMode
	
	
	



; --------------------------------------------
; ----- Memory Mode (STATE 4):
; --------------------------------------------
;Display statistics - average, longest, shortest
memoryMode:
	; Check that we're in the right state
	cmp [currState], 4
	jnz changeState


;----------------------------------------------------;
;----------------- HELPER FUNCTIONS -----------------;
;----------------------------------------------------;

;;;;;;;;;;;;;;;;;;;;
; Change Main State (METASTATE - NOT A PROCEDURE: JUMP HERE, DON'T CALL)
;;;;;;;;;;;;;;;;;;;;
; This state is jumped to when a state notices that it doesn't match currentState 
; Take us to the correct state
changeState:
	mov A, [currState] ; Move to A to speed up comparisons
	cmp A, 0
	jz soundMode
	cmp A, 1
	jz pushButtonMode
	cmp A, 2
	jz microphoneCalibrationMode
	cmp A, 3
	jz resolutionSettingMode
	cmp A, 4
	jz memoryMode
	; If we're here, currentState is invalid.
	; Display error text.
	lcall LCD_Wipe ; TODO: lcall necessary, or just call?
	mov A, >BAD_STATE_ERROR
	mov X, <BAD_STATE_ERROR
	lcall _LCD_PrCString
	; Just loop again, I suppose.
	jmp changeState

;;;;;;;;;;;;;;;
; Display Time (PROCEDURE: CALL):
;;;;;;;;;;;;;;;
; Displays the time in HRS:MIN:SEC:[RES] format
; (display time using currNumHours, currNumMins; currNumSecs, currNumDeciSecs)
; Parameters: None (assumed LCD position already set)
; Overwrites A (and X?)
displayTime:
	; Display hours: put currNumHours in A, then call LCD print hex byte
	; HRS
	mov A, [currNumHours]
	lcall _LCD_PrHexByte
	; HRS:
	mov A, ':'
	lcall _LCD_WriteData
	; HRS:MIN
	mov A, [currNumMins]
	lcall _LCD_PrHexByte
	; HRS:MIN:
	mov A, ':'
	lcall _LCD_WriteData
	; HRS:MIN:SEC
	mov A, [currNumSecs]
	lcall _LCD_PrHexByte
	; HRS:MIN:SEC:
	mov A, ':'
	lcall _LCD_WriteData
	; HRS:MIN:SEC:[RES]
	mov A, [currNumDeciSecs]
	lcall _LCD_PrHexByte
	; --- END ---
	ret
	


;Calculate Time In Seconds:
;Convert the time from hrs, min, sec to seconds
;http://www.cypress.com/file/106946/download
calculateTimeInSeconds:

; Wipe the LCD clean. 
; Overwrites A and X.
LCD_Wipe:
	; Put blank line (16 spaces) on line 0
	mov A, 0
	mov X, 0
	lcall _LCD_Position
	mov A, >BLANK_LINE
	mov X, <BLANK_LINE
	lcall _LCD_PrCString
	; Put blank line on line 1
	mov A, 1
	mov X, 0
	lcall _LCD_Position
	mov A, >BLANK_LINE
	mov X, <BLANK_LINE
	lcall _LCD_PrCString
	; Place LCD position on 0, 0
	mov A, 0
	mov X, 0
	lcall _LCD_Position
	; --- END ---
	ret
	

.terminate:
    jmp .terminate



;----------------------------------------------------;
; --------------- CONSTANT STRINGS ------------------;
;----------------------------------------------------;

.LITERAL 
subStateTable: 
 	; Typically just "this state + 1" will rollover to 0 for inaccessible states
	; 4 column maximum at the moment - can be expanded with appropriate changes to PSoCGPIOINT
	; |  STATE 0  |  STATE 1  |  STATE 2  |  STATE 3  |  STATE 5  |    
	db 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 2, 0, 0, 1, 2, 3, 0
SPLASH_SCREEN_A:
	ds "  ESE566 WATCH  "
	db 0x0
SPLASH_SCREEN_B:
	ds "  JL/JR/RRR/YS  "
	db 0x0
BLANK_LINE:
	ds "                "
	db 0x0
BAD_STATE_ERROR:
	ds "BAD STATE ERROR "
	db 0x0
BAD_SUBSTATE_ERR:
	ds "BAD SUBSTATE ERR"
	db 0x0
STOPPED:
	ds "STOPPED!"
	db 0x0
RUNNING: 
	ds "RUNNING..."
	db 0x0
TEST_STR_A:
	ds "A TEST A!"
	db 0x0
TEST_STR_B:
	ds "B TEST B!"
	db 0x0
SOUND_MODE:
	ds "SOUND MODE  "
	db 0x0
WAITING_FOR_SOUND:
	ds "W "
	db 0x0
SOUND_VAL:
	ds "S: "
	db 0x0
GOT_WHISTLE:
	ds "WHISTLE! "
	db 0x0
;string literals for current resolutions to display to user
CURRENT_RES_0P1:
	ds "CURR RES: 0.1s"
	db 0x0
CURRENT_RES_0P5:
	ds "CURR RES: 0.5s"
	db 0x0
CURRENT_RES_1P0:
	ds "CURR RES: 1.0s"
	db 0x0
.ENDLITERAL 