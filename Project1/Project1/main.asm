;-----------------------------------------------------------------------------
; Assembly main line
;-----------------------------------------------------------------------------

include "m8c.inc"       ; part specific constants and macros
include "memory.inc"    ; Constants & macros for SMM/LMM and Compiler
include "PSoCAPI.inc"   ; PSoC API definitions for all User Modules

export _main

;---------------------------------------------;
;----------------- MACROS --------------------;
;---------------------------------------------;

; Input: @0 - Bit mask (0b000_ _ _ _0), where the 4 spaces are 1 to light LEDs
macro LIGHT_LEDS
	mov A, [Port_1_Data_SHADE]
	and A, 0b11100001 ; Only reset LED pins
	or A,  @0 ; Bit mask LEDs we wanna light up (with input argument to macro)
	mov reg[PRT1DR], A
endm 

; led_pos (row), (column) sets the LED to be at a specific row or column
macro LCD_POS
	mov A, @0
	mov X, @1
	lcall _LCD_Position
endm 

; led_pos (STRING_LABEL) prints the specified text at the specified position.
macro LCD_PRINT
	mov A, >@0
	mov X, <@0
	lcall _LCD_PrCString
endm 

; Reset stopwatch time
macro RESET_TIME
	mov [currNumDeciSecs], 0
	mov [currNumSecs], 0
	mov [currNumMins], 0
	mov [currNumHours], 0
endm

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


export tempInit ; ; used to skip initializations in sound mode

;-------- ALLOCATIONS ------
area bss(ram) ;What is the name field??? What should I put?
currState: blk 1 ; 1 byte for current main state
currSubState: blk 1 ; 1 byte for current substate (internal states in main states)
soundAvg: blk 1 ; ???? HOW MANY BYTES TO STORE SOUND AVG??
currRes: blk 1 ; 1 byte to store the current resolution of timer

pushButtonDownTime: blk 1;how long has the pushbutton been pressed in 1/10th of sec?

;Variables to store the current stopwatch time
currNumHours: blk 1 ; 1 byte to store number of hours
currNumMins: blk 1 ; 1 byte to store number of minutes
currNumSecs: blk 1 ; 1 byte to store number of seconds
currNumDeciSecs: blk 1 ; 1 byte to store number of deci-seconds

measDone: blk 1 ; Indicate that a measurement has been done.

;this section is for the metrics
;WE NEED TO TALK ABOUT HOW TO STORE THIS
shortestTime: blk 2 ; 2 shortest time recorded
averageTime: blk 2 ; 2 average time recorded
longestTime: blk 2 ; 2 longest time recorded

;variables for multiplication
;JL+
multiplicationResult: blk 2
tempTimeInSec: blk 2
tempVar2: blk 4


tempVar: blk 4
tempByte: blk 1

;Let's just store everything in seconds
memData0: blk 2
memData1: blk 2
memData2: blk 2
memData3: blk 2
memData4: blk 2

;variables for sound measurements
whistleValue: blk 2	; 16 bits set initially or by microphoneCalibrationMode
soundValue: 	blk 2 	; 16 bits from ADC
tempInit: blk 1			; used to skip initializations
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
	
	; Light all LEDs to indicate startup.
	LIGHT_LEDS 0b00011110
	
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
	
	;JL+
	mov [shortestTime], 0xFF ;Set lower byte to FF so that it's largest possible value
	mov [shortestTime + 1], 0xFF ;Set upper byte to FF so that it's largest possible value
	
	;YS - shadow
	mov [Port_1_Data_SHADE], 0b00000000
	mov [measDone], 0
	
	mov [whistleValue+1], 3Ch		; LSB of whistleValue
	mov [whistleValue+0], 00h		; MSB of whistleValue
	
	; ---------------------
	; SPLASH SCREEN
	; ---------------------
	;;;;; Display first row of splash screen
	LCD_POS 0, 0
	LCD_PRINT SPLASH_SCREEN_A
	;mov A, 0 ; Set LCD Position: Row (A) = 0
	;mov X, 0 ; Col (X) = 0
	;lcall _LCD_Position
