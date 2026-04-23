; --- ÁREA DE CÓDIGO ---
ORIG 0000h

Inicio:
    ; 1. Inicializar a pilha
    MOV SP, FDFFh      

    ; 2. Limpar a tela
    MOV R1, CURSOR_INIT
    MOV M[CURSOR], R1       

    ; 3. Montar a coordenada do cursor (Linha << 8 | Coluna)
    MOV R1, M[NaveLinha]
    SHL R1, 8           ; Empurra a linha para os primeiros 8 bits
    MOV R2, M[NaveColuna]
    OR  R1, R2          ; Junta os valores de linha e coluno em R1
    
    ; 4. Enviar coordenada para o porto de controlo
    MOV M[CURSOR], R1   

    ; 5. Imprimir a nave
    MOV R1, 'A'
    MOV M[WRITE], R1    

Fim:
    BR Fim              ; Loop infinito para o programa não encerrar e fechar a tela

; --- ÁREA DE DADOS ---
ORIG 8000h

CURSOR      EQU FFFCh  
WRITE       EQU FFFEh  
CURSOR_INIT EQU FFFFh  

NaveLinha   WORD 22    
NaveColuna  WORD 40