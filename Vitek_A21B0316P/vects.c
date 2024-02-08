/***********************************************************************/
/*                                                                     */
/*  FILE        :vects.c                                               */
/*  DATE        :Mon, Jul 18, 2022                                     */
/*  DESCRIPTION :Vector Table                                          */
/*  CPU TYPE    :H8S/Other                                             */
/*                                                                     */
/*  This file is generated by KPIT GNU Project Generator.              */
/*                                                                     */
/***********************************************************************/
     



#include    "inthandler.h"
typedef  void (*fp) (void);
extern void start(void);
extern void stack (void);

#define VECT_SECT          __attribute__ ((section (".vects")))
const void *HardwareVectors[] VECT_SECT  = {
//;<<VECTOR DATA START (POWER ON RESET)>>
//;0 Power On Reset PC
start,
//;<<VECTOR DATA END (POWER ON RESET)>>
//vector 1 manual reset
//;<<VECTOR DATA START (MANUAL RESET)>>
//;2 Manual Reset PC
INT_Manual_Reset,
//;<<VECTOR DATA END (MANUAL RESET)>>
};
