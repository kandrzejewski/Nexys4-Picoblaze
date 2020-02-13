; 
; Send Carriage Return to the UART
; 
send_cr:            ld      uart1_data, #'\r'
                    call      send_to_uart1
                    ret       
; 
; Send a space to the UART
; 
send_space:         ld      uart1_data, #' '
                    call      send_to_uart1
                    ret       
; 
; Send a back space to the UART
; 
send_backspace:     ld      uart1_data, #'\b'
                    call      send_to_uart1
                    ret       
; 
; 
; Send 'Error' to the UART
; 
send_error:         ld      uart1_data, #'E'
                    call      send_to_uart1
                    ld      uart1_data, #'r'
                    call      send_to_uart1
                    call      send_to_uart1
                    ld      uart1_data, #'o'
                    call      send_to_uart1
                    ld      uart1_data, #'r'
                    call      send_to_uart1
                    ret       
; 
; Send 'KCPSM6>' prompt to the UART
; 
send_prompt:        call      send_cr             ; start new line
                    ld      uart1_data, #'C'
                    call      send_to_uart1
                    ld      uart1_data, #'O'
                    call      send_to_uart1
                    ld      uart1_data, #'m'
                    call      send_to_uart1
                    ld      uart1_data, #'m'
                    call      send_to_uart1
                    ld      uart1_data, #'a'
                    call      send_to_uart1
                    ld      uart1_data, #'n'
                    call      send_to_uart1
                    ld      uart1_data, #'d'
                    call      send_to_uart1
; 
; Send '>' character to the UART
; 
send_greater_than:  ld      uart1_data, #'>'
                    call      send_to_uart1
                    ret       
; 
; 
; Send Header to the UART
; 
send_header:        ld      uart1_data, #'U'
                    call      send_to_uart1
                    ld      uart1_data, #'A'
                    call      send_to_uart1
                    ld      uart1_data, #'R'
                    call      send_to_uart1
                    ld      uart1_data, #'T'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'B'
                    call      send_to_uart1
                    ld      uart1_data, #'r'
                    call      send_to_uart1
                    ld      uart1_data, #'i'
                    call      send_to_uart1
                    ld      uart1_data, #'d'
                    call      send_to_uart1
                    ld      uart1_data, #'g'
                    call      send_to_uart1
                    ld      uart1_data, #'e'
                    call      send_to_uart1
                    ld      uart1_data, #' '
                    call      send_to_uart1
                    ld      uart1_data, #'v'
                    call      send_to_uart1
                    ld      uart1_data, #'.'
                    call      send_to_uart1
                    ld      uart1_data, #'1'
                    call      send_to_uart1
                    ld      uart1_data, #'.'
                    call      send_to_uart1
                    ld      uart1_data, #'0'
                    call      send_to_uart1
                    ld      uart1_data, #'0'
                    call      send_to_uart1
                    ret       
; 