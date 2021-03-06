;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME: PushButtonTimer.asm
;;   Version: 2.6, Updated on 2015/3/4 at 22:27:47
;;  Generated by PSoC Designer 5.4.3191
;;
;;  DESCRIPTION: Timer16 User Module software implementation file
;;
;;  NOTE: User Module APIs conform to the fastcall16 convention for marshalling
;;        arguments and observe the associated "Registers are volatile" policy.
;;        This means it is the caller's responsibility to preserve any values
;;        in the X and A registers that are still needed after the API functions
;;        returns. For Large Memory Model devices it is also the caller's 
;;        responsibility to perserve any value in the CUR_PP, IDX_PP, MVR_PP and 
;;        MVW_PP registers. Even though some of these registers may not be modified
;;        now, there is no guarantee that will remain the case in future releases.
;;-----------------------------------------------------------------------------
;;  Copyright (c) Cypress Semiconductor 2015. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************

include "m8c.inc"
include "memory.inc"
include "PushButtonTimer.inc"

;-----------------------------------------------
;  Global Symbols
;-----------------------------------------------
export  PushButtonTimer_EnableInt
export _PushButtonTimer_EnableInt
export  PushButtonTimer_DisableInt
export _PushButtonTimer_DisableInt
export  PushButtonTimer_Start
export _PushButtonTimer_Start
export  PushButtonTimer_Stop
export _PushButtonTimer_Stop
export  PushButtonTimer_WritePeriod
export _PushButtonTimer_WritePeriod
export  PushButtonTimer_WriteCompareValue
export _PushButtonTimer_WriteCompareValue
export  PushButtonTimer_wReadCompareValue
export _PushButtonTimer_wReadCompareValue
export  PushButtonTimer_wReadTimer
export _PushButtonTimer_wReadTimer
export  PushButtonTimer_wReadTimerSaveCV
export _PushButtonTimer_wReadTimerSaveCV

; The following functions are deprecated and subject to omission in future releases
;
export  wPushButtonTimer_ReadCompareValue  ; deprecated
export _wPushButtonTimer_ReadCompareValue  ; deprecated
export  wPushButtonTimer_ReadTimer         ; deprecated
export _wPushButtonTimer_ReadTimer         ; deprecated
export  wPushButtonTimer_ReadTimerSaveCV   ; deprecated
export _wPushButtonTimer_ReadTimerSaveCV   ; deprecated

export  wPushButtonTimer_ReadCounter       ; obsolete
export _wPushButtonTimer_ReadCounter       ; obsolete
export  wPushButtonTimer_CaptureCounter    ; obsolete
export _wPushButtonTimer_CaptureCounter    ; obsolete


AREA project1_RAM (RAM,REL)

;-----------------------------------------------
;  Constant Definitions
;-----------------------------------------------


;-----------------------------------------------
; Variable Allocation
;-----------------------------------------------


