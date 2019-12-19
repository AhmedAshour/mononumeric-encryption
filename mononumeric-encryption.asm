include 'emu8086.inc' ; Includes some common functions

org 100h

;-------------- Saving Tables --------------
                                                     
; Stores letters from a to z (lower case) 
MOV CX, 26   ; Size of letters in the alphabet
MOV AL, 61h  ; ASCII code for letter 'a'
MOV DI, 400h ; Hold the offset of memory location in the ES  
CLD ; DF = 0 
store_letters:  
STOSB ; Copies a byte from AL to a memory location in ES. DI is used to hold the offset of the memory location in the ES. After the copy, DI is automatically incremented or decremented to point to the next string element in memory.   
INC AL ; Increases AL value by 1, therefore changing the letter 
LOOP store_letters ; Loops if CX after decrementing by 1 not equal 0


; Store numbers from 1 to 26
MOV CX, 26 ; Size of letters in the alphabet
MOV AL, 1  ; Starting from number 1
MOV DI, 460h ;   
 
store_numbers:  
STOSB   
INC AL  
LOOP store_numbers

;-------------- Starting the program --------------        
        
; Displays welcome message
LEA DX, welcome_msg
MOV AH, 9 ; Selecting the sub-function
INT 21h ; Function that outputs a string at DS:DX. String must be terminated by '$'
    
; Displays welcome message
LEA DX, welcome_msg2
MOV AH, 9 
INT 21h


start_program:

; Displays "Enter a message to encrypt: " message
LEA DX, encrypt_msg
MOV AH, 9 
INT 21h 

; Takes input from user
LEA DX, buffer
mov AH, 0Ah ; Sub-function that stores input of a string to DS:DX
INT 21h

; Puts $ at the end to be able to print it later
MOV BX,0
MOV BL, buffer[1]
MOV buffer[BX + 2], '$'

;-------------- Encrypting -------------- 
; Displays "Encrypted message: " message
LEA DX, encrypted_msg
MOV AH, 9 
INT 21h

; The encryption code
MOV DI, 3FFh
MOV BX, DI
LEA SI, buffer[2]

next_char:
	CMP [SI], '$' ; Check if reached end of message
	JE end_msg
	
	LODSB ; Loads first char into AL, then moves SI to next char 
	CMP AL, 'a'
	JB  next_char ; If char is invalid, skip it
	CMP AL, 'z'
	JA  next_char 
	XLATB     ; Encrypt 
forspace:	
    MOV [SI-1], AL
	MOV AH,0 	
	CALL PRINT_NUM_UNS ; Using a procedure to print numbers
    DEFINE_PRINT_NUM_UNS
 
	JMP next_char
	 
;space: mov al,0h
;       jmp forspace	

end_msg:

 
; Decryption:
MOV BX, DI
LEA SI, buffer[2]

next_num:
	CMP [SI], '$'
	JE end_nums
	
	LODSB ; Loads byte from DS:SI to AL, then increments SI by 1
	CMP AL, 1
	JB  next_num
	CMP AL, 26
	JA  next_num	
	XLATB     ; Decrypt 
	MOV [SI-1], AL
    JMP next_num

end_nums:
                
               
LEA DX, decrypt_msg
MOV AH, 9
INT 21h
      
; Displays decrypted message
LEA DX, buffer + 2
MOV AH, 9
INT 21h

; Repeat the program
JMP start_program


welcome_msg db "Welcome to Mononumeric Substitution Encryption Program $"
welcome_msg2 db 0Dh,0Ah, "====================================================== $"

encrypting_msg db 0Dh,0Ah, "Encrypting ... $"
encrypt_msg db 0Dh,0Ah, "Enter a message to encrypt: $" 
encrypted_msg db 0Dh,0Ah, "The encrypted message is: $"  
decrypt_msg db 0Dh,0Ah, "The decrypted message is: $"

buffer db 27,?, 27 dup(' ')

end