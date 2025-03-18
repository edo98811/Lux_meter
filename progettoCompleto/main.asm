;
; Digital_voltmeter_calibrated.asm
;
; Created: 21/12/2020 08:55:04
; Author : carlo
;


;
;
; Definizione dei registri utilizzati
.DEF	mp 		= R16		; registro di lavoro (generico)
.DEF	mp1 		= R17       	; registro di lavoro secondario (generico)
.DEF	var_check 	= R18		; var_check è la variabile decrementata dalla subroutine di risposta ad interrupt
					; quando arriva a 0 vieve attivato un campionamento dell'ADC
;
.EQU	T_CHECK 	= 50		; costante che definisce l'intervallo di campionamento della tensione in multipli di 10ms
.EQU	TABLEN		= 256		; lunghezza della tabella espressa in gruppi di 4 byte (non usato in questa versione)
;
;	crea tabella nella flash. In questo caso la tabella ha 256 righe consistenti ognuna in 4 byte
;	valori possibili (da 0 a 255) della conversione su 8 bit. La prima cella rappresenta l'uscita dell'ADC e non è utilizzata
;   la seconda la cifra delle centinaia da mandare al display; la terza la cifra delle decine; la quarta la cifra delle unità.
;   in questa versione viene visualizzata l'uscita grezza dell'ADC. 
; Cambiando la LUT si può visualizzare la tensione, la temperatura o l'intensità luminosa.
;
.CSEG ;la tabella che segue va scritta nella memoria flash
.ORG 	0x1FFF				; definisce l'inizio della tabella che sarà scritta in flash
; 
tabella:
.db	0,	0,0,0
.db	1,	0,0,2
.db	2,	0,0,4
.db	3,	0,0,6
.db	4,	0,0,8
.db	5,	0,1,0
.db	6,	0,1,2
.db	7,	0,1,4
.db	8,	0,1,6
.db	9,	0,1,8
.db	10,	0,2,0
.db	11,	0,2,2
.db	12,	0,2,4
.db	13,	0,2,5
.db	14,	0,2,7
.db	15,	0,2,9
.db	16,	0,3,1
.db	17,	0,3,3
.db	18,	0,3,5
.db	19,	0,3,7
.db	20,	0,3,9
.db	21,	0,4,1
.db	22,	0,4,3
.db	23,	0,4,5
.db	24,	0,4,7
.db	25,	0,4,9
.db	26,	0,5,1
.db	27,	0,5,3
.db	28,	0,5,5
.db	29,	0,5,7
.db	30,	0,5,9
.db	31,	0,6,1
.db	32,	0,6,3
.db	33,	0,6,5
.db	34,	0,6,7
.db	35,	0,6,9
.db	36,	0,7,1
.db	37,	0,7,3
.db	38,	0,7,5
.db	39,	0,7,6
.db	40,	0,7,8
.db	41,	0,8,0
.db	42,	0,8,2
.db	43,	0,8,4
.db	44,	0,8,6
.db	45,	0,8,8
.db	46,	0,9,0
.db	47,	0,9,2
.db	48,	0,9,4
.db	49,	0,9,6
.db	50,	0,9,8
.db	51,	1,0,0
.db	52,	1,0,2
.db	53,	1,0,4
.db	54,	1,0,6
.db	55,	1,0,8
.db	56,	1,1,0
.db	57,	1,1,2
.db	58,	1,1,4
.db	59,	1,1,6
.db	60,	1,1,8
.db	61,	1,2,0
.db	62,	1,2,2
.db	63,	1,2,4
.db	64,	1,2,5
.db	65,	1,2,7
.db	66,	1,2,9
.db	67,	1,3,1
.db	68,	1,3,3
.db	69,	1,3,5
.db	70,	1,3,7
.db	71,	1,3,9
.db	72,	1,4,1
.db	73,	1,4,3
.db	74,	1,4,5
.db	75,	1,4,7
.db	76,	1,4,9
.db	77,	1,5,1
.db	78,	1,5,3
.db	79,	1,5,5
.db	80,	1,5,7
.db	81,	1,5,9
.db	82,	1,6,1
.db	83,	1,6,3
.db	84,	1,6,5
.db	85,	1,6,7
.db	86,	1,6,9
.db	87,	1,7,1
.db	88,	1,7,3
.db	89,	1,7,5
.db	90,	1,7,6
.db	91,	1,7,8
.db	92,	1,8,0
.db	93,	1,8,2
.db	94,	1,8,4
.db	95,	1,8,6
.db	96,	1,8,8
.db	97,	1,9,0
.db	98,	1,9,2
.db	99,	1,9,4
.db	100,	1,9,6
.db	101,	1,9,8
.db	102,	2,0,0
.db	103,	2,0,2
.db	104,	2,0,4
.db	105,	2,0,6
.db	106,	2,0,8
.db	107,	2,1,0
.db	108,	2,1,2
.db	109,	2,1,4
.db	110,	2,1,6
.db	111,	2,1,8
.db	112,	2,2,0
.db	113,	2,2,2
.db	114,	2,2,4
.db	115,	2,2,5
.db	116,	2,2,7
.db	117,	2,2,9
.db	118,	2,3,1
.db	119,	2,3,3
.db	120,	2,3,5
.db	121,	2,3,7
.db	122,	2,3,9
.db	123,	2,4,1
.db	124,	2,4,3
.db	125,	2,4,5
.db	126,	2,4,7
.db	127,	2,4,9
.db	128,	2,5,1
.db	129,	2,5,3
.db	130,	2,5,5
.db	131,	2,5,7
.db	132,	2,5,9
.db	133,	2,6,1
.db	134,	2,6,3
.db	135,	2,6,5
.db	136,	2,6,7
.db	137,	2,6,9
.db	138,	2,7,1
.db	139,	2,7,3
.db	140,	2,7,5
.db	141,	2,7,6
.db	142,	2,7,8
.db	143,	2,8,0
.db	144,	2,8,2
.db	145,	2,8,4
.db	146,	2,8,6
.db	147,	2,8,8
.db	148,	2,9,0
.db	149,	2,9,2
.db	150,	2,9,4
.db	151,	2,9,6
.db	152,	2,9,8
.db	153,	3,0,0
.db	154,	3,0,2
.db	155,	3,0,4
.db	156,	3,0,6
.db	157,	3,0,8
.db	158,	3,1,0
.db	159,	3,1,2
.db	160,	3,1,4
.db	161,	3,1,6
.db	162,	3,1,8
.db	163,	3,2,0
.db	164,	3,2,2
.db	165,	3,2,4
.db	166,	3,2,5
.db	167,	3,2,7
.db	168,	3,2,9
.db	169,	3,3,1
.db	170,	3,3,3
.db	171,	3,3,5
.db	172,	3,3,7
.db	173,	3,3,9
.db	174,	3,4,1
.db	175,	3,4,3
.db	176,	3,4,5
.db	177,	3,4,7
.db	178,	3,4,9
.db	179,	3,5,1
.db	180,	3,5,3
.db	181,	3,5,5
.db	182,	3,5,7
.db	183,	3,5,9
.db	184,	3,6,1
.db	185,	3,6,3
.db	186,	3,6,5
.db	187,	3,6,7
.db	188,	3,6,9
.db	189,	3,7,1
.db	190,	3,7,3
.db	191,	3,7,5
.db	192,	3,7,6
.db	193,	3,7,8
.db	194,	3,8,0
.db	195,	3,8,2
.db	196,	3,8,4
.db	197,	3,8,6
.db	198,	3,8,8
.db	199,	3,9,0
.db	200,	3,9,2
.db	201,	3,9,4
.db	202,	3,9,6
.db	203,	3,9,8
.db	204,	4,0,0
.db	205,	4,0,2
.db	206,	4,0,4
.db	207,	4,0,6
.db	208,	4,0,8
.db	209,	4,1,0
.db	210,	4,1,2
.db	211,	4,1,4
.db	212,	4,1,6
.db	213,	4,1,8
.db	214,	4,2,0
.db	215,	4,2,2
.db	216,	4,2,4
.db	217,	4,2,5
.db	218,	4,2,7
.db	219,	4,2,9
.db	220,	4,3,1
.db	221,	4,3,3
.db	222,	4,3,5
.db	223,	4,3,7
.db	224,	4,3,9
.db	225,	4,4,1
.db	226,	4,4,3
.db	227,	4,4,5
.db	228,	4,4,7
.db	229,	4,4,9
.db	230,	4,5,1
.db	231,	4,5,3
.db	232,	4,5,5
.db	233,	4,5,7
.db	234,	4,5,9
.db	235,	4,6,1
.db	236,	4,6,3
.db	237,	4,6,5
.db	238,	4,6,7
.db	239,	4,6,9
.db	240,	4,7,1
.db	241,	4,7,3
.db	242,	4,7,5
.db	243,	4,7,6
.db	244,	4,7,8
.db	245,	4,8,0
.db	246,	4,8,2
.db	247,	4,8,4
.db	248,	4,8,6
.db	249,	4,8,8
.db	250,	4,9,0
.db	251,	4,9,2
.db	252,	4,9,4
.db	253,	4,9,6
.db	254,	4,9,8
.db	255,	5,0,0


