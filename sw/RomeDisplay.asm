showI:              ld bpm, #1
                    ld temp, #'i'
                    ld mod, 'n'
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #49
                    call send_to_uart2
                    
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #1
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2
					                  
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #2
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2	
					return
					
showV:              ld bpm, #5 
                    ld temp, #'v' 
                    ld mod, 'n'                  
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #53
                    call send_to_uart2

					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #1
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2
					                  
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #2
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2	
					return
					
showX:              ld bpm, #10
                    ld temp, #'x'  
ld mod, 'n'                 
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #48
                    call send_to_uart2
					                 
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #1
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #49
                    call send_to_uart2
					                  
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #2
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2
					return

showL:              ld bpm, #50
                    ld temp, #'l'  
ld mod, 'n'                 
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #48
                    call send_to_uart2
					                 
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #1
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #53
                    call send_to_uart2
					                  
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #2
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2
					return	

showC:              ld bpm, #100
                    ld temp, #'c' 
ld mod, 'n'                  
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #48
                    call send_to_uart2
					                 
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #1
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #48
                    call send_to_uart2
					                  
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #2
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #49
                    call send_to_uart2
					return	


showD:              ld bpm, #500
                    ld temp, #'d' 
                    ld mod, 'n'                  
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #0
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #48
                    call send_to_uart2
					                 
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #1
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #48
                    call send_to_uart2
					                  
					ld uart2_data, #'A'
                    call send_to_uart2
                    ld uart2_data, #2
                    call send_to_uart2
                    ld uart2_data, #'D'
                    call send_to_uart2
                    ld uart2_data, #53
                    call send_to_uart2
					return							