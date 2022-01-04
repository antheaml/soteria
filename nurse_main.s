
#include <xc.inc>

extrn	nurse_ledSetup, setup_lcd
extrn	SPI_MasterInit, SPI_MasterTransmit, SPI_MasterRead, read_byte1, NOP_delay
extrn	nurse_fall, nurse_alert, nurse_remote_disable

; ---------- Module controlling the set-up and standby state of the nurse device ---------- ;
    
psect	code, abs
	
rst:	org	0x0000	; reset vector
	goto	nurse_setup
	
nurse_setup:
    ; ********************************************************
    ; Subroutine which sets up the nurse device upon start-up
    ; ********************************************************
    bcf	    CFGS		    ; point to Flash program memory  
    bsf	    EEPGD		    ; access Flash program memory
    call    nurse_ledSetup	    ; set up LEDs
    call    setup_lcd		    ; set up LCD including UART for LCD
    movlw   0b00000111		    ; PORTD0:2 are inputs
    movwf   TRISD, A 
    movlw   0x00
    movwf   TRISH, A 		    ; PORTH0:7 are outputs
    goto    polling_main

    
polling_main: 
    ; ********************************************************************************************
    ; Looping subroutine which tests the logic level of RD0:2 to determine if a fall has occured,
    ; or the alert or disable buttons are pressed on the client device
    ; Logic:
    ; 		Fall occurs -> PORTD0 high -> call fall subroutine 
    ; 		Alert button pressed -> PORTD1 high -> call alert subroutine 
    ; 		Disable button pressed -> PORTD2 high -> call disable subroutine triggered
    ; BTFSC = bit test f, skip if clear
    ; Note: polling used instead of interrupt as interrupt bins (RB0:3) used by LCD screen 
    ; ********************************************************************************************
    BTFSC   PORTD, 1, A 
    call    nurse_alert
    BTFSC   PORTD, 0, A 
    call    nurse_fall
    BTFSC   PORTD, 2, A 
    call    nurse_remote_disable
    bra     polling_main ; loop
    
testing:
    call    NOP_delay
    call    NOP_delay
    bcf	    PORTE, 0, A
    call    NOP_delay
    call    NOP_delay
    movlw   0b10000000
    call    SPI_MasterTransmit
    call    NOP_delay
    call    NOP_delay
    call    NOP_delay
    movlw   0b00000000
    call    SPI_MasterRead
    bsf	    PORTE, 0, A
    ; wait in infinite loop for interrupt to be called
    
    goto    $

end	rst

    
    