;
;
.CSEG
.ORG 0x0000							; definisce l'inizio del codice all'indirizzo 0x0000 (obbligatorio)			 
;
; INTERRUPT VECTORS FOLLOW
;
 	jmp RESET 				; vector 1:		Reset Handler
	jmp EXT_INT0			; vector 2:		IRQ0 Handler
	jmp EXT_INT1			; vector 3:		IRQ1 Handler
	jmp PCINTR0				; vector 4:		PCINT0 Handler
	jmp PCINTR1				; vector 5:		PCINT1 Handler
	jmp PCINTR2				; vector 6:		PCINT2 Handler
	jmp WDT					; vector 7:		Watchdog timer handler
	jmp TIM2_COMPA			; vector 8:		Timer2 Compare A handler
	jmp TIM2_COMPB			; vector 9:		Timer2 compare B handler
	jmp TIM2_OVF			; vector 10:	Timer2 Overflow Handler
	jmp TIM1_CAPT			; vector 11:	Timer1 Capture Handler
	jmp TIM1_COMPA			; vector 12:	Timer1 CompareA Handler
	jmp TIM1_COMPB			; vector 13:	Timer1 CompareB Handler
	jmp TIM1_OVF			; vector 14:	Timer1 Overflow Handler
	jmp TIM0_COMPA			; vector 15:	Timer 0 CompareA handler
	jmp TIM0_COMPB			; vector 16:	Timer 0 CompareB handler
	jmp TIM0_OVF 			; vector 17:	Timer0 Overflow Handler
	jmp SPI_STC				; vector 18:	SPI Transfer Complete Handler
	jmp USART_RXC			; vector 19:	USART RX Complete Handler
	jmp USART_UDRE			; vector 20:	USART UDR Empty Handler
	jmp USART_TXC			; vector 21:	USART TX Complete Handler
	jmp ADC_conv			; vector 22:	ADC Conversion Complete Handler
	jmp EE_RDY				; vector 23:	EEPROM Ready Handler
	jmp ANA_COMP			; vector 24:	Analog Comparator Handler
	jmp TWSI				; vector 25:	Two-wire Serial Interface Handler
	jmp SPM_RDY				; vector 26:	Store Program Memory Ready Handler
