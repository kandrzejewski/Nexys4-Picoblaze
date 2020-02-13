showFahrI:	                   ; start new line
                    ld      uart1_data, #'1'	
                    call      send_to_uart1
                    ld      uart1_data, #'C'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'-'
					call      send_to_uart1
                    ld      uart1_data, #'>'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'5'
                    call      send_to_uart1
                    ld      uart1_data, #'0'
					call      send_to_uart1
                    ld      uart1_data, #'F'
showFahrX:	                   ; start new line
                    ld      uart1_data, #'1'	
                    call      send_to_uart1
                    ld      uart1_data, #'0'
                    call      send_to_uart1
                    ld      uart1_data, #'C'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'-'
					call      send_to_uart1
                    ld      uart1_data, #'>'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'5'
                    call      send_to_uart1
                    ld      uart1_data, #'0'
					call      send_to_uart1
                    ld      uart1_data, #'F'
showFahrV:	                  
                    ld      uart1_data, #'5'	
                    call      send_to_uart1
                    ld      uart1_data, #'C'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'-'
					call      send_to_uart1
                    ld      uart1_data, #'>'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'4'
                    call      send_to_uart1
                    ld      uart1_data, #'1'
					call      send_to_uart1
                    ld      uart1_data, #'F'
showFahrL:	                  
                    ld      uart1_data, #'5'	
                    call      send_to_uart1
					ld      uart1_data, #'0'
                    call      send_to_uart1
                    ld      uart1_data, #'C'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'-'
					call      send_to_uart1
                    ld      uart1_data, #'>'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'1'
					call      send_to_uart1
                    ld      uart1_data, #'2'
                    call      send_to_uart1
                    ld      uart1_data, #'2'
					call      send_to_uart1
                    ld      uart1_data, #'F'
showFahrC:	                  
                    ld      uart1_data, #'1'	
                    call      send_to_uart1
					ld      uart1_data, #'0'
                    call      send_to_uart1
					ld      uart1_data, #'0'
                    call      send_to_uart1
                    ld      uart1_data, #'C'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'-'
					call      send_to_uart1
                    ld      uart1_data, #'>'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'2'
					call      send_to_uart1
                    ld      uart1_data, #'1'
                    call      send_to_uart1
                    ld      uart1_data, #'2'
					call      send_to_uart1
                    ld      uart1_data, #'F'
showFahrD:          call      send_to_uart1
                    ld      uart1_data, #'D'