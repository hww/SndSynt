/* File: sdram.h */

#ifndef __SDRAM_H
#define __SDRAM_H

#include "sdramdrv.h"

#ifdef __cplusplus
extern "C" {
#endif

// РЕГИСТРЫ КОНТРОЛЛЕРА SDRAM

#define SDRAM_PRECHARGE		$FF70		//	Пречердж 
#define SDRAM_ACTIVE 		$FF71		//	Активизация строки
#define SDRAM_RDCOL			$FF72		//	Столбец цикла чтение с автопречерчем
#define SDRAM_WRCOL			$FF73		//	Cтобец цикла записи с автопречерчем
#define SDRAM_WRRDDAT		$FF74		//	Запись/Чтение данных
#define SDRAM_MODE			$FF75		//	Установка режима 
#define SDRAM_RFSH			$FF76		//	Регенерация
#define SDRAM_SRFSH			$FF77		//	Саморегенерация 
#define SDRAM_PRECHARGEALL 	$FF78		//	Пречердж всех банков 
#define SDRAM_RDCOLAP 		$FF7A		//	Столбец цикла чтение 
#define SDRAM_WRCOLAP 		$FF7B		//	Cтобец цикла записи 

// КОМАНДЫ КОНТРОЛЛЕРА SDRAM

#define CMD_PRECHARGE_ALL	move	#0x1000,X:SDRAM_PRECHARGEALL
#define CMD_SET_MODE 		move	#0x0880,X:SDRAM_MODE
#define CMD_AUTO_RFSH 		move	#0x0000,X:SDRAM_RFSH
#define CMD_SELF_RFSH 		move	#0x0000,X:SDRAM_SRFSH
#define CMD_GET_DATA(reg)	move	X:SDRAM_WRRDDAT,reg
#define CMD_SET_DATA(reg)	move	reg,X:SDRAM_WRRDDAT
#define CMD_ACTIVE(reg)		move	reg,X:SDRAM_ACTIVE
#define CMD_WRCOLAP(reg)	move	reg,X:SDRAM_WRCOLAP
#define CMD_RDCOLAP(reg)	move	reg,X:SDRAM_RDCOLAP
#define CMD_WRCOL(reg)		move	reg,X:SDRAM_WRCOL
#define CMD_RDCOL(reg)		move	reg,X:SDRAM_RDCOL

// ЦЕПОЧКИ КОМАНД КОНТРОЛЛЕРА SDRAM

#define SDRAM_POWER_ON		CMD_PRECHARGEALL	\
							CMD_AUTO_RFSH		\
							CMD_AUTO_RFSH		\
							CMD_SET_MODE		\
							CMD_SELF_RFSH
							
#ifdef __cplusplus
}
#endif

#endif