;
; END OF INTERRUPT VECTORS 
;
RESET:
; In questo punto inizia il programma principale
;
; Inizializzazione dello stack pointer all'ultima cella della RAM
;
	ldi     mp,HIGH(RAMEND)
   	out     SPH,mp
   	ldi     mp,LOW(RAMEND)
   	out     SPL,mp
;
; Inizializzazione in uscita dei primi 7 bit della porta D. PD0 - PD3 = ABCD; PD4 = LE centinaia; PD5 = LE decine; PD6 = LE unità.

	ldi	mp,0b0111_1111
	out	DDRD,mp
;
	ldi	mp, 0b0111_0000			; mette a 1 i LE dei 4511 (condizione di memoria)
	out	PORTD, mp						
;
; divide per 16 la frequenza del clock interno (16 MHz)
	ldi	mp, 0b1000_0000
	sts	CLKPR, mp				; abilita la programmazione del prescaler
	ldi	mp, 0b0000_0100
	sts	CLKPR, mp				; programma la divisione per 16 del clock interno
;
;	programma il timer 0
;
; seleziona prescaler passo 1024 (se 1 MHz allora 1024 us)
	ldi     mp,0b0000_0101
   	out     TCCR0B,mp
;	seleziona tempo tra interrupt pari a circa 10ms (10,24 ms)
	ldi     mp, 246
   	out     TCNT0,mp
;	abilita l'interrupt in caso di overflow di TCNT0
	ldi     mp,0b0000_0001
	sts     TIMSK0,mp
;
; inizializza la variabile var_check che sarà decrementata dalla subroutine di risposta ad interrupt 
;
	ldi		var_check,T_CHECK
;
;   programma l'ADC in modo da abilitarlo senza abilitare l'interrupt e seleziona un fattore di prescaling pari a 4.
;   Deve SEMPRE precedere la selezione dell'ingresso: non si può selezionare l'ingresso dell'ADC se questo non è stato preventivamente abilitato
	ldi 	mp,0b10000010
	sts		ADCSRA,mp
