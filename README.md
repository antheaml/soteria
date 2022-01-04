# Soteria - Fall detection system - Nurse device

## Project description
This code forms one half of the code required for the alpha-prototype of the Soteria fall detection system. Soteria provides a solution to the delay between a fall occurring in an at-risk individual and a trusted responder arriving on the scene. The at-risk individual wears the _Client_ device which is equipped with an accelerometer to detect falling motion, alongside an alert button, and a button to disable the alarm system. The _Client_ is paired with the _Nurse_ device which features an LCD screen, LEDs, and a buzzer to provide the user with information about whether the at-risk individual has fallen or is in need of aid. 

## Hardware
The client and nurse devices are based on MikroElectronika's EasyPIC PRO V7.0 development boards, which are mounted with the PIC18F87K22 microprocessor. Mikroelektronika's 6 DOF IMU 2 Click, which comes mounted with the BMI160 microprocessor, is attached to the _Client_ device for acceleration detection.

## What each file does
### nurse_interrupt.s
A module which controls the response of the nurse device when a fall is detected in the client, or the alert or disabled button is pressed. 

Contains the following subroutines: nurse_ledSetup, nurse_fall, nurse_alert, nurse_remote_disable

### nurse_lcd_main.s
A module which controls sending messages to the LCD screen. 

Contains the following subroutines: setup_lcd, LCD_Setup, LCD_clear, start_fall_lcd, start_disable_lcd, start_alertButton_lcd, loop_fall_lcd, loop_disable_lcd, loop_alertButton_lcd, LCD_Write_Message, LCD_Loop_message, LCD_Send_Byte_I, LCD_Send_Byte_D, LCD_Enable, delay, LCD_delay_ms, lcdlp2, LCD_delay_x4us, LCD_delay, lcdlp1

### nurse_main.s
A module which controls the set-up and standby state of the nurse device. The module also contains the testing subroutine which was used to test spi communication at an earlier stage of development.

Contains the following subroutines: rst, nurse_setup, polling_main, testing.

### nurse_uart_4_lcd.s
A module which initialises the UART communication protocol used to communicate between the microprocessor and the LCD.

Contains the following subroutines: UART_Setup, UART_Transmit_Message, UART_Loop_message, UART_Transmit_Byte

## Credits

This project was jointly made by SW Yuan and A MacIntosh-LaRocque for the 3rd Year Microprocessors Lab Course at Imperial College London during the academic year 2021-2022. 
