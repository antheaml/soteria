#include <xc.inc>

global	setup_lcd, start_fall_lcd, start_alertButton_lcd, start_disable_lcd


extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message
extrn   nurse_ledSetup, nurse_fall, nurse_alert, nurse_remote_disable


psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
LCD_tmp:	ds 1   ; reserve 1 byte for temporary use
LCD_counter:	ds 1   ; reserve 1 byte for counting through nessage

LCD_E	EQU 5	; LCD enable bit
LCD_RS	EQU 4	; LCD register select bit

psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable_fall: 
	db	'F','a','l','l',' ','i','n',' ','R','o','o','m',' ','1','0','8',0x0a
					; message, plus carriage return
	myTable_l   EQU	17	; length of data
	align	2

myTable_disable: 
	db	'D','e','v','i','c','e',' ','i','d','l','e',0x0a
					; message, plus carriage return
	myTable_2   EQU	12	; length of data
	align	2

myTable_alertButton: 
	db	'H','e','l','p',' ','i','n',' ','R','o','o','m',' ','1','0','8',0x0a
					; message, plus carriage return
	myTable_3   EQU	17	; length of data
	align	2

psect	lcd_main_code, class=CODE	
rst: 	org 0x0
	goto	setup_lcd

	; ******* Programme FLASH read Setup Code ***********************
setup_lcd:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	call	LCD_clear
	call	start_disable_lcd
	return
	;goto	start
	
	; ******* Main programme ****************************************
	
LCD_clear:
	call	LCD_delay_ms
	movlw	000000001B	; Assume RS = 0 alresdy, so don't need to define
	call	LCD_Send_Byte_I
	movlw	10		; wait 40us
	call	LCD_delay_x4us
	return
	
start_fall_lcd: 	
	call	LCD_clear
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable_fall)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable_fall)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable_fall)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l		; bytes to read
	movwf 	counter, A		; our counter register
	call	loop_fall_lcd
	return

start_disable_lcd: 
	call	LCD_clear
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable_disable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable_disable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable_disable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_2	; bytes to read
	movwf 	counter, A		; our counter register
	call	loop_disable_lcd
	return

start_alertButton_lcd: 	
	call	LCD_clear
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable_alertButton)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable_alertButton)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable_alertButton)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_3	; bytes to read
	movwf 	counter, A		; our counter register
	call	loop_alertButton_lcd
	return

loop_fall_lcd: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop_fall_lcd		; keep going until finished

	movlw	myTable_l	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message

	movlw	myTable_l	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message
	return			; goto current line in code

loop_disable_lcd: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop_disable_lcd		; keep going until finished

	movlw	myTable_2	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message

	movlw	myTable_2	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message

	return			; goto current line in code

LCD_Send_Byte_I:	    ; Transmits byte stored in W to instruction reg
	movwf   LCD_tmp, A
	swapf   LCD_tmp, W, A   ; swap nibbles, high nibble goes first
	andlw   0x0f	    ; select just low nibble
	movwf   LATB, A	    ; output data bits to LCD
	bcf	LATB, LCD_RS, A	; Instruction write clear RS bit
	call    LCD_Enable  ; Pulse enable Bit 
	movf	LCD_tmp, W, A   ; swap nibbles, now do low nibble
	andlw   0x0f	    ; select just low nibble
	movwf   LATB, A	    ; output data bits to LCD
	bcf	LATB, LCD_RS, A	; Instruction write clear RS bit
        call    LCD_Enable  ; Pulse enable Bit 
	return

LCD_Send_Byte_D:	    ; Transmits byte stored in W to data reg
	movwf   LCD_tmp, A
	swapf   LCD_tmp, W, A	; swap nibbles, high nibble goes first
	andlw   0x0f	    ; select just low nibble
	movwf   LATB, A	    ; output data bits to LCD
	bsf	LATB, LCD_RS, A	; Data write set RS bit
	call    LCD_Enable  ; Pulse enable Bit 
	movf	LCD_tmp, W, A	; swap nibbles, now do low nibble
	andlw   0x0f	    ; select just low nibble
	movwf   LATB, A	    ; output data bits to LCD
	bsf	LATB, LCD_RS, A	; Data write set RS bit	    
        call    LCD_Enable  ; Pulse enable Bit 
	movlw	10	    ; delay 40us
	call	LCD_delay_x4us
	return

LCD_Enable:	    ; pulse enable bit LCD_E for 500ns
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bsf	LATB, LCD_E, A	    ; Take enable high
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	LATB, LCD_E, A	    ; Writes data to LCD
	return

loop_alertButton_lcd: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop_alertButton_lcd		; keep going until finished

	movlw	myTable_3	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message

	movlw	myTable_3	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message

	return			; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay:	
	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return


;;;;;;;;;;;;;;;;;;;;;;;;;;;; LCD delays ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LCD_delay_ms:		    ; delay given in ms in W
	movwf	LCD_cnt_ms, A
lcdlp2:	movlw	250	    ; 1 ms delay
	call	LCD_delay_x4us	
	decfsz	LCD_cnt_ms, A
	bra	lcdlp2
	return
    
LCD_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l, A	; now need to multiply by 16
	swapf   LCD_cnt_l, F, A	; swap nibbles
	movlw	0x0f		;						
	andwf	LCD_cnt_l, W, A ; move low nibble to W
	movwf	LCD_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1:	decf 	LCD_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return		
	

