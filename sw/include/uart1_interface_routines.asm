                   ;
                   ;------------------------------------------------------------------------------------------
                   ; Copyright © 2011-2012, Xilinx, Inc.
                   ; This file contains confidential and proprietary information of Xilinx, Inc. and is
                   ; protected under U.S. and international copyright and other intellectual property laws.
                   ;------------------------------------------------------------------------------------------
                   ;
                   ; THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
                   ;
                   ;------------------------------------------------------------------------------------------
                   ;
                   ;             _  ______ ____  ____  __  __  __
                   ;            | |/ / ___|  _ \/ ___||  \/  |/ /_
                   ;            | ' / |   | |_) \___ \| |\/| | '_ \
                   ;            | . \ |___|  __/ ___) | |  | | (_) )
                   ;            |_|\_\____|_|   |____/|_|  |_|\___/
                   ;
                   ;
                   ;                PicoBlaze Reference Design.
                   ;
                   ;
                   ; Ken Chapman - Xilinx Ltd
                   ;
                   ; 23rd April 2012 - Initial Release
                   ; 24th July 2012 - Corrections to comments only
                   ;
                   ; This file contains routines used to interface with the UART6 macros provided with KCPSM6
                   ; and was first supplied with a reference design called 'uart6_605' included in the
                   ; PicoBlaze package. The routines enable characters to be transmitted to and received
                   ; from the UART macros as well as perform a reset of the FIFO the buffers.
                   ;
                   ;     NOTE - This is not a standalone PSM file. The 'uart_control.psm' file supplied with
                   ;            the reference design stated above includes this file and calls the routines
                   ;            contained in this file.
                   ;
                   ;                INCLUDE "uart_interface_routines.psm"
                   ;
                   ;     Hint - The INCLUDE directive was introduced in KCPSM6 Assembler v2.00.
                   ;
                   ;
                   ;------------------------------------------------------------------------------------------
                   ; Hardware Constants
                   ;------------------------------------------------------------------------------------------
                   ;
                   ; The CONSTANT directives below define the input and output ports assigned to the UART
                   ; macros that implement a 115,200 baud rate communication with the USB/UART on the board.
                   ; Additional constants identify the allocation of signals to bits within a port.
                   ;
                   uart1_data_reg equ uart1_data
                   ;
                   ; UART Status
                   ; -----------
                   ;
                   uart1_status_port equ 0x00             ; Read status
                   uart1_tx_data_present equ 0b00000001 ; Tx   data_present - bit0
                   uart1_tx_half_full equ 0b00000010    ;         half_full - bit1
                   uart1_tx_full equ 0b00000100         ;              full - bit2
                   uart1_rx_data_present equ 0b00001000 ; Rx   data_present - bit3
                   uart1_rx_half_full equ 0b00010000    ;         half_full - bit4
                   uart1_rx_full equ 0b00100000         ;              full - bit5
                   ;
                   ; Write data to UART_TX6
                   ; ----------------------
                   ;
                   uart1_tx6_output_port equ 0x01
                   ;
                   ; Read data from UART_RX6
                   ; -----------------------
                   ;
                   uart1_rx6_input_port equ 0x01
                   ;
                   ; Reset UART buffers (Constant Optimised Port)
                   ; --------------------------------------------
                   ;
                   reset_uart1_port equ 0x01
                   uart1_tx_reset equ 0b00000001        ; uart_tx6 reset - bit0
                   uart1_rx_reset equ 0b00000010        ; uart_rx6 reset - bit1
                   uart1_reset equ 0b00000011           ; reset Tx and Rx
                   uart1_operate equ 0b00000000         ; Tx and Rx free to operate
                   ;
                   ;
                   ;--------------------------------------------------------------------------------------
                   ; Routine to reset UART Buffers inside 'uart_tx6' and 'uart_rx6'
                   ;--------------------------------------------------------------------------------------
                   ;
                   ; This routine will generate and apply an active High reset pulse to  the FIFO
                   ; buffers in both the transmitter and receiver macros.
                   ;
                   ; Note that the reset signals have been assigned to a constant optimised output port
                   ; so the 'OUTPUTK' instructions are used and no registers contents are affected.
                   ;
                   ;
