; -----------------------------------
; pB6 UART2 test
; CCE 2019
;------------------------------------
device kcpsm6
ISR_vec code 0x3ff
ISR code 0x3d0
entity "program_ROM7_debug"
;------------------------------------
;
; Registers and constants
;
uart1_data equ sf
uart2_data equ se
uart3_data equ sd
uart4_data equ sc
;
const_button_u equ 0b00000001
const_button_c equ 0b00000010
const_button_r equ 0b00000100
const_button_l equ 0b00001000
button_save equ s8
;
const_DEL equ 0x7f
const_ADR equ 'A'
const_DAT equ 'D'
; 
; Initialise the system
; 
cold_start:         ld s0, #0               ; clear all time values
                    ;ld button_save, #0
                    call   send_cr
                    call   send_header
;                    call   init_display
                    enable interrupt        ; enable the 1us interrupts
; 
; Start of the main program loop.
; 
                    jump start
;
; -----------------------------------
;
include "./include/uart1_interface_routines.asm"
include "./include/uart2_interface_routines.asm"
include "./include/uart3_interface_routines.asm"
include "./include/uart4_interface_routines.asm"
include "./uart1_text.asm"
;
;
;
start:
                    call send_prompt
;
;
;
loop:               ld uart4_data, #1
                    call send_to_uart4
                    call read_from_uart4
                    test uart4_data, #const_button_c
                    call c, save_button  
                    test uart4_data, #const_button_u
                    call c, save_button
                    test uart4_data, #const_button_r
                    call c, save_button
                    test uart4_data, #const_button_l
                    call c, save_button
                    
                    test button_save, #const_button_u
                    call c, processor_select
                    test button_save, #const_button_c
                    call c, ok
                    cmp button_save, #const_button_l
                    call c, view_temp_c
                    test button_save, #const_button_r
                    call c, view_temp_f

                    input s0, uart1_status_port
                    test s0, #uart1_rx_data_present           
                    jump nc, end_terminal_handling
                    call send_prompt
                    call read_rx1e
                    ld s0, uart1_data
                    cmp s0, #'R' ; start Procesor select
                    call z, processor_select
                    cmp s0, #'F' ;
                    call z, far_select
                    cmp s0, #'C' ;
                    call z, cel_select
;
;
;
end_terminal_handling:
                    jump loop
;
;
;
save_button:        ld button_save, uart4_data 
                    return          
;
;
;
ok:                 return



view_temp_c:        ld uart3_data, #1
                    call send_to_uart3
                    call read_from_uart3
                    ld uart2_data, #'C'
                    call send_to_uart2
                    ld uart2_data, #uart3_data
                    call send_to_uart2
                    return
;           
;
;
view_temp_f:        ld uart3_data, #1
                    call send_to_uart3
                    call read_from_uart3
                    ld uart2_data, #'F'
                    call send_to_uart2
                    ld uart2_data, uart3_data
                    call send_to_uart2
                    return
;
; Funkcjie obs3uguj1ce terminal 
;                          
processor_select:   ld uart2_data, #const_DEL
                    call send_to_uart2
                    return

far_select:         ld button_save, #const_button_r 
                    return

cel_select:         ld button_save, #const_button_l  
                    return
;
; Interrupt service routine (ISR)
; 
                    ORG       ISR
isr_proc:           add       s0, #1  
                    retie
; 
; Interrupt vector
; 
                    ORG       ISR_vec
                    jump      isr_proc
; 