;	mov A, >SPLASH_SCREEN_A ; Move MSB of ROM string address into A
;	mov X, <SPLASH_SCREEN_A ; Move LSB into X
;	lcall _LCD_PrCString
	;;;;; Now display second row
	LCD_POS 1,0
	LCD_PRINT SPLASH_SCREEN_B
;	mov A, 1 ; Move to row 2
;	mov X, 0
;	lcall _LCD_Position
;	mov A, >SPLASH_SCREEN_B
;	mov X, <SPLASH_SCREEN_B
;	lcall _LCD_PrCString
	;;;; Show for two seconds
	splash_delay:
		lcall StopwatchTimer_Start
		cmp [currNumSecs], 2
		jc splash_delay ; If carry, that means currNumSecs < 2, so loop
	call StopwatchTimer_Stop
	mov [currNumSecs], 0
	mov [currNumDeciSecs], 0
	
	lcall LCD_Wipe ; Wipe splash screen off of LCD
	
	; ---------------------
	; ENTER MAIN FSM
	; ---------------------
	; go to soundMode(0) first
	;mov [currState], 0 
	;mov [currSubState], 0
	;jmp soundMode 
	
	
	; go to pushButtonMode(1) first
	mov [currState], 1 
	mov [currSubState], 0
	jmp pushButtonMode 
	
;-------------------------------------------------------------;
;----------------- MAIN FINITE STATE MACHINE -----------------;
;-------------------------------------------------------------;
; Each procedure will have to check if "currentState" matches the procedure
; If currentState indictes a different state, call procedure to change states.

; --------------------------------------------
; ----- Sound Mode (STATE 0):
; --------------------------------------------
; We poll for a whistle
; If a whistle is detected, we start the timer
; While the timer is running, we wait for another whistle or a short button press
; If another whistle is detected, we stop the timer and poll for another whistle
; SUBSTATES:
; 0 = waiting for whistle
; 1 = timer started (whistle detected) - waiting for whistle/pushbutton to stop
soundMode:
	; Check that we're in the right state
	cmp [currState], 0
	jnz changeState

	; Light up LEDs with 0-001 (1)
	LIGHT_LEDS 0b00000010
	
	; Go to correct substate
	cmp [currSubState], 0
	jz wait0ForWhistle_init
	; If we eschew error handling, we can just make this jump to _run
	cmp [currSubState], 1
	jz startTimer_init
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; SUBSTATE 0: waiting for whistle
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	wait0ForWhistle_init: 
		cmp [measDone], 1 ; Did we just finish a measurement? (kludge for button)
		jz exit1state ; If so, then go.
		cmp [tempInit], 1						; check if we already initialized
		jz wait0ForWhistle_idle				; 1 == already initialized; 0 == not initialized
	wait0ForWhistle_init_LCD: 
		lcall StopwatchTimer_Stop 			; stop stop watch
		lcall LCD_Wipe 						; TODO: lcall necessary, or just call?
		lcall displayTime
		LCD_POS 1, 0
		LCD_PRINT SOUND_MODE_idle
