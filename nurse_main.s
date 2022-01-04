
#include <xc.inc>

extrn	nurse_ledSetup, setup_lcd
extrn	SPI_MasterInit, SPI_MasterTransmit, SPI_MasterRead, read_byte1, NOP_delay
extrn	nurse_fall, nurse_alert, nurse_remote_disable

    
psect	code, abs
	
rst:	org	0x0000	; reset vector
	goto	nurse_setup

;int_hi:	org	0x0008	; high priority interrupt
;	goto	Nurse_Int_Hi
	
nurse_setup:
    ;bsf	    TRISB, 0, A		    ; make interrupts input already done in Nurse_Interrupt_Setup 
    bcf	    CFGS		    ; point to Flash program memory  
    bsf	    EEPGD		    ; access Flash program memory
    call    nurse_ledSetup	    ; set up lEDs
    call    setup_lcd		    ; set up lcd including uart for lcd
    ;call    Nurse_Interrupt_Setup   ; set up interrupt pins for nurse
    ;call    Nurse_Int_Hi
    ;call    SPI_MasterInit
    movlw   0b00000111
    movwf   TRISD, A  ;port d is input
    movlw   0x00
    movwf   TRISH, A ; port H as outputs
    goto    polling_main

    
polling_main: ; used to be main 
    BTFSC   PORTD, 1, A ;bit test RH7, skip if clear
    call    nurse_alert
    BTFSC   PORTD, 0, A ;bit test RG0, skip if clear
    call    nurse_fall
    BTFSC   PORTD, 2, A ;bit test RG2, skip if clear
    call    nurse_remote_disable
    bra     polling_main
    
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

    
    
