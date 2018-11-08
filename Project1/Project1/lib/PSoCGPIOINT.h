/******************************************************************************
*  Generated by PSoC Designer 5.4.3191
******************************************************************************/
#include <m8c.h>
/*
*   PSoCGPIOINT.h
*   Data: 04 June, 2002
*   Copyright (c) Cypress Semiconductor 2015. All Rights Reserved.
*
*  This file is generated by the Device Editor on Application Generation.
*  It contains equates that are useful in writing code relating to GPIO
*  related values.
*  
*  DO NOT EDIT THIS FILE MANUALLY, AS IT IS OVERWRITTEN!!!
*  Edits to this file will not be preserved.
*/
// PushButton address and mask defines
#pragma	ioport	PushButton_Data_ADDR:	0x4
BYTE			PushButton_Data_ADDR;
#pragma	ioport	PushButton_DriveMode_0_ADDR:	0x104
BYTE			PushButton_DriveMode_0_ADDR;
#pragma	ioport	PushButton_DriveMode_1_ADDR:	0x105
BYTE			PushButton_DriveMode_1_ADDR;
#pragma	ioport	PushButton_DriveMode_2_ADDR:	0x7
BYTE			PushButton_DriveMode_2_ADDR;
#pragma	ioport	PushButton_GlobalSelect_ADDR:	0x6
BYTE			PushButton_GlobalSelect_ADDR;
#pragma	ioport	PushButton_IntCtrl_0_ADDR:	0x106
BYTE			PushButton_IntCtrl_0_ADDR;
#pragma	ioport	PushButton_IntCtrl_1_ADDR:	0x107
BYTE			PushButton_IntCtrl_1_ADDR;
#pragma	ioport	PushButton_IntEn_ADDR:	0x5
BYTE			PushButton_IntEn_ADDR;
#define PushButton_MASK 0x1
// PushButton Shadow defines
//   PushButton_DataShadow define
extern unsigned char Port_1_Data_SHADE;
#define PushButton_DataShadow (*(unsigned char*)&Port_1_Data_SHADE)
// AnalogColumn_InputMUX_3 address and mask defines
#pragma	ioport	AnalogColumn_InputMUX_3_Data_ADDR:	0x0
BYTE			AnalogColumn_InputMUX_3_Data_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_3_DriveMode_0_ADDR:	0x100
BYTE			AnalogColumn_InputMUX_3_DriveMode_0_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_3_DriveMode_1_ADDR:	0x101
BYTE			AnalogColumn_InputMUX_3_DriveMode_1_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_3_DriveMode_2_ADDR:	0x3
BYTE			AnalogColumn_InputMUX_3_DriveMode_2_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_3_GlobalSelect_ADDR:	0x2
BYTE			AnalogColumn_InputMUX_3_GlobalSelect_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_3_IntCtrl_0_ADDR:	0x102
BYTE			AnalogColumn_InputMUX_3_IntCtrl_0_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_3_IntCtrl_1_ADDR:	0x103
BYTE			AnalogColumn_InputMUX_3_IntCtrl_1_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_3_IntEn_ADDR:	0x1
BYTE			AnalogColumn_InputMUX_3_IntEn_ADDR;
#define AnalogColumn_InputMUX_3_MASK 0x1
// AnalogColumn_InputMUX_0 address and mask defines
#pragma	ioport	AnalogColumn_InputMUX_0_Data_ADDR:	0x0
BYTE			AnalogColumn_InputMUX_0_Data_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_0_DriveMode_0_ADDR:	0x100
BYTE			AnalogColumn_InputMUX_0_DriveMode_0_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_0_DriveMode_1_ADDR:	0x101
BYTE			AnalogColumn_InputMUX_0_DriveMode_1_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_0_DriveMode_2_ADDR:	0x3
BYTE			AnalogColumn_InputMUX_0_DriveMode_2_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_0_GlobalSelect_ADDR:	0x2
BYTE			AnalogColumn_InputMUX_0_GlobalSelect_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_0_IntCtrl_0_ADDR:	0x102
BYTE			AnalogColumn_InputMUX_0_IntCtrl_0_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_0_IntCtrl_1_ADDR:	0x103
BYTE			AnalogColumn_InputMUX_0_IntCtrl_1_ADDR;
#pragma	ioport	AnalogColumn_InputMUX_0_IntEn_ADDR:	0x1
BYTE			AnalogColumn_InputMUX_0_IntEn_ADDR;
#define AnalogColumn_InputMUX_0_MASK 0x2
// AnalogOutBuf_3 address and mask defines
#pragma	ioport	AnalogOutBuf_3_Data_ADDR:	0x0
BYTE			AnalogOutBuf_3_Data_ADDR;
#pragma	ioport	AnalogOutBuf_3_DriveMode_0_ADDR:	0x100
BYTE			AnalogOutBuf_3_DriveMode_0_ADDR;
#pragma	ioport	AnalogOutBuf_3_DriveMode_1_ADDR:	0x101
BYTE			AnalogOutBuf_3_DriveMode_1_ADDR;
#pragma	ioport	AnalogOutBuf_3_DriveMode_2_ADDR:	0x3
BYTE			AnalogOutBuf_3_DriveMode_2_ADDR;
#pragma	ioport	AnalogOutBuf_3_GlobalSelect_ADDR:	0x2
BYTE			AnalogOutBuf_3_GlobalSelect_ADDR;
#pragma	ioport	AnalogOutBuf_3_IntCtrl_0_ADDR:	0x102
BYTE			AnalogOutBuf_3_IntCtrl_0_ADDR;
#pragma	ioport	AnalogOutBuf_3_IntCtrl_1_ADDR:	0x103
BYTE			AnalogOutBuf_3_IntCtrl_1_ADDR;
#pragma	ioport	AnalogOutBuf_3_IntEn_ADDR:	0x1
BYTE			AnalogOutBuf_3_IntEn_ADDR;
#define AnalogOutBuf_3_MASK 0x4
// AnalogOutBuf_0 address and mask defines
#pragma	ioport	AnalogOutBuf_0_Data_ADDR:	0x0
BYTE			AnalogOutBuf_0_Data_ADDR;
#pragma	ioport	AnalogOutBuf_0_DriveMode_0_ADDR:	0x100
BYTE			AnalogOutBuf_0_DriveMode_0_ADDR;
#pragma	ioport	AnalogOutBuf_0_DriveMode_1_ADDR:	0x101
BYTE			AnalogOutBuf_0_DriveMode_1_ADDR;
#pragma	ioport	AnalogOutBuf_0_DriveMode_2_ADDR:	0x3
BYTE			AnalogOutBuf_0_DriveMode_2_ADDR;
#pragma	ioport	AnalogOutBuf_0_GlobalSelect_ADDR:	0x2
BYTE			AnalogOutBuf_0_GlobalSelect_ADDR;
#pragma	ioport	AnalogOutBuf_0_IntCtrl_0_ADDR:	0x102
BYTE			AnalogOutBuf_0_IntCtrl_0_ADDR;
#pragma	ioport	AnalogOutBuf_0_IntCtrl_1_ADDR:	0x103
BYTE			AnalogOutBuf_0_IntCtrl_1_ADDR;
#pragma	ioport	AnalogOutBuf_0_IntEn_ADDR:	0x1
BYTE			AnalogOutBuf_0_IntEn_ADDR;
#define AnalogOutBuf_0_MASK 0x8
// AnalogOutBuf_2 address and mask defines
#pragma	ioport	AnalogOutBuf_2_Data_ADDR:	0x0
BYTE			AnalogOutBuf_2_Data_ADDR;
#pragma	ioport	AnalogOutBuf_2_DriveMode_0_ADDR:	0x100
BYTE			AnalogOutBuf_2_DriveMode_0_ADDR;
#pragma	ioport	AnalogOutBuf_2_DriveMode_1_ADDR:	0x101
BYTE			AnalogOutBuf_2_DriveMode_1_ADDR;
#pragma	ioport	AnalogOutBuf_2_DriveMode_2_ADDR:	0x3
BYTE			AnalogOutBuf_2_DriveMode_2_ADDR;
#pragma	ioport	AnalogOutBuf_2_GlobalSelect_ADDR:	0x2
BYTE			AnalogOutBuf_2_GlobalSelect_ADDR;
#pragma	ioport	AnalogOutBuf_2_IntCtrl_0_ADDR:	0x102
BYTE			AnalogOutBuf_2_IntCtrl_0_ADDR;
#pragma	ioport	AnalogOutBuf_2_IntCtrl_1_ADDR:	0x103
BYTE			AnalogOutBuf_2_IntCtrl_1_ADDR;
#pragma	ioport	AnalogOutBuf_2_IntEn_ADDR:	0x1
BYTE			AnalogOutBuf_2_IntEn_ADDR;
#define AnalogOutBuf_2_MASK 0x10
// AnalogOutBuf_1 address and mask defines
#pragma	ioport	AnalogOutBuf_1_Data_ADDR:	0x0
BYTE			AnalogOutBuf_1_Data_ADDR;
#pragma	ioport	AnalogOutBuf_1_DriveMode_0_ADDR:	0x100
BYTE			AnalogOutBuf_1_DriveMode_0_ADDR;
#pragma	ioport	AnalogOutBuf_1_DriveMode_1_ADDR:	0x101
BYTE			AnalogOutBuf_1_DriveMode_1_ADDR;
#pragma	ioport	AnalogOutBuf_1_DriveMode_2_ADDR:	0x3
BYTE			AnalogOutBuf_1_DriveMode_2_ADDR;
#pragma	ioport	AnalogOutBuf_1_GlobalSelect_ADDR:	0x2
BYTE			AnalogOutBuf_1_GlobalSelect_ADDR;
#pragma	ioport	AnalogOutBuf_1_IntCtrl_0_ADDR:	0x102
BYTE			AnalogOutBuf_1_IntCtrl_0_ADDR;
#pragma	ioport	AnalogOutBuf_1_IntCtrl_1_ADDR:	0x103
BYTE			AnalogOutBuf_1_IntCtrl_1_ADDR;
#pragma	ioport	AnalogOutBuf_1_IntEn_ADDR:	0x1
BYTE			AnalogOutBuf_1_IntEn_ADDR;
#define AnalogOutBuf_1_MASK 0x20
// LCDD4 address and mask defines
#pragma	ioport	LCDD4_Data_ADDR:	0x8
BYTE			LCDD4_Data_ADDR;
#pragma	ioport	LCDD4_DriveMode_0_ADDR:	0x108
BYTE			LCDD4_DriveMode_0_ADDR;
#pragma	ioport	LCDD4_DriveMode_1_ADDR:	0x109
BYTE			LCDD4_DriveMode_1_ADDR;
#pragma	ioport	LCDD4_DriveMode_2_ADDR:	0xb
BYTE			LCDD4_DriveMode_2_ADDR;
#pragma	ioport	LCDD4_GlobalSelect_ADDR:	0xa
BYTE			LCDD4_GlobalSelect_ADDR;
#pragma	ioport	LCDD4_IntCtrl_0_ADDR:	0x10a
BYTE			LCDD4_IntCtrl_0_ADDR;
#pragma	ioport	LCDD4_IntCtrl_1_ADDR:	0x10b
BYTE			LCDD4_IntCtrl_1_ADDR;
#pragma	ioport	LCDD4_IntEn_ADDR:	0x9
BYTE			LCDD4_IntEn_ADDR;
#define LCDD4_MASK 0x1
// LCDD4 Shadow defines
//   LCDD4_DataShadow define
extern BYTE Port_2_Data_SHADE;
#define LCDD4_DataShadow (*(unsigned char*)&Port_2_Data_SHADE)
//   LCDD4_DriveMode_0Shadow define
extern BYTE Port_2_DriveMode_0_SHADE;
#define LCDD4_DriveMode_0Shadow (*(unsigned char*)&Port_2_DriveMode_0_SHADE)
//   LCDD4_DriveMode_1Shadow define
extern BYTE Port_2_DriveMode_1_SHADE;
#define LCDD4_DriveMode_1Shadow (*(unsigned char*)&Port_2_DriveMode_1_SHADE)
// LCDD5 address and mask defines
#pragma	ioport	LCDD5_Data_ADDR:	0x8
BYTE			LCDD5_Data_ADDR;
#pragma	ioport	LCDD5_DriveMode_0_ADDR:	0x108
BYTE			LCDD5_DriveMode_0_ADDR;
#pragma	ioport	LCDD5_DriveMode_1_ADDR:	0x109
BYTE			LCDD5_DriveMode_1_ADDR;
#pragma	ioport	LCDD5_DriveMode_2_ADDR:	0xb
BYTE			LCDD5_DriveMode_2_ADDR;
#pragma	ioport	LCDD5_GlobalSelect_ADDR:	0xa
BYTE			LCDD5_GlobalSelect_ADDR;
#pragma	ioport	LCDD5_IntCtrl_0_ADDR:	0x10a
BYTE			LCDD5_IntCtrl_0_ADDR;
#pragma	ioport	LCDD5_IntCtrl_1_ADDR:	0x10b
BYTE			LCDD5_IntCtrl_1_ADDR;
#pragma	ioport	LCDD5_IntEn_ADDR:	0x9
BYTE			LCDD5_IntEn_ADDR;
#define LCDD5_MASK 0x2
// LCDD5 Shadow defines
//   LCDD5_DataShadow define
extern BYTE Port_2_Data_SHADE;
#define LCDD5_DataShadow (*(unsigned char*)&Port_2_Data_SHADE)
//   LCDD5_DriveMode_0Shadow define
extern BYTE Port_2_DriveMode_0_SHADE;
#define LCDD5_DriveMode_0Shadow (*(unsigned char*)&Port_2_DriveMode_0_SHADE)
//   LCDD5_DriveMode_1Shadow define
extern BYTE Port_2_DriveMode_1_SHADE;
#define LCDD5_DriveMode_1Shadow (*(unsigned char*)&Port_2_DriveMode_1_SHADE)
// LCDD6 address and mask defines
#pragma	ioport	LCDD6_Data_ADDR:	0x8
BYTE			LCDD6_Data_ADDR;
#pragma	ioport	LCDD6_DriveMode_0_ADDR:	0x108
BYTE			LCDD6_DriveMode_0_ADDR;
#pragma	ioport	LCDD6_DriveMode_1_ADDR:	0x109
BYTE			LCDD6_DriveMode_1_ADDR;
#pragma	ioport	LCDD6_DriveMode_2_ADDR:	0xb
BYTE			LCDD6_DriveMode_2_ADDR;
#pragma	ioport	LCDD6_GlobalSelect_ADDR:	0xa
BYTE			LCDD6_GlobalSelect_ADDR;
#pragma	ioport	LCDD6_IntCtrl_0_ADDR:	0x10a
BYTE			LCDD6_IntCtrl_0_ADDR;
#pragma	ioport	LCDD6_IntCtrl_1_ADDR:	0x10b
BYTE			LCDD6_IntCtrl_1_ADDR;
#pragma	ioport	LCDD6_IntEn_ADDR:	0x9
BYTE			LCDD6_IntEn_ADDR;
#define LCDD6_MASK 0x4
// LCDD6 Shadow defines
//   LCDD6_DataShadow define
extern BYTE Port_2_Data_SHADE;
#define LCDD6_DataShadow (*(unsigned char*)&Port_2_Data_SHADE)
//   LCDD6_DriveMode_0Shadow define
extern BYTE Port_2_DriveMode_0_SHADE;
#define LCDD6_DriveMode_0Shadow (*(unsigned char*)&Port_2_DriveMode_0_SHADE)
//   LCDD6_DriveMode_1Shadow define
extern BYTE Port_2_DriveMode_1_SHADE;
#define LCDD6_DriveMode_1Shadow (*(unsigned char*)&Port_2_DriveMode_1_SHADE)
// LCDD7 address and mask defines
#pragma	ioport	LCDD7_Data_ADDR:	0x8
BYTE			LCDD7_Data_ADDR;
#pragma	ioport	LCDD7_DriveMode_0_ADDR:	0x108
BYTE			LCDD7_DriveMode_0_ADDR;
#pragma	ioport	LCDD7_DriveMode_1_ADDR:	0x109
BYTE			LCDD7_DriveMode_1_ADDR;
#pragma	ioport	LCDD7_DriveMode_2_ADDR:	0xb
BYTE			LCDD7_DriveMode_2_ADDR;
#pragma	ioport	LCDD7_GlobalSelect_ADDR:	0xa
BYTE			LCDD7_GlobalSelect_ADDR;
#pragma	ioport	LCDD7_IntCtrl_0_ADDR:	0x10a
BYTE			LCDD7_IntCtrl_0_ADDR;
#pragma	ioport	LCDD7_IntCtrl_1_ADDR:	0x10b
BYTE			LCDD7_IntCtrl_1_ADDR;
#pragma	ioport	LCDD7_IntEn_ADDR:	0x9
BYTE			LCDD7_IntEn_ADDR;
#define LCDD7_MASK 0x8
// LCDD7 Shadow defines
//   LCDD7_DataShadow define
extern BYTE Port_2_Data_SHADE;
#define LCDD7_DataShadow (*(unsigned char*)&Port_2_Data_SHADE)
//   LCDD7_DriveMode_0Shadow define
extern BYTE Port_2_DriveMode_0_SHADE;
#define LCDD7_DriveMode_0Shadow (*(unsigned char*)&Port_2_DriveMode_0_SHADE)
//   LCDD7_DriveMode_1Shadow define
extern BYTE Port_2_DriveMode_1_SHADE;
#define LCDD7_DriveMode_1Shadow (*(unsigned char*)&Port_2_DriveMode_1_SHADE)
// LCDE address and mask defines
#pragma	ioport	LCDE_Data_ADDR:	0x8
BYTE			LCDE_Data_ADDR;
#pragma	ioport	LCDE_DriveMode_0_ADDR:	0x108
BYTE			LCDE_DriveMode_0_ADDR;
#pragma	ioport	LCDE_DriveMode_1_ADDR:	0x109
BYTE			LCDE_DriveMode_1_ADDR;
#pragma	ioport	LCDE_DriveMode_2_ADDR:	0xb
BYTE			LCDE_DriveMode_2_ADDR;
#pragma	ioport	LCDE_GlobalSelect_ADDR:	0xa
BYTE			LCDE_GlobalSelect_ADDR;
#pragma	ioport	LCDE_IntCtrl_0_ADDR:	0x10a
BYTE			LCDE_IntCtrl_0_ADDR;
#pragma	ioport	LCDE_IntCtrl_1_ADDR:	0x10b
BYTE			LCDE_IntCtrl_1_ADDR;
#pragma	ioport	LCDE_IntEn_ADDR:	0x9
BYTE			LCDE_IntEn_ADDR;
#define LCDE_MASK 0x10
// LCDE Shadow defines
//   LCDE_DataShadow define
extern BYTE Port_2_Data_SHADE;
#define LCDE_DataShadow (*(unsigned char*)&Port_2_Data_SHADE)
//   LCDE_DriveMode_0Shadow define
extern BYTE Port_2_DriveMode_0_SHADE;
#define LCDE_DriveMode_0Shadow (*(unsigned char*)&Port_2_DriveMode_0_SHADE)
//   LCDE_DriveMode_1Shadow define
extern BYTE Port_2_DriveMode_1_SHADE;
#define LCDE_DriveMode_1Shadow (*(unsigned char*)&Port_2_DriveMode_1_SHADE)
// LCDRS address and mask defines
#pragma	ioport	LCDRS_Data_ADDR:	0x8
BYTE			LCDRS_Data_ADDR;
#pragma	ioport	LCDRS_DriveMode_0_ADDR:	0x108
BYTE			LCDRS_DriveMode_0_ADDR;
#pragma	ioport	LCDRS_DriveMode_1_ADDR:	0x109
BYTE			LCDRS_DriveMode_1_ADDR;
#pragma	ioport	LCDRS_DriveMode_2_ADDR:	0xb
BYTE			LCDRS_DriveMode_2_ADDR;
#pragma	ioport	LCDRS_GlobalSelect_ADDR:	0xa
BYTE			LCDRS_GlobalSelect_ADDR;
#pragma	ioport	LCDRS_IntCtrl_0_ADDR:	0x10a
BYTE			LCDRS_IntCtrl_0_ADDR;
#pragma	ioport	LCDRS_IntCtrl_1_ADDR:	0x10b
BYTE			LCDRS_IntCtrl_1_ADDR;
#pragma	ioport	LCDRS_IntEn_ADDR:	0x9
BYTE			LCDRS_IntEn_ADDR;
#define LCDRS_MASK 0x20
// LCDRS Shadow defines
//   LCDRS_DataShadow define
extern BYTE Port_2_Data_SHADE;
#define LCDRS_DataShadow (*(unsigned char*)&Port_2_Data_SHADE)
//   LCDRS_DriveMode_0Shadow define
extern BYTE Port_2_DriveMode_0_SHADE;
#define LCDRS_DriveMode_0Shadow (*(unsigned char*)&Port_2_DriveMode_0_SHADE)
//   LCDRS_DriveMode_1Shadow define
extern BYTE Port_2_DriveMode_1_SHADE;
#define LCDRS_DriveMode_1Shadow (*(unsigned char*)&Port_2_DriveMode_1_SHADE)
// LCDRW address and mask defines
#pragma	ioport	LCDRW_Data_ADDR:	0x8
BYTE			LCDRW_Data_ADDR;
#pragma	ioport	LCDRW_DriveMode_0_ADDR:	0x108
BYTE			LCDRW_DriveMode_0_ADDR;
#pragma	ioport	LCDRW_DriveMode_1_ADDR:	0x109
BYTE			LCDRW_DriveMode_1_ADDR;
#pragma	ioport	LCDRW_DriveMode_2_ADDR:	0xb
BYTE			LCDRW_DriveMode_2_ADDR;
#pragma	ioport	LCDRW_GlobalSelect_ADDR:	0xa
BYTE			LCDRW_GlobalSelect_ADDR;
#pragma	ioport	LCDRW_IntCtrl_0_ADDR:	0x10a
BYTE			LCDRW_IntCtrl_0_ADDR;
#pragma	ioport	LCDRW_IntCtrl_1_ADDR:	0x10b
BYTE			LCDRW_IntCtrl_1_ADDR;
#pragma	ioport	LCDRW_IntEn_ADDR:	0x9
BYTE			LCDRW_IntEn_ADDR;
#define LCDRW_MASK 0x40
// LCDRW Shadow defines
//   LCDRW_DataShadow define
extern BYTE Port_2_Data_SHADE;
#define LCDRW_DataShadow (*(unsigned char*)&Port_2_Data_SHADE)
//   LCDRW_DriveMode_0Shadow define
extern BYTE Port_2_DriveMode_0_SHADE;
#define LCDRW_DriveMode_0Shadow (*(unsigned char*)&Port_2_DriveMode_0_SHADE)
//   LCDRW_DriveMode_1Shadow define
extern BYTE Port_2_DriveMode_1_SHADE;
#define LCDRW_DriveMode_1Shadow (*(unsigned char*)&Port_2_DriveMode_1_SHADE)