;		mov A, 1							; move to second row of LCD
;		mov X, 0
;		lcall _LCD_Position	
;		mov A, >SOUND_MODE_idle
;		mov X, <SOUND_MODE_idle
;		lcall _LCD_PrCString
		mov [tempInit], 1					; 1 == already initialized;
	wait0ForWhistle_idle:
		;M8C_EnableGInt 					; re-enable global interrupts 
		;lcall StopwatchTimer_Stop 			; stop stop watch
		lcall  DUALADC_1_fIsDataAvailable	; check if there is data available from the ADC
	    jz    soundMode			; poll until data is ready

	data0ReadyADC_1:
		; data is ready
		M8C_DisableGInt   					; we want to temporarily disable global interrupts
	    lcall DUALADC_1_iGetData1        	; Get ADC1(P01) Data (X = MSB A=LSB)
		M8C_EnableGInt 						; re-enable global interrupts 
		
		; clear flags
		lcall DUALADC_1_ClearFlag 			; clear ADC1 flags 
		and F, FBh							; clear the CF
		
		; save ADC readings
		mov [soundValue + 0], X				; save MSB of ADC1 data
		mov [soundValue + 1], A				; save LSB of ADC1 data
		
	compare0Sound_MSB:
		mov A, [soundValue + 0]
		cmp A, [whistleValue + 0]					; compare MSB
		jz compare0Sound_LSB						; if the MSB's are 0, then check LSB
		jnc exit0state								; if there was no carry, 
													; 	then soundValue MSB is greater than whistleValue MSB,
													;	so start timer
		jmp soundMode								; if there was a carry, 
													;	then soundValue MSB is less than whistleValue MSB,
													;	so keep waiting for more sound data
	compare0Sound_LSB:
		mov A, [soundValue + 1]
		cmp A, [whistleValue + 1]					; compare LSB
		jnc exit0state								; if there was no carry,
													;	soundValue LSB is greater than whistleValue LSB,
													;	so start the timer
		jmp soundMode								; if there was a carry, 
													;	then soundValue MSB is less than whistleValue MSB,
													;	so keep waiting for more sound data
	
	exit0state:
		mov [tempInit] , 0
		jmp startTimer_init
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;										
	; SUBSTATE 1 = timer started (whistle detected)
	;	 - waiting for whistle/pushbutton to stop
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	startTimer_init:
		mov [measDone], 1 ; Note that we're doing a measurement
		cmp [tempInit], 1								; check if we already initialized
		jz startTimer_idle							; 1 = already initialized; 0 = not initialized
	startTimer_init_LCD:
		mov [currSubState], 1 
		lcall LCD_Wipe
		lcall displayTime							; display time
		LCD_POS 1, 0
		LCD_PRINT SOUND_MODE_active
;		mov A, 1									; move to second row of LCD
;		mov X, 0
;		lcall _LCD_Position	
;		mov A, >SOUND_MODE_active
;		mov X, <SOUND_MODE_active
;		lcall _LCD_PrCString
		lcall StopwatchTimer_Start 					; start stop watch
		mov [tempInit], 1							; 1 = already initialized;
	startTimer_idle:
		mov A, 0									; move to first row of LCD
		mov X, 0
		lcall _LCD_Position							
		lcall displayTime							; display time
		;M8C_EnableGInt 						; re-enable global interrupts 
	; wait for either a whistle or a pushbutton press
	wait1ForWhistle: 	
	
		lcall  DUALADC_1_fIsDataAvailable			; check if there is data available from the ADC
	    jz    soundMode						; poll until data is ready
		
	data1ReadyADC_1:
		M8C_DisableGInt   							; we want to temporarily disable global interrupts
	    lcall DUALADC_1_iGetData1        			; Get ADC1(P01) Data (X = MSB A=LSB)
		M8C_EnableGInt 								; re-enable global interrupts 
		
		; clear flags
		lcall DUALADC_1_ClearFlag 					; clear ADC1 flags 
		and F, FBh									; clear the CF
		
		; save ADC readings
		mov [soundValue + 0], X						; save MSB of ADC1 data
		mov [soundValue + 1], A						; save LSB of ADC1 data
	
	compare1Sound_MSB:
		mov A, [soundValue + 0]
		cmp A, [whistleValue + 0]					; compare MSB
		jz compare1Sound_LSB							; if the MSB's are 0, then check LSB
		jnc exit1state								; if there was no carry, 
													; 	then soundValue MSB is greater than whistleValue MSB,
													;	so STOP timer
		jmp soundMode							; if there was a carry, 
													;	then soundValue MSB is less than whistleValue MSB,
													;	so keep waiting for more sound data
	compare1Sound_LSB:
		mov A, [soundValue + 1]
		cmp A, [whistleValue + 1]					; compare LSB
		jnc exit1state								; if there was no carry,
													;	soundValue LSB is greater than whistleValue LSB,
													;	so STOP the timer
		jmp soundMode							; if there was a carry, 
													;	then soundValue MSB is less than whistleValue MSB,
													;	so keep waiting for more sound data
	
	exit1state:
		mov [tempInit] , 0
		; jmp stopTimer
	
	stopTimer:
		lcall StopwatchTimer_Stop
		; TODO: HERE WE CAN SAVE THE TIME INFO FROM SECONDS, MINUTES, ETC.
		; Light up LEDs with 0-110 (FROZEN SOUND OUTPUT)
		LIGHT_LEDS 0b00011000 
		LCD_POS 1,0
		LCD_PRINT SOUND_MODE_output
		lcall timeOutputFreeze ; Save measurement and freeze output
		mov [currSubState], 0 	; go to timer stopped state 
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
	
	; Light up LEDs with 0-010 (2)
	LIGHT_LEDS 0b00000100
	
	; Go to correct substate
	cmp [currSubState], 0
	jz pushButtonMode_stop
	; If we eschew error handling, we can just make this jump to _run
	cmp [currSubState], 1
	jz pushButtonMode_run
	; If we get here - DISPLAY ERROR MESSAGE
	lcall LCD_Wipe ; TODO: lcall necessary, or just call?
	LCD_PRINT BAD_SUBSTATE_ERR
