org 100h 

.DATA                                   ; Definicion de datos
    msg DB '[Palindromo] Palabra: $'    ; Define Byte -> texto
    buffer db 32                        ; Define Byte -> Buffer donde se almacena el input
	db 33 dup(?)                        ; Define byte -> Arreglo de 33 sin inicializacion 
	msg_is DB 10,13,'[Palindromo] Si$'  ; Define byte -> Line Feed & Carriage Return y texto
	msg_not DB 10,13,'[Palindromo] No$' ; Define byte -> Line Feed & Carriage Return y texto
                
.CODE                                   ; Seccion de codigo
           
    CALL print                          ; Ejecutar procedimiento "print"
    JMP start                           ; Saltar al "start" label

    start:                              ; Inicio del "start" label -> Inicio del programa
        CALL read                       ; Ejecutar procedimiento "read" 
        CALL get_size                   ; Ejecutar procedimiento "get_size"                                                  
        
        
    PRINT PROC                          ; Inicio del procedimiento "PRINT" -> Imprime el mensaje msg
        LEA DX, msg                     ; Guarda en registro DX la direccion de memoria inicial de msg
        MOV AH, 09H                     ; 09H -> Valor de DOS interrupt para imprimir
        INT 21H                         ; Llamado a una function del MS-DOS API
        ret                             ; Retorno a la instruccion posterior al llamado de procedimiento
    PRINT ENDP                          ; Finalizacion del procedimiento "PRINT"
              
    read:                               ; Inicio del "read' label -> Leer palabra del usuario
        MOV AH, 0AH                     ; 0AH -> Valor de DOS interrupt para leer caracter 
	    MOV DX, offset buffer	        ; Guarda en registro DX la direccion de memoria inicial de buffer
	    INT 21H                         ; Llamado a una function del MS-DOS API
	    LEA di, buffer+0x2              ; Guarda en Destination Index -> direccion de buffer mas 0x2
	    MOV bx, di                      ; Guarda en registro BX el valor actual en DI
	    MOV ax, 0                       ; Ajusta el valor de AX a 0 para iniciar una acumulacion
	    JMP get_size                    ; Salto a al "get_size" label
         
    get_size:                           ; Inicio del "get_size' label -> Obtener la longitud de la palabra
        INC bx                          ; Incrementa BX -> la direccion inicial de palabra por 0x1
        INC ax                          ; Incrementa AX -> acumulador de la longitud de la palabra
        CMP [bx], 0Dh                   ; Compara el valor en la direccion BX y 0DH (Carriage Return)
        JZ update_address               ; Si son iguales, salta al "update_address" label
        JMP get_size                    ; Salta a "get_size" label para evaluar nuevamente la comparacion
        
    update_address:                     ; Inicio del "update_address" label -> Actualiza SI y DI
        MOV si, di                      ; Copia DI a SI -> la direccion de memoria inicial de palabra
        ADD si, ax                      ; Aumenta SI su direccion de memoria mas la longitud  de la palabra
        DEC si                          ; Decrementa el valor de SI (direccion de memoria) por 0x1
        
        mov cx, ax                      ; Copia el registro de AX a CX (longitu de la palabra)
        cmp cx, 1                       ; Compara si la longitud de la palabra es 1
        je is_palindrome                ; Si es de longitud 1, entonces es palindrome
        shr cx, 1                       ; Shift Right 2^1 -> Divide la longitud de la palabra entre 2
        
        JMP iterate_next_char           ; Salta al "iterate_next_char" label
           
    
     iterate_next_char:                 ; Inicio del "iterate_next_char" label -> Comparar letras opuestas
        mov al, [di]                    ; Asigna a AL el valor en la posicion de memoria almacenada en DI
        mov bl, [si]                    ; Asigna a BL el valor en la posicion de memoria almacenada en SI 
        cmp al, bl                      ; Compara el valor almacenado en AL contra BL
        jne not_palindrome              ; Jump Not Zero -> Si los valores son diferentes salta al "not palindrome" label
        inc di                          ; Incrementa DI (posicion de memoria) en 0x1
        dec si                          ; Decrementa SI <posicion de memoria> en 0x1
        loop iterate_next_char          ; "FOR LOOP" -> "iterate_next_char" hasta que CX sea 0


     is_palindrome:                     ; "is_palindrome" label imprime el mensaje cuando es palindrome
           mov ah, 9
           mov dx, offset msg_is
           int 21h
           jmp stop

     not_palindrome:                    ; "is_palindrome" label imprime el mensaje cuando no es palindrome
        mov ah, 9
        mov dx, offset msg_not
        int 21h
             
     stop:                              ; Inicio del "stop" label -> Detiene la ejecucion del programa
        HLT                             ; HALT -> Detiene el CPU
    
    END                                 ; Fin del programa
             
                
ret