reset_uart1_macros: outputk #uart1_reset, reset_uart1_port
                   outputk #uart1_operate, reset_uart1_port
                   return 
                   ;
                   ;
                   ;--------------------------------------------------------------------------------------
                   ; Routine to send one character to the UART Transmitter 'uart_tx6'
                   ;--------------------------------------------------------------------------------------
                   ;
                   ; This routine will transmit the character provided in register 'uart_data'.
                   ;
                   ; Before the character is output to the 'UART_TX6' macro the status of the FIFO buffer
                   ; is checked to see if there is space. If the buffer is full then this routine will
                   ; wait for space to become available (e.g. the time required for a previous character
                   ; to be transmitted by the UART).
                   ;
                   ; Registers used s0 and uart_data for the data (which is preserved)
                   ;
    send_to_uart1: input s0, uart1_status_port                ;Check if buffer is full
                   test s0, #uart1_tx_full
                   jump nz, send_to_uart1                          ;wait if full
                   output uart1_data_reg, uart1_tx6_output_port
                   return 
                   ;
                   ;
                   ;--------------------------------------------------------------------------------------
                   ; Routine to attempt to receive one character from the UART Receiver 'uart_rx6'
                   ;--------------------------------------------------------------------------------------
                   ;
                   ; This routine will attempt to receive one character from the 'UART_RX6' macro, and if
                   ; successful, will return that character in register 'uart_data' and the Zero flag will be
                   ; reset (Z=0).
                   ;
                   ; If there are no characters available to be read from the FIFO buffer within the
                   ; 'UART_RX6' macro then this routine will timeout after ~2,000 clock cycles (which is
                   ; 40us at 50MHz) with the Zero flag set (Z=1). This timeout scheme ensures that KCPSM6
                   ; cannot become stuck in this routine if no characters are received. If you do want
                   ; KCPSM6 to wait indefinitely for a character to be received then either modify this
                   ; routine or perform a test of the Zero flag and repeat the call to this routine as
                   ; shown in this example...
                   ;
                   ;          wait_for_UART_RX: CALL UART_RX
                   ;                            JUMP Z, wait_for_UART_RX
                   ;
                   ;
                   ; Registers used s0, s1 and s5.
                   ;
read_from_uart1_tout: load s1, #90                      ;Timeout = 125 x (10 instructions x 2 clock cycles)
       rx1_timeout: input s0, uart1_status_port				 ;250 for 125MHz, 40 for 20MHz
                   test s0, #uart1_rx_data_present             ;Z=0 and C=1 when data present
                   jump nz, read_rx1
                   add s1, #0
                   add s1, #0
                   add s1, #0
                   add s1, #0
                   sub s1, #1
                   return z                                  ;Timeout returns with Z=1 and C=0
                   jump rx1_timeout
                   ;
  read_from_uart1: input s0, uart1_status_port				 
                   test s0, #uart1_rx_data_present           
                   jump nz, read_rx1
                   jump read_from_uart1
                   ;
  read_from_uart1e: input s0, uart1_status_port				 ; read and echo to host
                   test s0, #uart1_rx_data_present           
                   jump nz, read_rx1e
                   jump read_from_uart1e
                   ;
          read_rx1: input uart1_data_reg, uart1_rx6_input_port             ;read character from buffer
                   return 
                   ;
          read_rx1e: input uart1_data_reg, uart1_rx6_input_port             ;read character from buffer
                   call send_to_uart1
                   return 
                   ;
                   ;
                   ;------------------------------------------------------------------------------------------
                   ; End of 'uart_interface_routines.psm"'
                   ;------------------------------------------------------------------------------------------
                   ;