;	mov A, >BAD_SUBSTATE_ERR
;	mov X, <BAD_SUBSTATE_ERR
;	lcall _LCD_PrCString
	jmp pushButtonMode
	
	pushButtonMode_stop:
		; Timer is stopped!
		; -- DISPLAY -- 
		; lcall displayDownTime ; DEBUG ONLY
;		mov A, 0									; move to first row of LCD
;		mov X, 0
;		lcall _LCD_Position	
		LCD_POS 0,0
		lcall displayTime ; First row: display time
		; Move to second row (TODO: replace with macro?)
		LCD_POS 1,0
		LCD_PRINT STOPPED
;		mov A, 1
;		mov X, 0
;		lcall _LCD_Position
;		mov A, >STOPPED
;		mov X, <STOPPED
;		lcall _LCD_PrCString
		; -- CONTROL --
		lcall StopwatchTimer_Stop ; Make sure the stopwatch is stopped
		cmp [measDone], 1 
		jnz pushButtonMode ; If 0 (or not 1), we came from mode switch - don't freeze output. 
		; If 1, however, we need to freeze the output.
		; Light up LEDs with 0-111 (FROZEN PUSHBUTTON OUTPUT)
		LIGHT_LEDS 0b00011100 
		LCD_POS 1,0
		LCD_PRINT OUTPUT
;		mov A, 1
;		mov X, 0
;		lcall _LCD_Position
;		mov A, >OUTPUT
;		mov X, <OUTPUT
;		lcall _LCD_PrCString
		lcall timeOutputFreeze ; Save measurement and freeze output
		; -- END -- 
		; Continue in this state
		jmp pushButtonMode
		
	pushButtonMode_run:
		; Timer is running!
		; -- DISPLAY -- (TODO: redundant code, maybe move to psuhButton?)
		; lcall displayDownTime ; DEBUG ONLY
		LCD_POS 0,0
;		mov A, 0									; move to first row of LCD
;		mov X, 0
;		lcall _LCD_Position	
		lcall displayTime ; First row: display time
		; Move to second row (TODO: replace with macro?)
		LCD_POS 1,0
		LCD_PRINT RUNNING