AREA UserModules (ROM, REL)

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PushButtonTimer_EnableInt
;
;  DESCRIPTION:
;     Enables this timer's interrupt by setting the interrupt enable mask bit
;     associated with this User Module. This function has no effect until and
;     unless the global interrupts are enabled (for example by using the
;     macro M8C_EnableGInt).
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    None.
;  RETURNS:      Nothing.
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 PushButtonTimer_EnableInt:
_PushButtonTimer_EnableInt:
   RAM_PROLOGUE RAM_USE_CLASS_1
   PushButtonTimer_EnableInt_M
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PushButtonTimer_DisableInt
;
;  DESCRIPTION:
;     Disables this timer's interrupt by clearing the interrupt enable
;     mask bit associated with this User Module.
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    None
;  RETURNS:      Nothing
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 PushButtonTimer_DisableInt:
_PushButtonTimer_DisableInt:
   RAM_PROLOGUE RAM_USE_CLASS_1
   PushButtonTimer_DisableInt_M
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PushButtonTimer_Start
;
;  DESCRIPTION:
;     Sets the start bit in the Control register of this user module.  The
;     timer will begin counting on the next input clock.
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    None
;  RETURNS:      Nothing
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 PushButtonTimer_Start:
_PushButtonTimer_Start:
   RAM_PROLOGUE RAM_USE_CLASS_1
   PushButtonTimer_Start_M
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PushButtonTimer_Stop
;
;  DESCRIPTION:
;     Disables timer operation by clearing the start bit in the Control
;     register of the LSB block.
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    None
;  RETURNS:      Nothing
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 PushButtonTimer_Stop:
_PushButtonTimer_Stop:
   RAM_PROLOGUE RAM_USE_CLASS_1
   PushButtonTimer_Stop_M
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PushButtonTimer_WritePeriod
;
;  DESCRIPTION:
;     Write the 16-bit period value into the Period register (DR1). If the
;     Timer user module is stopped, then this value will also be latched
;     into the Count register (DR0).
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: fastcall16 WORD wPeriodValue (LSB in A, MSB in X)
;  RETURNS:   Nothing
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 PushButtonTimer_WritePeriod:
_PushButtonTimer_WritePeriod:
   RAM_PROLOGUE RAM_USE_CLASS_1
   mov   reg[PushButtonTimer_PERIOD_LSB_REG], A
   mov   A, X
   mov   reg[PushButtonTimer_PERIOD_MSB_REG], A
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PushButtonTimer_WriteCompareValue
;
;  DESCRIPTION:
;     Writes compare value into the Compare register (DR2).
;
;     NOTE! The Timer user module must be STOPPED in order to write the
;           Compare register. (Call PushButtonTimer_Stop to disable).
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    fastcall16 WORD wCompareValue (LSB in A, MSB in X)
;  RETURNS:      Nothing
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 PushButtonTimer_WriteCompareValue:
_PushButtonTimer_WriteCompareValue:
   RAM_PROLOGUE RAM_USE_CLASS_1
   mov   reg[PushButtonTimer_COMPARE_LSB_REG], A
   mov   A, X
   mov   reg[PushButtonTimer_COMPARE_MSB_REG], A
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PushButtonTimer_wReadCompareValue
;
;  DESCRIPTION:
;     Reads the Compare registers.
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    None
;  RETURNS:      fastcall16 WORD wCompareValue (value of DR2 in the X & A registers)
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 PushButtonTimer_wReadCompareValue:
_PushButtonTimer_wReadCompareValue:
 wPushButtonTimer_ReadCompareValue:                ; this name deprecated
_wPushButtonTimer_ReadCompareValue:                ; this name deprecated
   RAM_PROLOGUE RAM_USE_CLASS_1
   mov   A, reg[PushButtonTimer_COMPARE_MSB_REG]
   mov   X, A
   mov   A, reg[PushButtonTimer_COMPARE_LSB_REG]
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PushButtonTimer_wReadTimerSaveCV
;
;  DESCRIPTION:
;     Returns the value in the Count register (DR0), preserving the
;     value in the compare register (DR2).
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: None
;  RETURNS:   fastcall16 WORD wCount (value of DR0 in the X & A registers)
;  SIDE EFFECTS:
;     1) May cause an interrupt, if interrupt on Compare is enabled.
;     2) If enabled, Global interrupts are momentarily disabled.
;     3) The user module is stopped momentarily while the compare value is
;        restored.  This may cause the Count register to miss one or more
;        counts depending on the input clock speed.
;     4) The A and X registers may be modified by this or future implementations
;        of this function.  The same is true for all RAM page pointer registers in
;        the Large Memory Model.  When necessary, it is the calling function's
;        responsibility to perserve their values across calls to fastcall16 
;        functions.
;
;  THEORY of OPERATION:
;     1) Read and save the Compare register.
;     2) Read the Count register, causing its data to be latched into
;        the Compare register.
;     3) Read and save the Counter value, now in the Compare register,
;        to the buffer.
;     4) Disable global interrupts
;     5) Halt the timer
;     6) Restore the Compare register values
;     7) Start the Timer again
;     8) Restore global interrupt state
;
 PushButtonTimer_wReadTimerSaveCV:
_PushButtonTimer_wReadTimerSaveCV:
 wPushButtonTimer_ReadTimerSaveCV:               ; this name deprecated
_wPushButtonTimer_ReadTimerSaveCV:               ; this name deprecated
 wPushButtonTimer_ReadCounter:                   ; this name deprecated
_wPushButtonTimer_ReadCounter:                   ; this name deprecated

CpuFlags:      equ   0
wCount_MSB:    equ   1
wCount_LSB:    equ   2

   RAM_PROLOGUE RAM_USE_CLASS_2
   mov   X, SP                                   ; X <- stack frame pointer
   add   SP, 3                                   ; Reserve space for flags, count
   mov   A, reg[PushButtonTimer_CONTROL_LSB_REG] ; save the Control register
   push  A
   mov   A, reg[PushButtonTimer_COMPARE_LSB_REG] ; save the Compare register
   push  A
   mov   A, reg[PushButtonTimer_COMPARE_MSB_REG]
   push  A
   mov   A, reg[PushButtonTimer_COUNTER_LSB_REG] ; synchronous copy DR2 <- DR0
                                                 ; This may cause an interrupt!
   mov   A, reg[PushButtonTimer_COMPARE_MSB_REG] ; Now grab DR2 (DR0) and save
   mov   [X+wCount_MSB], A
   mov   A, reg[PushButtonTimer_COMPARE_LSB_REG]
   mov   [X+wCount_LSB], A
   mov   A, 0                                    ; Guess the global interrupt state
   tst   reg[CPU_F], FLAG_GLOBAL_IE              ; Currently Disabled?
   jz    .SetupStatusFlag                        ;   Yes, guess was correct
   mov   A, FLAG_GLOBAL_IE                       ;    No, modify our guess
.SetupStatusFlag:                                ; and ...
   mov   [X+CpuFlags], A                         ;   StackFrame[0] <- Flag Reg image
   M8C_DisableGInt                               ; Disable interrupts globally
   PushButtonTimer_Stop_M                        ; Disable (stop) the timer
   pop   A                                       ; Restore the Compare register
   mov   reg[PushButtonTimer_COMPARE_MSB_REG], A
   pop   A
   mov   reg[PushButtonTimer_COMPARE_LSB_REG], A
   pop   A                                       ; restore start state of the timer
   mov   reg[PushButtonTimer_CONTROL_LSB_REG], A
   pop   A                                       ; Return result stored in stack frame
   pop   X
   RAM_EPILOGUE RAM_USE_CLASS_2
   reti                                          ; Flag Reg <- StackFrame[0]

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PushButtonTimer_wReadTimer
;
;  DESCRIPTION:
;     Performs a software capture of the Count register.  A synchronous
;     read of the Count register is performed.  The timer is NOT stopped.
;
;     WARNING - this will cause loss of data in the Compare register.
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    None
;  RETURNS:      fastcall16 WORD wCount, (value of DR0 in the X & A registers)
;  SIDE EFFECTS:
;    May cause an interrupt.
;
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
;  THEORY of OPERATION:
;     1) Read the Count register - this causes the count value to be
;        latched into the Compare registers.
;     2) Read and return the Count register values from the Compare
;        registers into the return buffer.
;
 PushButtonTimer_wReadTimer:
_PushButtonTimer_wReadTimer:
 wPushButtonTimer_ReadTimer:                     ; this name deprecated
_wPushButtonTimer_ReadTimer:                     ; this name deprecated
 wPushButtonTimer_CaptureCounter:                ; this name deprecated
_wPushButtonTimer_CaptureCounter:                ; this name deprecated

   RAM_PROLOGUE RAM_USE_CLASS_1
   mov   A, reg[PushButtonTimer_COUNTER_LSB_REG] ; synchronous copy DR2 <- DR0
                                                 ; This may cause an interrupt!

   mov   A, reg[PushButtonTimer_COMPARE_MSB_REG] ; Return DR2 (actually DR0)
   mov   X, A
   mov   A, reg[PushButtonTimer_COMPARE_LSB_REG]
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION

; End of File PushButtonTimer.asm
