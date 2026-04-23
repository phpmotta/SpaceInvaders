; --- ÁREA DE CÓDIGO ---
ORIG 0000h

Inicio: MOV R1, FDFFh       ; 1. Inicializar a pilha
        MOV SP, R1          ; Transfere do registrador para o Stack Pointer(SP)
        
        ; 2. Limpar a tela
        MOV R1, CURSOR_INIT
        MOV M[CURSOR], R1   

        ;-comeca impressao da borda do jogo-

        MOV R3, 0           ; Inicia a coluna a 0 (c = 0)

                        ; --- 1. Desenhar no Topo (Linha 0) ---
        LoopBorda:      MOV M[CURSOR], R3   ; Coordenada = 0 (linha) + R3 (coluna)
                        MOV R1, '#'
                        MOV M[WRITE], R1    ; Imprime o '#' no topo

                        ; --- 2. Desenhar na Base (Linha 23) ---
                        MOV R4, 23          ; R4 recebe a linha da base
                        SHL R4, 8           ; Empurra a linha para os 8 bits superiores
                        OR  R4, R3          ; Junta a linha com a coluna atual (R3)
                        
                        MOV M[CURSOR], R4   ; Posiciona o cursor na base
                        MOV M[WRITE], R1    ; Imprime o '#' (o R1 já tem o '#' guardado)

                        ; --- 3. Avançar e Testar o Ciclo ---
                        INC R3              ; Avança para a próxima coluna (c++)
                        CMP R3, 80          ; Já chegou ao limite direito do ecrã (coluna 80)?
                        BR.NZ LoopBorda     ; Se Não é Zero (Not Zero), volta ao início do ciclo

        MOV R3, 1       ;R3=1 LINHA
        MOV R1, '#'

        LoopBordaL:     MOV R2, R3
                        SHL R2, 8

                        ;---1. DESENHAR LADO ESQUERDO ---
                        MOV M[CURSOR], R2
                        MOV M[WRITE], R1

                        ;---2. DESENHAR LADO DIREITO
                        MOV R4, 79    ; R4 RECEBE VALOR 79(NUMERO DA COLUNA)
                        OR R2, R4     ; JUNTA VALOR DE LINHA E COLUNA

                        MOV M[CURSOR], R2
                        MOV M[WRITE], R1

                        ;--- 3. AVANÇA E TESTA CICLO ---
                        INC R3
                        CMP R3, 23
                        BR.NZ LoopBordaL

        ;-fim da impressao da borda do jogo-

        ; 3. Montar a coordenada do cursor 
        MOV R1, M[NaveLinha]
        SHL R1, 8           ; Empurra a linha para os primeiros 8 bits
        MOV R2, M[NaveColuna]
        OR  R1, R2          ; Junta os valores de linha e coluna em R1
        
        ; 4. Enviar coordenada para o porto de controlo
        MOV M[CURSOR], R1   
        
        ; 5. Imprimir a nave
        MOV R1, 'A'
        MOV M[WRITE], R1    

Fim:    BR Fim              ; Loop infinito para o programa nao encerrar

; --- ÁREA DE DADOS ---
ORIG 8000h

CURSOR      EQU FFFCh  
WRITE       EQU FFFEh  
CURSOR_INIT EQU FFFFh  

NaveLinha   WORD 22    
NaveColuna  WORD 40