;		mov A, 1
;		mov X, 0
;		lcall _LCD_Position
;		mov A, >RUNNING
;		mov X, <RUNNING
;		lcall _LCD_PrCString
		; -- CONTROL --
		lcall StopwatchTimer_Start ; Make sure the stopwatch is stopped
		mov [measDone], 1 ; When we leave this state, note that measurement was done
		; -- END -- 
		; Continue in this state
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
	
	; Light up LEDs with 0-011 (3)
	LIGHT_LEDS 0b00000110 
	
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
		;lcall displayDownTime ; DEBUG ONLY
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
		; lcall displayDownTime ; DEBUG ONLY
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
		
		; -- END -- 
		; Continue in this state
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
	
	; Light up LEDs with 0-100 (4)
	LIGHT_LEDS 0b00001000

	; Resolves substate (JL+)
	cmp [currSubState], 1 ;if the substate is to increment the res
	jz resolutionSettingMode_changeMode ; Substate (1) = change Mode
	; Else (substate (0)) we go straight to display mode
	
	;Display the current resolution
	resolutionSettingMode_displayMode:
	;todo - we need to test if this works
	;lcall LCD_Wipe
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
	; -- END -- 
	; Continue in this state
	jmp resolutionSettingMode

	;DO THE FOLLOWING IF THERE IS A SHORT BUTTON PRESS
	resolutionSettingMode_changeMode:
	;increment the currRes variable
	;if the variable is greater than 2 then set back to 0
	mov [currSubState], 0 ;reset the substate back to display
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
	
	; Light up LEDs with 0-101 (5)
	LIGHT_LEDS  0b00001010
	; Print "MEM/ORY" on right side of screen
	LCD_POS 0, 13
	LCD_PRINT MEM_STR_A
	LCD_POS 1, 13
	LCD_PRINT MEM_STR_B
	
	; Go to correct substate
	cmp [currSubState], 0
	jz memoryMode_12
	cmp [currSubState], 1
	jz memoryMode_34
	cmp [currSubState], 2
	jz memoryMode_5avg
	cmp [currSubState], 3
	jz memoryMode_maxmin
	; If we get here - DISPLAY ERROR MESSAGE
	lcall LCD_Wipe ; TODO: lcall necessary, or just call?
	LCD_PRINT BAD_SUBSTATE_ERR
	jmp memoryMode
	
	memoryMode_12:
		LCD_POS 0,0
		; Display "01: "
		LCD_PRINT ONE_STR
		; Display measurement 0 (1)
		mov A, [memData0]
		mov X, [memData0 + 1]
		lcall _LCD_PrHexInt
		;;; Next row - display second measurement
		LCD_POS 1,0
		; Display "02: "
		LCD_PRINT TWO_STR
		; Display measurement 1 (2)
		mov A, [memData1]
		mov X, [memData1 + 1]
		lcall _LCD_PrHexInt
		; -- END -- 
		; Continue in this state
		jmp memoryMode
		
	memoryMode_34:
		LCD_POS 0,0
		; Display "03: "
		LCD_PRINT THREE_STR
		; Display measurement 2 (3)
		mov A, [memData2]
		mov X, [memData2 + 1]
		lcall _LCD_PrHexInt
		;;; Next row - display fourth measurement
		LCD_POS 1,0
		; Display "04: "
		LCD_PRINT FOUR_STR
		; Display measurement 3 (4)
		mov A, [memData3]
		mov X, [memData3 + 1]
		lcall _LCD_PrHexInt
		; -- END -- 
		; Continue in this state
		jmp memoryMode
		
	memoryMode_5avg:
		LCD_POS 0,0
		; Display "05: "
		LCD_PRINT FIVE_STR
		; Display measurement 4 (5)
		mov A, [memData4]
		mov X, [memData4 + 1]
		lcall _LCD_PrHexInt
		;;; Next row - display AVERAGE
		LCD_POS 1,0
		; Display "AVG:"
		LCD_PRINT AVG_STR
		; Display average time
		mov A, [averageTime]
		mov X, [averageTime + 1]
		lcall _LCD_PrHexInt
		; -- END -- 
		; Continue in this state
		jmp memoryMode
		
	memoryMode_maxmin:
		LCD_POS 0,0
		; Display "MAX:"
		LCD_PRINT MAX_STR
		; Display measurement 4 (5)
		mov A, [longestTime]
		mov X, [longestTime + 1]
		lcall _LCD_PrHexInt
		;;; Next row - display AVERAGE
		LCD_POS 1,0
		; Display "MIN:"
		LCD_PRINT MIN_STR
		; Display average time
		mov A, [shortestTime]
		mov X, [shortestTime + 1]
		lcall _LCD_PrHexInt
		; -- END -- 
		; Continue in this state
		jmp memoryMode


