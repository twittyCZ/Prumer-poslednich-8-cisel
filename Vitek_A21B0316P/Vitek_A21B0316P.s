	.h8300s

               .equ syscall,0x1FF00               ; simulated IO area
               .equ PUTS,0x0114                   ; kod PUTS
               .equ GETS,0x0113                   ; kod GETS

; ------ datovy segment ----------------------------

               .data

pInput:			.long input
pNumber:		.long number
pLine:			.long line ;od��dkov�n�
pBin:			.long bin
pOutput:		.long output
pCount:			.long count
pCountNumber:	.long countNumber
pOutputNumeral:	.long outputNumeral

input:			.asciz	"Put a number: "
number:			.space 	50
line:			.asciz	"\n\r"
output:			.space	20
outputNumeral:	.space 	7 
count:			.space	30
countNumber:	.space 	30
				.space 300
bin:
				.space 300
                       
stck:                                       

; ------ kodovy segment ----------------------------

               .text
               .global _start

_start:  	    mov.l #stck,ER7

next:          		
			   
			   mov.w #PUTS,R0                 
               mov.l #pInput,ER1              
			   jsr @syscall	

               mov.w #GETS,R0               
               mov.l #pNumber,ER1          
               jsr @syscall		  
	
			   mov	#number,ER6
			   xor R4, R4  
			   xor R2, R2
			   xor	ER1, ER1
			   mov #10, E2
			   jsr	asciiBin ;prevede ascii cislo do binarniho a ulozi do zasobniku
			   
			   
			   mov	@countNumber, R3 ;kontrola, zda v zasobniku je aspon 8 cisel
			   cmp	#7, R3 
			   bls	next:16
			   
			   mov #0, ER1
			   mov #bin, ER6

			   
			   xor ER1, ER1
			   xor ER3, ER3
			   xor ER4, ER4
			   jsr sumOfNumbers ; se�te zadan� ��sla a ulo�� je do registru ER1
			   jsr average ; spo��t� pr�m�r zadan�ch ��sel a ulo�� je do R1
			   jsr binToAscii ;bin�rn� hodnotu �evede do ascii podoby
			   mov #outputNumeral, ER3
			   jsr averageToConsole ;vyp�e pr�m�r do konzole 
			   
			   mov.w #PUTS,R0               
               mov.l #pLine,ER1 ;vyp�e mezeru   
               jsr @syscall
		
			   jsr clearRegisters
			   
			   jmp next
			   
clearRegisters:	
				xor ER0, ER0
				xor ER1, ER1
				xor ER2, ER2
				xor ER3, ER3
				xor ER4, ER4
				xor ER6, ER6
				rts
							   
 				 
				
asciiBin:		;��slo ulo�� do ER4
				mov	 @ER6, R2L 
 				cmp	 #0x0A,R2L  ;0A je konec na��t�n� v z�sobn�ku
 				beq saveToBin:16 
 				add #-'0',R2L ;ode�te druhou pozici v R2 registru
 				mulxu E2,ER4 

 				add R2,R4
 				inc #1,ER6
 				jmp asciiBin	

return:			rts			

saveToBin:		
				mov	@count, R3 	;pomoc� ��sla count si najednu na pozici, kam chci ��slo ulo�it
				cmp #8, R3 
				beq deleteCount:16 ;dojeli jsme na konec osmi �lenn� �ady, je pot�eba ji vynulovat
									; a za��t p�episovat op�t prvn� �len
				mov #bin, ER6 				
				jsr findPlace
				xor E3, E3
				
				add	#1, R3
				mov	R3, @count; aktualizuje ukazatel na m�sto v �ad� 8 ��sel
				
				mov	R4, @ER6 ;p�id� vkl�dan� ��slo do z�sobn�ku na dan� m�sto
				add	#2, ER6
				
				cmp #8, R3 
				beq updateCountNumber:16 ;nastavim si dalsi promennou countNumber, ktera rika ze uz mame 8 cisel
								  ;tudiz muzeme vypisovat prumer
				
				rts				
				
deleteCount:	;count ma hodnoty od 0 do 8, urcuje pozici kam se ma v zasobniku ukladat ��slo
				mov #0, R3 
				mov R3, @count
				
				jmp saveToBin		
				
updateCountNumber:		
				mov R3, @countNumber
				rts

findPlace:		cmp	R3, E3
				beq return:16
				add #2, ER6
				add #1, E3
				jmp findPlace			
						
						
sumOfNumbers:	; secte cisla a ulo�� je do ER1
				cmp #8, ER3 ;aby bylo 8 pr�chod�
				beq return:16
				mov @ER6, E1 ; v pam�ti ER6 je adrea z�sobn�ku 
				add E1, R1
				xor E1, E1
				add #2, ER6 ;posuneme se v z�sobn�ku
				add #1, ER3 ;jeden pr�chod
				jmp sumOfNumbers;
				
average:			;vezme sou�et ��sel v registru ER1 a vyd�l� je osmi 
		 
				
			divxu  R3, ER1;vyd�l� sou�et ��sel osmi, osmi�ka je zde z p�edchoz� operace
				; v R1 je v�sledek a v E1 je zbytek
			  mov #10, R2 ;abychom pak d�lili 10
			  xor ER3, ER3
			  xor ER5, ER5
			  mov E2, R3 
			  mov R1, R3
			  mov #output, ER6
			  jmp return
		  
binToAscii:     ;vypisujeme po cislici
				; v�sledek je v ER3, E- zbytek, R - v�sledek
				divxu R2, ER3 ; d�l�me 10, zaj�m� n�s zbytek
				add #'0', E3
				mov E3, @ER6 ;v ER6 je adresa z�sobn�ku, kam chceme d�t v�sledek
				xor E3, E3
				
				add #1, E5
				cmp #0, R3
				beq return:16
				add #2, ER6
				
				jmp binToAscii

averageToConsole:
				cmp #0, E5 
				beq return:16
				
				mov @ER6, R5
				mov R5L, @outputNumeral
				
				mov.w #PUTS,R0                 
               	mov.l #pOutputNumeral,ER1              
               	jsr @syscall
										
				dec #1, E5
				dec #2, ER6
				jmp averageToConsole				
			