;
;	programma l'ADC perché lavori con riferimento interno pari alla tensione di alimentazione (AVcc), giustifichi a sinistra il risultato e senta l'input su PC0 (ADC0)
;
	ldi		mp,0b0110_0000
	sts		ADMUX,mp
;
;
; abilita gli interrupt a livello di SREG
;
	sei
;
;
main_loop:
;
;	verifica se è trascorso un tempo pari all'intervallo di campionamento della tensione (var_check = 0?)
;
	cpi		var_check,0
;
;   salto condizionato a end_loop se var_check è diverso da 0
;	
	brne	end_loop
; 
;   le istruzioni da qui a rjmp main_loop vengono eseguite solo se var_check è pari a 0
;
	ldi		var_check,T_CHECK		; per prima cosa inizializza nuovamente var_check
;
;	prepara il passaggio dell'indirizzo iniziale della tabella alla subroutine come variabile locale nello stack
;
	ldi		ZH,high(2*tabella)		; inizializza ZH con la parte alta dell'indirizzo della tabella
	ldi		ZL,low(2*tabella)		; inizializza ZL con la parte bassa dell'indirizzo della tabella
;									
	push	ZH				; mette ZH nello stack per passarlo alla subroutine che lo utilizzerà come parametro
;
	push	ZL				; mette ZL nello stack per passarlo alla subroutine che lo utilizzerà come parametro