;----------------------------------------------------;
;----------------- HELPER FUNCTIONS -----------------;
;----------------------------------------------------;

;;;;;;;;;;;;;;;;;;;;
; Change Main State (METASTATE - NOT A PROCEDURE: JUMP HERE, DON'T CALL)
;;;;;;;;;;;;;;;;;;;;
; This state is jumped to when a state notices that it doesn't match currentState 
; Take us to the correct state
changeState:
	lcall LCD_Wipe ; Wipe LCD between state transitions.
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
	; -- Silently handle the error by just going to default state.
	;JL+
	;mov [currState], 0
	;ljmp soundMode
	; -- Display error text.
	lcall LCD_Wipe 
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
	; From here, we need to determine which resolution we're gonna display
	cmp [currRes], 2 ; Is resolution 1?
	jz endDisplayTime ; Then don't display the res
	cmp [currRes], 0 ; Is resolution 0.1?
	jz displayRes ; If yes, display the resolution.
	; If we're here, then resolution is 0.5. In that case, only display if DeciSecs is 5 or 0.
	cmp A, 5 ; If deciSecs = 5
	jz displayRes ; display
	cmp A, 0 ; else, if deciSecs = 0 
	jz displayRes ; display
	jmp endDisplayTime ; else, don't display
	displayRes:
	; HRS:MIN:SEC:
	mov A, ':'
	lcall _LCD_WriteData
	; HRS:MIN:SEC:[RES]
	mov A, [currNumDeciSecs]
	lcall _LCD_PrHexByte
	; --- END ---
	endDisplayTime:
	ret

; DEBUG ONLY: Display pushbutton down time.
;displayDownTime:
;DEBUG: DISPLAY DOWN TIME
;	mov A, 0
;	mov X, 14
;	lcall _LCD_Position
;	mov A, [pushButtonDownTime]
;	lcall _LCD_PrHexByte
;	mov A, 0
;	mov X, 0
;	lcall _LCD_Position
;	ret

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
	
timeOutputFreeze:
	M8C_DisableIntMask INT_MSK0, INT_MSK0_GPIO ; Disable GPIO interrupt so pushbutton doesn't work
	mov [pushButtonDownTime], 0
	lcall saveTimeData ; Save this measurement
	lcall PushButtonTimer_Start ; Use pushbutton timer to count out 2 seconds (20 deciseconds)
	; Use this time to save our measurement
	waitFor2Secs_loop:
		cmp [pushButtonDownTime], 20 ; Wait until 20 deciseconds. TODO: Make this variable?
		jc waitFor2Secs_loop ; If carry, we're < 20 so loop back.
	; We're out of the loop if we reach here.
	mov [pushButtonDownTime], 0
	M8C_EnableIntMask INT_MSK0, INT_MSK0_GPIO ; Re-enable GPIO (pushbutton) interrupt
	mov [measDone], 0 ; Remove pending measurement
	RESET_TIME ; Reset timer

;JL+
;Save Time Data:
;Saves the current time in seconds for memory mode
;http://www.cypress.com/file/133371/download
saveTimeData:
	;move current data down 1, we move both upper and lower bytes
	; 3->4 ; 2->3 ; 1->2 ; 0->1
	mov [memData4], [memData3]
	mov [memData4 + 1], [memData3 + 1]
	mov [memData3], [memData2]
	mov [memData3 + 1], [memData2 + 1]
	mov [memData2], [memData1]
	mov [memData2 + 1], [memData1 + 1]
	mov [memData1], [memData0]
	mov [memData1 + 1], [memData0 + 1]
	;tempVar = Hours * 3600
	;take a look at the section 2.19 of the doc above
	mov A, >tempVar
	push A
	mov A, <tempVar
	push A
	;3600 part
	mov A, 16 ;lower byte of 0x0E16 (3600)
	push A
	mov A, 0x0E ;upper byte of 0x0E16 (3600)
	push A
	;Hours part
	mov A, [currNumHours]
	push A
	mov A, 0
	push A
	lcall mulu_16x16_32
	add SP, 250 ;pop the stack ?
	;add the result in tempVar to tempTimeInSec
	mov A, [tempVar]
	add [tempTimeInSec], A
	mov A, [tempVar + 1]
	adc [tempTimeInSec + 1], A
	;Minutes * 60
	;take a look at the section 2.18 of the doc above
	mov X, 60 ;60 part of equation
	mov A, currNumMins ;Minutes part of equation
	lcall mulu_8x8_16
	;add the result to tempTimeInSec
	adc [tempTimeInSec + 1], A
	mov A, X
	add [tempTimeInSec], A
	
	;add seconds
	mov A, [currNumSecs]
	add [tempTimeInSec], A
	adc [tempTimeInSec + 1], 0
	;save to first memory slot
	mov [memData0], [tempTimeInSec]
	mov [memData0 + 1], [tempTimeInSec + 1]
	;is it the smallest value?
	saveTimeData_smallest_upper:
		mov A, [memData0 + 1]
		cmp A, [shortestTime + 1] 
		jz saveTimeData_smallest_lower ;the upper bytes are equal
		jc saveTimeData_isSmallest ;upper byte of current value is smaller
		jmp saveTimeData_largest_upper
	saveTimeData_smallest_lower:
		mov A, [memData0]
		cmp A, [shortestTime]
		jc saveTimeData_isSmallest ;lower byte is smaller
		jmp saveTimeData_largest_upper ;equal or larger
	saveTimeData_isSmallest:
		mov [shortestTime], [memData0]
		mov [shortestTime + 1], [memData0 + 1]
		jmp saveTimeData_end
	;is it the largest value?
	saveTimeData_largest_upper:
		mov A, [memData0 +1]
		cmp A, [longestTime + 1]
		jz saveTimeData_largest_lower ;the upper bytes are equal
		jnc saveTimeData_isLargest ;the upper byte is larger
		jmp saveTimeData_end
	saveTimeData_largest_lower:
		mov A, [memData0]
		cmp A, [longestTime]
		jnc saveTimeData_isLargest ;the lower byte is larger
		jmp saveTimeData_end ;equal or smaller
	saveTimeData_isLargest:
		mov [longestTime], [memData0]
		mov [longestTime + 1], [memData0 + 1]
	;reset temp data
	saveTimeData_end:
	mov [tempTimeInSec], 0
	mov [tempTimeInSec + 1], 0
ret

;JL+
;Calculate Average of Data
;Takes the 5 data points and calculates the average
calculateAverageOfData:
	calculateAverageOfData_isData0_populated:
	cmp [memData0], 0
	jz calculateAverageOfData_isData1_populated
	inc [tempByte] ;there is a time populated here
	;add this time to the total
	mov A, [memData0]
	add [tempVar], A
	mov A, [memData0 + 1]
	adc [tempVar + 1], A
	adc [tempVar + 2], 0
	calculateAverageOfData_isData1_populated:
	cmp [memData1], 0
	jz calculateAverageOfData_isData2_populated
	inc [tempByte] ;there is a time populated here
	;add this time to the total
	mov A, [memData1]
	add [tempVar], A
	mov A, [memData1 + 1]
	adc [tempVar + 1], A
	adc [tempVar + 2], 0
	calculateAverageOfData_isData2_populated:
	cmp [memData2], 0
	jz calculateAverageOfData_isData3_populated
	inc [tempByte] ;there is a time populated here	
	;add this time to the total
	mov A, [memData2]
	add [tempVar], A
	mov A, [memData2 + 1]
	adc [tempVar + 1], A
	adc [tempVar + 2], 0
	calculateAverageOfData_isData3_populated:
	cmp [memData3], 0
	jz calculateAverageOfData_isData4_populated
	inc [tempByte] ;there is a time populated here	
	;add this time to the total
	mov A, [memData3]
	add [tempVar], A
	mov A, [memData3 + 1]
	adc [tempVar + 1], A
	adc [tempVar + 2], 0
	calculateAverageOfData_isData4_populated:
	cmp [memData4], 0
	jz calculateAverageOfData_doCalc
	inc [tempByte] ;there is a time populated here
	;add this time to the total
	mov A, [memData4]
	add [tempVar], A
	mov A, [memData4 + 1]
	adc [tempVar + 1], A
	adc [tempVar + 2], 0
	
	calculateAverageOfData_doCalc:
	;check out section 2.6 of above paper
	mov A, >tempVar2
	push A
	mov A, <tempVar2
	push A
	mov A, tempByte ;2nd parameter byte 0
	push A
	mov A, 0 ;2nd parameter byte 1
	push A
	mov A, 0 ;2nd parameter byte 2
	push A
	mov A, 0 ;2nd parameter byte 3
	push A
	mov A, [tempVar] ;1st parameter
	push A
	mov A, [tempVar + 1]
	push A	
	mov A, [tempVar + 2]
	push A
	mov A, [tempVar + 3]
	push A
	lcall divu_32x32_32
	add SP, 246 ;pop the stack ?
	
	mov [averageTime], [tempVar2]
	mov [averageTime + 1], [tempVar2 + 1]
	
	;reset temp variables
	mov [tempByte], 0
	mov [tempVar], 0
	mov [tempVar + 1], 0
	mov [tempVar + 2], 0
	mov [tempVar + 3], 0
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
	db 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 2, 3, 0
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
	; Two spaces required to cover up the two dots from RUNNING since we don't wipe LCD
	ds "STOPPED!  " 
	db 0x0
RUNNING: 
	ds "RUNNING..."
	db 0x0
OUTPUT:
	ds "- OUTPUT -"
	db 0x0
TEST_STR_A:
	ds "A TEST A!"
	db 0x0
TEST_STR_B:
	ds "B TEST B!"
	db 0x0
SOUND_MODE_idle:
	ds "SOUND MODE :("
	db 0x0
SOUND_MODE_active:
	ds "SOUND MODE :)"
	db 0x0
SOUND_MODE_output:
	ds "SOUND MODE :OUT"
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
MAX_STR:
	ds "MAX: "
	db 0x0
MIN_STR: 
	ds "MIN: "
	db 0x0
AVG_STR:
	ds "AVG: "
	db 0x0
ONE_STR:
	ds "  1: "
	db 0x0
TWO_STR:
	ds "  2: "
	db 0x0
THREE_STR:
	ds "  3: "
	db 0x0
FOUR_STR:
	ds "  4: "
	db 0x0
FIVE_STR:
	ds "  5: "
	db 0x0
MEM_STR_A:
	ds "MEM"
	db 0x0
MEM_STR_B:
	ds "ORY"
	db 0x0
.ENDLITERAL 