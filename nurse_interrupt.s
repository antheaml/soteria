#include <xc.inc>
    
global	nurse_ledSetup, nurse_fall, nurse_alert, nurse_remote_disable

extrn	start_fall_lcd, start_alertButton_lcd, start_disable_lcd, setup_lcd

psect	nurse_int_code,class=CODE

nurse_ledSetup: 
    ; ***************************************************************
    ; ----- Subroutine to set ports controlling LEDs as inputs/outputs
    ; ***************************************************************
    movlw   0b11111000 ; PORTH0:2 as output
    movwf   TRISH, A 
    movlw   0b00000100 ; PORTH0:1 and PORTH3:7 LEDs off, PORTH2 (disable LED)  on 
    movwf   PORTH, A
    return		
	
nurse_fall:
    ; ******************************************
    ; ----- Subroutine called when client falls
    ; ******************************************
    bsf	    PORTH, 0 , A ; turn on fall LED
    call    setup_lcd 
    call    start_fall_lcd
    return
    
nurse_alert:
    ; *****************************************************
    ; ----- Subroutine called when alert button is pressed
    ; *****************************************************
    bsf	    PORTH, 1, A ; turn on alert LED
    call    setup_lcd
    call    start_alertButton_lcd
    return
    
nurse_remote_disable:
    ; *******************************************************
    ; ----- Subroutine called when disable button is pressed
    ; *******************************************************		   
    movlw   0b00000100 ; turn on disable LED, turn off alert and fall LED
    movwf   PORTH, A
    call    setup_lcd
    call    start_disable_lcd
    return

	