;
; richiamo della subroutine measure che campiona la tensione e visualizza il risultato (attenzione, la call memorizza nello stack i due byte dell'indirizzo di rientro)
;
	call	measure
;
end_loop:
;
	nop						; istruzione di comodo aggiunta per il debugging (nop = no operation), aggiunge un ritardo di un ciclo di clock
;
       rjmp main_loop
;
;	Segue la subroutine che legge l'uscita dell'ADC e mostra il valore letto su 8 bit sulle tre lampade a sette segmenti
;   Riceve come parametri passati dal programma chiamante nello stack i byte basso ed alto dell'indirizzo iniziale della LUT
;
measure:
;
	pop		mp		; estrae temporaneamente dallo stack l'ultimo byte dell'indirizzo di rientro messo nello stack dalla call
	pop		mp1		; estrare temporaneamente dallo stack il primo byte dell'indirizzo di rientro messo nello stack dalla call
	pop		ZL		; recupera il byte basso dell'indirizzo  della tabella che è stato passato dal programma chiamante nello stack
	pop		ZH		; recupera il byte alto dell'indirizzo della tabella che è stato passato dal programma chiamante nello stack
	push	mp1		; ripristina nello stack il primo byte dell'indirizzo di rientro messo nello stack dalla call
	push	mp		; ripristina nello stack l'ultimo byte dell'indirizzo di rientro messo nello stack dalla call
;
;	inizia adesso la conversione portando a 1 il bit 6 di ADCSRA (ADSC) senza modificare null'altro in ADCSRA
;
	lds		mp,ADCSRA
	ldi		mp1,0b0100_0000
	or		mp,mp1
	sts		ADCSRA,mp
;
; aspetta che la conversione sia pronta testando ADSC in ADCSRA: a conversione terminata ADSC torna a 0 
;
check_conv:
	lds		mp,ADCSRA
	ldi		mp1,0b01000000
	and		mp,mp1
	brne	check_conv
;
;
; legge il valore convertito su 8 bit (siccome è stata scelta la giustificazione a sinistra gli 8 bit più significativi 
; del risultato sono in ADCH)
;
;
	lds		mp,ADCH
	ldi		mp1,4
	mul		mp,mp1
;
	add		ZL,R0		; Punta alla cella della tabella che corrisponde al valore letto dall'ADC
	adc		ZH,R1
;
;	prepara visulaizzazione su display
;
	lpm		mp, Z+		; legge primo valore della riga della tabella che contiene il valore completo intero su 8 bit ed incrementa Z
;
	lpm		mp, Z+		; legge il secondo valore della riga della tabella che contiene la cifra delle centinaia  ed incrementa Z
	ori		mp,0b0111_0000	; lascia a uno PD4 - PD7	e non modifica PD0 - PD3	
	out		PORTD, mp		; scrive in uscita la cifra delle centinaia
	andi	mp, 0b0110_1111	; prepara PD4 a livello basso (LE centinaia) senza modificare la cifra delle centinaia
	out		PORTD, mp		; abilita LE centinaia
	nop					; istruzioni di attesa necessarie per garantire l'efficacia dello strobe
	nop
	nop
	nop
	nop
	ori		mp,0b0111_0000	; mette a uno PD4 - PD7 (alza LE)
	out		PORTD, mp
;		
;
	lpm		mp, Z+			; legge il terzo valore della riga della tabella che contiene la cifra delle decine  ed incrementa Z
;
	ori		mp,0b0111_0000	; lascia a 1  PD4 - PD7		e non modifica PD0 - PD3
	out		PORTD, mp		; scrive in uscita la cifra delle decine
	andi	mp, 0b0101_1111		; prepara PD5 a livello basso (LE decine) senza modificare la cifra delle decine
	out		PORTD, mp		; abilita LE decine
	nop					; istruzioni di attesa necessarie per garantire l'efficacia dello strobe
	nop
	nop
	nop
	nop
	ori		mp,0b0111_0000	; mette a uno PD4 - PD7 (alza LE)
	out		PORTD, mp	
;
	lpm		mp, Z+			; legge il quarto valore della riga della tabella che contiene la cifra delle unità  ed incrementa Z
;
	ori		mp,0b0111_0000	; lascia a 1  PD4 - PD7		e non modifica PD0 - PD3		
	out		PORTD, mp		; scrive in uscita la cifra delle unità
	andi	mp, 0b0011_1111	; prepara PD6 a livello basso (LE unità) senza modificare la cifra delle unità
	out		PORTD, mp		; abilita LE unità
	nop					; istruzioni di attesa necessarie per garantire l'efficacia dello strobe
	nop
	nop
	nop
	nop
	ori		mp,0b0111_0000	; mette a uno PD4 - PD7 (alza LE)
	out		PORTD, mp	
;
;	scrittura display terminata
;	
;
	ret									; ritorna al programma chiamante
;
;
;  INTERRUPT HANDLERS FOLLOW
;
;
EXT_INT0:
	reti							; vector 2:		IRQ0 Handler
;	
EXT_INT1:							
	reti							; vector 3:		IRQ1 Handler
;
PCINTR0:
	reti							; vector 4:		PCINT0 Handler
;
PCINTR1:					
	reti							; vector 5:		PCINT1 Handler
;
PCINTR2:					
	reti							; vector 6:		PCINT2 Handler
;
WDT:								
	reti							; vector 7:		Watchdog timer handler
;
TIM2_COMPA:
	reti							; vector 8:		Timer2 compare A handler
;
TIM2_COMPB:
	reti							; vector 9:		Timer2 compare B handler
;
TIM2_OVF:							
	reti							; vector 10:		Timer2 Overflow Handler
;
TIM1_CAPT:
	reti							; vector 11:		Timer1 Capture Handler
;
TIM1_COMPA:	
	reti							; vector 12:		Timer1 CompareA Handler
;
TIM1_COMPB:			
	reti							; vector 13:		Timer1 CompareB Handler
;
TIM1_OVF:					
	reti							; vector 14:		Timer1 Overflow Handler
;
TIM0_COMPA:					
	reti							; vector 15:		Timer 0 CompareA handler
;
TIM0_COMPB:
	reti							; vector 16:		Timer 0 CompareB handler
;
;			
TIM0_OVF:
;
;	salva mp nello stack prima di utilizzarlo
	push	mp
;  	salva SREG nello stack
	in	mp,SREG
	push	mp
;   	inizializza nuovamente la variabile di conteggio del timer counter (10,24 ms)
	ldi	mp,246
    	out	TCNT0,mp
;	decrementa la variabile di conteggio della temporizzazione dell'ADC
	dec var_check
;	ripristina SREG
	pop 	mp
	out 	SREG,mp
;	ripristina mp
	pop 	mp
;		
	reti							; vector 17:		Timer0 Overflow Handler
;
;
;
SPI_STC:
	reti							; vector 18:		SPI Transfer Complete Handler
;
USART_RXC:						
	reti							; vector 19:		USART RX Complete Handler
;
USART_UDRE:					
	reti							; vector 20:		USART UDR Empty Handler
;
USART_TXC:					
	reti							; vector 21:		USART TX Complete Handler
;
ADC_conv:					
	reti							; vector 22:		ADC Conversion Complete Handler
;
EE_RDY:						
	reti							; vector 23:		EEPROM Ready Handler
;
ANA_COMP:						
	reti							; vector 24:		Analog Comparator Handler
;	
TWSI:
	reti							; vector 25:		Two-wire Serial Interface Handler
;
SPM_RDY:
	reti							; vector 26:		Store Program Memory Ready Handler