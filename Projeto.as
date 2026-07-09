;Aluno: Pedro Henrique Penna Motta 2026.1
;Trabalho da disciplina de Arquitetura de computadores
;Space Invaders

;------ INTERRUPÇÃO ----------------------------------------------------------------------
        ORIG FE0Fh
        Vetor15 WORD Timer
;-----------------------------------------------------------------------------------------

;------ Inicialização --------------------------------------------------------------------
        ORIG 0000h

                ; inicializa a pilha
        Inicio: MOV R1, FDFFh       
                MOV SP, R1          ; transfere do registrador para o Stack Pointer(SP)
                
                ; configura e ativa o temporizador(interrupção)
                MOV R1, 1           ; esse valor controla o tempo de início do timer, no caso 1 espaço temporal
                MOV M[TIMER_VAL], R1
                MOV R1, 1           ; 1 liga o temporizador
                MOV M[TIMER_CTRL], R1

                ENI                 ; habilita as interrupções no processador
                
                ; Limpar a tela
                MOV R1, CURSOR_INIT
                
                MOV M[CURSOR], R1   
;-----------------------------------------------------------------------------------------

;------ Borda do jogo --------------------------------------------------------------------

        MOV R3, 0       ; inicia coluna com 0 

                        ; desenha linha 0
        LoopTeto:      MOV M[CURSOR], R3   
                        MOV R1, '#'
                        MOV M[WRITE], R1    ; imprime o '#' no topo

                        ; desenha ultima linha
                        MOV R4, 23          
                        SHL R4, 8           
                        OR  R4, R3          
                        
                        MOV M[CURSOR], R4   
                        MOV M[WRITE], R1    

                        ; avança 
                        INC R3             
                        CMP R3, 80          
                        BR.NZ LoopTeto     

        MOV R3, 1       
        MOV R1, '#'

        LoopBorda:     MOV R2, R3
                        SHL R2, 8

                        ; desenha lado esquerdo da tela
                        MOV M[CURSOR], R2
                        MOV M[WRITE], R1

                        ; desenha lado direito da tela
                        MOV R4, 79    
                        OR R2, R4     

                        MOV M[CURSOR], R2
                        MOV M[WRITE], R1

                        ; avança 
                        INC R3
                        CMP R3, 23
                        BR.NZ LoopBorda
;-----------------------------------------------------------------------------------------

;------ Imprime a nave e score -----------------------------------------------------------
        
        ; monta o cursor da nave
        MOV R1, M[NaveLinha]    
        SHL R1, 8               
        MOV R2, M[NaveColuna]   
        OR  R1, R2              
        
        MOV M[CURSOR], R1   
        
        ; imprimir a nave
        MOV R1, 'A'
        MOV M[WRITE], R1    

                        ; imprime texto "SCORE:"
                        MOV R1, 1 
                        SHL R1, 8

                        MOV R2, 2
                        OR R1, R2
                        MOV R3, 'S'
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R3

                        INC R1
                        MOV M[CURSOR], R1
                        MOV R3, 'C'
                        MOV M[WRITE], R3
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R3, 'O'
                        MOV M[WRITE], R3
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R3, 'R'
                        MOV M[WRITE], R3
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R3, 'E'
                        MOV M[WRITE], R3
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R3, ':'
                        MOV M[WRITE], R3

                        ; desenha os inimigos iniciais
                        CALL DesenhaInim
                        CALL Vidas
                        
                        ; imprime o placar inicial (00)
                        MOV R1, 1
                        SHL R1, 8
                        MOV R2, 9
                        OR R1, R2
                        MOV M[CURSOR], R1
                        MOV R2, '0'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
;-----------------------------------------------------------------------------------------

;------ Loop do jogo ---------------------------------------------------------------------       

        GameLoop:         MOV R1, M[EstadoJogo]   ; verifica qual estado do jogo              
                          CMP R1, 1               ; 0 = Jogando, 1 = inimigos atingiram a nave, 2 = matou todos os inim
                          BR.Z AtingeNave
                          CMP R1, 2
                          BR.NZ AUX
                          JMP Vitoria

        AUX:              MOV R1, M[STATUS]       ; lê se alguem digitou algo
                          CMP R1, 0               
                          BR.NZ PegaTecla         
                          JMP GameLoop            

        PegaTecla:        MOV R1, M[READ]      

        TestaEsquerda:    CMP R1, 'a'             ; testa se apertaram 'a' 
                          BR.NZ TestaDireita      
                          JMP MoveEsquerda        

        TestaDireita:     CMP R1, 'd'             ; testa se apertaram 'd'
                          BR.NZ TestaDisparo      
                          JMP MoveD      

        TestaDisparo:     CMP R1, ' '             ; testa se dispararam ' '
                          BR.NZ FimLoop           
                          JMP VerificaTiro               

        FimLoop:          JMP GameLoop            ; ignora outras teclas e volta para o inicio

                          ; reage de uma forma dependendo do estado do jogo
        AtingeNave:       DEC M[NumeroVidas]       ; tira uma vida 
                          MOV R1, M[NumeroVidas]   ; verifica se as vidas acabaram
                          CMP R1, 0                 
                          BR.Z GameOver            ; se sim, vai pro Game Over com tempo parado
              
                          MOV R1, 0                ; se ainda tem vidas, continua o jogo
                          MOV M[EstadoJogo], R1    ; tempo continua
                          CALL ResetFase           ; reinicia posição dos inimigos
                          JMP GameLoop

        Vitoria:          CALL MensagemVitoria     ; escreve na tela 'Vitória'
                          CALL Espaco       ; apertar espaço para reiniciar jogo
                          CALL ResetCompleto       ; se apertou espaço, zera as variáveis e reinicia
                          MOV R1, 0                
                          MOV M[EstadoJogo], R1    ; volta com o tempo para reiniciar o jogo
                          JMP GameLoop

        GameOver:         CALL MensagemGameOver    ; escreve na tela 'Game Over'
                          CALL Espaco       ; espera apertar espaço para reniciar
                          CALL ResetCompleto       ; se apertou espaço, zera as variáveis e reinicia
                          MOV R1, 0
                          MOV M[EstadoJogo], R1    ; volta com o tempo para reiniciar o jogo
                          JMP GameLoop
;-----------------------------------------------------------------------------------------

;------ Movimentação da nave e tiro ------------------------------------------------------

        MoveEsquerda:   MOV R1, M[NaveColuna]   
                        CMP R1, 1               ; esta na parede?
                        BR.Z CancelaE            ; se sim, pula 
                        CMP R1, 2               
                        BR.Z CancelaE            
                        JMP MoveE            

        CancelaE:        JMP GameLoop            

                        ; apaga a nave da posição antiga 
        MoveE:          MOV R1, M[NaveLinha]    
                        SHL R1, 8
                        MOV R2, M[NaveColuna]
                        OR  R1, R2
                        MOV M[CURSOR], R1
                        MOV R1, ' '             
                        MOV M[WRITE], R1

                        ; atualiza a variável
                        MOV R1, M[NaveColuna]
                        SUB R1, 2
                        MOV M[NaveColuna], R1

                        ; imprime a nave na nova posição 
                        MOV R1, M[NaveLinha]    
                        SHL R1, 8
                        MOV R2, M[NaveColuna]
                        OR  R1, R2
                        MOV M[CURSOR], R1
                        MOV R1, 'A'             
                        MOV M[WRITE], R1

                        JMP GameLoop            


        MoveD:          MOV R1, M[NaveColuna]   
                        CMP R1, 78             ;verifica se esta na parede
                        BR.Z CancelaD           ; se sim, cancela
                        CMP R1, 77             
                        BR.Z CancelaD            
                        JMP FazMoveD            
        CancelaD:       JMP GameLoop            
       
                        ; apaga a nave da posição antiga
        FazMoveD:       MOV R1, M[NaveLinha]    
                        SHL R1, 8
                        MOV R2, M[NaveColuna]
                        OR  R1, R2
                        MOV M[CURSOR], R1
                        MOV R1, ' '             
                        MOV M[WRITE], R1

                        ; atualiza a variável
                        MOV R1, M[NaveColuna]
                        ADD R1, 2
                        MOV M[NaveColuna], R1

                        ; imprime a nave na nova posição
                        MOV R1, M[NaveLinha]    
                        SHL R1, 8
                        MOV R2, M[NaveColuna]
                        OR  R1, R2
                        MOV M[CURSOR], R1
                        MOV R1, 'A'             
                        MOV M[WRITE], R1

                        JMP GameLoop

        VerificaTiro:   MOV R1, M[TiroAtivo]    
                        CMP R1, 1               ; já tem um tiro?
                        BR.NZ Atira          ; Se não, atira
                        JMP GameLoop            ; Se sim, volta para o jogo e ignora

                        ; liga a 'trava' de que tem um tiro ativo
        Atira:          MOV R1, 1
                        MOV M[TiroAtivo], R1

                        ; copia a coluna da nave para o tiro
                        MOV R1, M[NaveColuna] 
                        MOV M[TiroColuna], R1

                        ; definir a altura inicial 
                        MOV R1, 20
                        MOV M[TiroLinha], R1

                        ; desenhar o tiro na tela pela primeira vez
                        MOV R1, M[TiroLinha]    
                        SHL R1, 8               
                        MOV R2, M[TiroColuna]   
                        OR  R1, R2             
                                
                        MOV M[CURSOR], R1       
                        MOV R1, '|'             
                        MOV M[WRITE], R1        

                        ; volta para o loop do jogo
                        JMP GameLoop              
;-----------------------------------------------------------------------------------------

;------ Rotina do Temporizador -----------------------------------------------------------
        Timer:          PUSH R1             ; salva os registradores para não quebrar 
                        PUSH R2             ; a lógica do GameLoop 
                        PUSH R3
                        PUSH R4

                        ; para o tempo
                        MOV R1, M[EstadoJogo]
                        CMP R1, 0             ; jogo está rodando normalmente (0)?
                        BR.Z TimerNormal      ; se sim, pula para o timer normal
                        JMP ReativaTimer      ; se não, vai para a interrupção

                        ; movimentação Inimiga
        TimerNormal:    INC M[TimerInim]    
                        MOV R1, M[TimerInim]
                        MOV R2, 5             ; controla velocidade dos inimigos
                        CMP R1, R2
                        BR.Z AtualizaMov   
                        JMP Tiro
        
        AtualizaMov:    MOV M[TimerInim], R0    ; zera o timer de movimentação

                        ; apaga os inimigos vivos
                        MOV R1, ' '
                        MOV M[ImprimeInimigo], R1    
                        CALL DesenhaInim         ; escreve por cima dos inimigos com ' '

                        ; atualiza posicao dos inimigos
                        MOV R1, M[DirecaoInim]  
                        CMP R1, 1
                        BR.Z MoveDireitaInim   
                        JMP MoveEsquerdaInim      

        MoveDireitaInim:MOV R1, 2               
                        ADD M[Inimigo1Col], R1
                        ADD M[Inimigo2Col], R1
                        ADD M[Inimigo3Col], R1
                        ADD M[Inimigo4Col], R1
                        ADD M[Inimigo5Col], R1
                        ADD M[Inimigo6Col], R1
                        ADD M[Inimigo7Col], R1
                        ADD M[Inimigo8Col], R1
                        ADD M[Inimigo9Col], R1
                        ADD M[Inimigo10Col], R1
                        ADD M[Inimigo11Col], R1
                        ADD M[Inimigo12Col], R1
                        ADD M[Inimigo13Col], R1
                        ADD M[Inimigo14Col], R1
                        JMP VerificaBordas      

        MoveEsquerdaInim:MOV R1, 2             
                        SUB M[Inimigo1Col], R1
                        SUB M[Inimigo2Col], R1
                        SUB M[Inimigo3Col], R1
                        SUB M[Inimigo4Col], R1
                        SUB M[Inimigo5Col], R1
                        SUB M[Inimigo6Col], R1
                        SUB M[Inimigo7Col], R1
                        SUB M[Inimigo8Col], R1
                        SUB M[Inimigo9Col], R1
                        SUB M[Inimigo10Col], R1
                        SUB M[Inimigo11Col], R1
                        SUB M[Inimigo12Col], R1
                        SUB M[Inimigo13Col], R1
                        SUB M[Inimigo14Col], R1
                        JMP VerificaBordas      

                        ;verifica se os inimigos bateram na borda direita ou esquerda
        VerificaBordas: MOV R1, M[DirecaoInim]
                        CMP R1, 1                
                        BR.Z TestaBordaD         
                        JMP TestaBordaE          

                        ; testa se bateu na borda direita
        TestaBordaD:    MOV R1, M[Inimigo5Col]   
                        CMP R1, 75               
                        BR.N FimVerificaAux        
                        JMP BateuParede     

        FimVerificaAux: JMP FimVerifica

                        ; testa se bateu na borda esquerda
        TestaBordaE:    MOV R1, M[Inimigo1Col]   
                        CMP R1, 2                
                        BR.NN FimVerificaAux        
                        JMP BateuParede          

                        ; inverte a direção e desce
        BateuParede:    MOV R1, M[DirecaoInim]
                        CMP R1, 1                
                        BR.Z MudaPraEsquerda     

        MudaPraDireita: MOV R1, 1                
                        MOV M[DirecaoInim], R1
                        JMP DesceInim

        MudaPraEsquerda:MOV R1, 0
                        MOV M[DirecaoInim], R1

        DesceInim:      INC M[InimigoLinha]
                        INC M[InimigoLinha2]
                        INC M[InimigoLinha3]

                        ; verifica se os inimigos atingiram a linha da nave
                        MOV R2, M[NaveLinha]     
                        
                        MOV R1, M[InimigoLinha3]
                        CMP R1, R2
                        BR.NZ VerificaLinhaI2
                        ; verifica se a fileira 3 tem inimigos ativos
                        MOV R1, M[Inimigo10Ativo]
                        ADD R1, M[Inimigo11Ativo]
                        ADD R1, M[Inimigo12Ativo]
                        ADD R1, M[Inimigo13Ativo]
                        ADD R1, M[Inimigo14Ativo]
                        CMP R1, 0
                        BR.Z VerificaLinhaI2
                        JMP AtingiuNAve         ; se a soma > 0, tem algum inimigo ativo na linha da nave

        VerificaLinhaI2: MOV R1, M[InimigoLinha2]
                        CMP R1, R2
                        BR.NZ VerificaLinhaI1
                        ; verifica se a fileira 2 tem inimigos ativos
                        MOV R1, M[Inimigo6Ativo]
                        ADD R1, M[Inimigo7Ativo]
                        ADD R1, M[Inimigo8Ativo]
                        ADD R1, M[Inimigo9Ativo]
                        CMP R1, 0
                        BR.NZ AtingiuNAve

        VerificaLinhaI1: MOV R1, M[InimigoLinha]
                        CMP R1, R2
                        BR.NZ FimVerifica
                        ; verifica se a fileira 1 tem inimigos ativos
                        MOV R1, M[Inimigo1Ativo]
                        ADD R1, M[Inimigo2Ativo]
                        ADD R1, M[Inimigo3Ativo]
                        ADD R1, M[Inimigo4Ativo]
                        ADD R1, M[Inimigo5Ativo]
                        CMP R1, 0
                        BR.NZ AtingiuNAve
                        JMP FimVerifica

        AtingiuNAve:    MOV R1, 1                ; 1 = perde vida pq atingiram a nave
                        MOV M[EstadoJogo], R1

        FimVerifica:    MOV R1, 'W'              ; escrevem inimigos 
                        MOV M[ImprimeInimigo], R1    
                        CALL DesenhaInim

                        ; atualização do tiro
        Tiro:           MOV R1, M[TiroAtivo]
                        CMP R1, 1               ; tem tiro?
                        BR.Z AtualizaTiro       ; se sim, atualiza
                        JMP ReativaTimer        ; se não, pula atualização do tiro

             
        AtualizaTiro:     MOV R1, M[TiroLinha]
                          SHL R1, 8
                          MOV R2, M[TiroColuna]
                          OR  R1, R2
                          MOV M[CURSOR], R1
                          MOV R1, ' '             
                          MOV M[WRITE], R1

                          ; atualiza a posição
                          DEC M[TiroLinha]      

                          ; verifica se atingiu alguma linha dos inimigos
                          MOV R1, M[TiroLinha]
                          MOV R2, M[InimigoLinha]
                          CMP R1, R2              
                          BR.Z TestaInimigo1       

                          MOV R2, M[InimigoLinha2]
                          CMP R1, R2
                          BR.NZ TestaLinhaInim3
                          JMP TestaInimigo6

        TestaLinhaInim3:  MOV R2, M[InimigoLinha3]
                          CMP R1, R2
                          BR.NZ TestaTetoJmp
                          JMP TestaInimigo10

        TestaTetoJmp:     JMP TestaTeto            ; se nao atingiu, testa o teto
                       
                          ; testa se atingiiu os inimigos
        TestaInimigo1:    MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo1Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim1         
                          JMP TestaInimigo2        

                          ;verifica se a coluna é a mesma
        BateuInim1:      MOV R2, M[Inimigo1Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi1            
                          JMP TestaInimigo2        

                          ; destrói inimigo
        Destroi1:         MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo1Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo1Ativo], R0
                          MOV M[TiroAtivo], R0
                          JMP Pontuacao         

        TestaInimigo2:    MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo2Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim2         
                          JMP TestaInimigo3        

        BateuInim2:      MOV R2, M[Inimigo2Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi2            
                          JMP TestaInimigo3        

        Destroi2:         MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo2Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo2Ativo], R0
                          MOV M[TiroAtivo], R0
                          JMP Pontuacao         

        TestaInimigo3:    MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo3Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim3         
                          JMP TestaInimigo4        

        BateuInim3:      MOV R2, M[Inimigo3Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi3            
                          JMP TestaInimigo4        

        Destroi3:         MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo3Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo3Ativo], R0
                          MOV M[TiroAtivo], R0
                          JMP Pontuacao         

        TestaInimigo4:    MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo4Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim4         
                          JMP TestaInimigo5        

        BateuInim4:      MOV R2, M[Inimigo4Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi4            
                          JMP TestaInimigo5        

        Destroi4:         MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo4Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo4Ativo], R0
                          MOV M[TiroAtivo], R0
                          JMP Pontuacao         

        TestaInimigo5:    MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo5Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim5         
                          JMP TestaTeto            

        BateuInim5:      MOV R2, M[Inimigo5Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi5            
                          JMP TestaTeto            

        Destroi5:         MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo5Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo5Ativo], R0
                          MOV M[TiroAtivo], R0
                          JMP Pontuacao

        TestaInimigo6:    MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo6Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim6         
                          JMP TestaInimigo7            

        BateuInim6:      MOV R2, M[Inimigo6Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi6            
                          JMP TestaInimigo7            

        Destroi6:         MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo6Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo6Ativo], R0
                          MOV M[TiroAtivo], R0                  
                          JMP Pontuacao

        TestaInimigo7:    MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo7Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim7         
                          JMP TestaInimigo8            

        BateuInim7:      MOV R2, M[Inimigo7Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi7            
                          JMP TestaInimigo8           

        Destroi7:         MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo7Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo7Ativo], R0
                          MOV M[TiroAtivo], R0                  
                          JMP Pontuacao

        TestaInimigo8:    MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo8Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim8         
                          JMP TestaInimigo9            

        BateuInim8:      MOV R2, M[Inimigo8Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi8            
                          JMP TestaInimigo9         

        Destroi8:         MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo8Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo8Ativo], R0
                          MOV M[TiroAtivo], R0                  
                          JMP Pontuacao

        TestaInimigo9:    MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo9Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim9         
                          JMP TestaTeto            

        BateuInim9:      MOV R2, M[Inimigo9Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi9            
                          JMP TestaTeto            

        Destroi9:         MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo9Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo9Ativo], R0
                          MOV M[TiroAtivo], R0                  
                          JMP Pontuacao

        TestaInimigo10:   MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo10Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim10         
                          JMP TestaInimigo11            

        BateuInim10:     MOV R2, M[Inimigo10Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi10            
                          JMP TestaInimigo11           

        Destroi10:        MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo10Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo10Ativo], R0
                          MOV M[TiroAtivo], R0                  
                          JMP Pontuacao

        TestaInimigo11:   MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo11Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim11         
                          JMP TestaInimigo12            

        BateuInim11:     MOV R2, M[Inimigo11Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi11            
                          JMP TestaInimigo12         

        Destroi11:        MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo11Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo11Ativo], R0
                          MOV M[TiroAtivo], R0                  
                          JMP Pontuacao

        TestaInimigo12:   MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo12Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim12         
                          JMP TestaInimigo13            

        BateuInim12:     MOV R2, M[Inimigo12Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi12            
                          JMP TestaInimigo13           

        Destroi12:        MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo12Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo12Ativo], R0
                          MOV M[TiroAtivo], R0                  
                          JMP Pontuacao

        TestaInimigo13:   MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo13Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim13         
                          JMP TestaInimigo14            

        BateuInim13:     MOV R2, M[Inimigo13Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi13            
                          JMP TestaInimigo14         

        Destroi13:        MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo13Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo13Ativo], R0
                          MOV M[TiroAtivo], R0                  
                          JMP Pontuacao

        TestaInimigo14:   MOV R1, M[TiroColuna]
                          MOV R2, M[Inimigo14Ativo] 
                          CMP R2, 1
                          BR.Z BateuInim14         
                          JMP TestaTeto            

        BateuInim14:     MOV R2, M[Inimigo14Col]
                          INC R2                   
                          CMP R1, R2
                          BR.Z Destroi14            
                          JMP TestaTeto            

        Destroi14:        MOV R3, ' '              
                          MOV R1, M[TiroLinha]     
                          SHL R1, 8                
                          MOV R2, M[Inimigo14Col]   
                          
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1               
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3
                          INC R2                   
                          MOV R4, R1
                          OR  R4, R2               
                          MOV M[CURSOR], R4
                          MOV M[WRITE], R3

                          MOV M[Inimigo14Ativo], R0
                          MOV M[TiroAtivo], R0                  
                          JMP Pontuacao

                          ;Pontuação
                
                          ; adiciona o ponto na dezena
        Pontuacao:        INC M[PontosDezena]
                          MOV R1, M[PontosDezena]
                          CMP R1, 10             ; chegou a 10?
                          BR.NZ ImprimePlacar    ; se não, imprime

                          ; se a dezena chegar a 10
                          MOV R1, 0
                          MOV M[PontosDezena], R1 ; zera a dezena 
                          INC M[PontosCentena]    ; incrementa a centena

        
                          ; imprime a centena na coluna 9
        ImprimePlacar:    MOV R1, 1
                          SHL R1, 8
                          MOV R2, 9
                          OR  R1, R2    
                          MOV M[CURSOR], R1
                          MOV R2, M[PontosCentena]
                          ADD R2, '0'
                          MOV M[WRITE], R2

                          ; imprime a dezena na coluna 10
                          INC R1
                          MOV M[CURSOR], R1
                          MOV R2, M[PontosDezena]
                          ADD R2, '0'
                          MOV M[WRITE], R2

                          ; verifica se ganhou
                          DEC M[InimigosVivos]      ; decrementa 1 dos inimigos
                          MOV R1, M[InimigosVivos]  ; verifica se matou todos os inimigos
                          CMP R1, 0                 ; 
                          BR.NZ ContinuaJogo        ; se não, continua o jogo
                          
                          MOV R1, 2                 ; se matou, vitoria
                          MOV M[EstadoJogo], R1

        ContinuaJogo:     JMP ReativaTimer


                          ; verifica se bateu no teto
        TestaTeto:        MOV R1, M[TiroLinha]
                          CMP R1, 1
                          BR.NZ DesenhaTiro       
                          
                          ; se bater no limite da tela, morre o tiro
                          MOV R1, 0
                          MOV M[TiroAtivo], R1
                          JMP ReativaTimer        

                          ; desenha o tiro na posição nova
        DesenhaTiro:      MOV R1, M[TiroLinha]
                          SHL R1, 8
                          MOV R2, M[TiroColuna]
                          OR  R1, R2
                          MOV M[CURSOR], R1
                          MOV R1, '|'
                          MOV M[WRITE], R1

        ReativaTimer:   MOV R1, 1                ; controla a velocidade do processador. quanto maior, mais lento          
                        MOV M[TIMER_VAL], R1
                        MOV R1, 1           
                        MOV M[TIMER_CTRL], R1

                        POP R4
                        POP R3
                        POP R2              
                        POP R1
                        RTI                 
;-----------------------------------------------------------------------------------------

;------ Sub-rotinas ----------------------------------------------------------------------
        
                        ; desenha inimigos
        DesenhaInim:    MOV R1, M[Inimigo1Ativo]  ; verifica se inimigo esta ativo
                        CMP R1, 0               
                        BR.Z PulaDesenhoI1        ; se não estiver, pula o desenho desse inimigo

                        MOV R1, M[InimigoLinha]   ; se estiver ativo, imprime inimigo
                        SHL R1, 8
                        MOV R2, M[Inimigo1Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

                        ; vai para o inimigo 2 e assim por diante
        PulaDesenhoI1:  MOV R1, M[Inimigo2Ativo]
                        CMP R1, 0               
                        BR.Z PulaDesenhoI2      

                        MOV R1, M[InimigoLinha]
                        SHL R1, 8
                        MOV R2, M[Inimigo2Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

        PulaDesenhoI2:  MOV R1, M[Inimigo3Ativo]
                        CMP R1, 0               
                        BR.Z PulaDesenhoI3      

                        MOV R1, M[InimigoLinha]
                        SHL R1, 8
                        MOV R2, M[Inimigo3Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
               
        PulaDesenhoI3:  MOV R1, M[Inimigo4Ativo]
                        CMP R1, 0               
                        BR.Z PulaDesenhoI4      

                        MOV R1, M[InimigoLinha]
                        SHL R1, 8
                        MOV R2, M[Inimigo4Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                
        PulaDesenhoI4:  MOV R1, M[Inimigo5Ativo]
                        CMP R1, 0               
                        BR.Z PulaDesenhoI5      

                        MOV R1, M[InimigoLinha]
                        SHL R1, 8
                        MOV R2, M[Inimigo5Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

        PulaDesenhoI5:  MOV R1, M[Inimigo6Ativo]
                        CMP R1, 0               
                        BR.Z PulaDesenhoI6      

                        MOV R1, M[InimigoLinha2]
                        SHL R1, 8
                        MOV R2, M[Inimigo6Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

        PulaDesenhoI6:  MOV R1, M[Inimigo7Ativo]
                        CMP R1, 0               
                        BR.Z PulaDesenhoI7      

                        MOV R1, M[InimigoLinha2]
                        SHL R1, 8
                        MOV R2, M[Inimigo7Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

        PulaDesenhoI7:  MOV R1, M[Inimigo8Ativo]
                        CMP R1, 0               
                        BR.Z PulaDesenhoI8      

                        MOV R1, M[InimigoLinha2]
                        SHL R1, 8
                        MOV R2, M[Inimigo8Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

        PulaDesenhoI8:  MOV R1, M[Inimigo9Ativo]
                        CMP R1, 0       
                        BR.Z PulaDesenhoI9    

                        MOV R1, M[InimigoLinha2]
                        SHL R1, 8
                        MOV R2, M[Inimigo9Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

        PulaDesenhoI9:  MOV R1, M[Inimigo10Ativo]
                        CMP R1, 0       
                        BR.Z PulaDesenhoI10    

                        MOV R1, M[InimigoLinha3]
                        SHL R1, 8
                        MOV R2, M[Inimigo10Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

        PulaDesenhoI10: MOV R1, M[Inimigo11Ativo]
                        CMP R1, 0       
                        BR.Z PulaDesenhoI11    

                        MOV R1, M[InimigoLinha3]
                        SHL R1, 8
                        MOV R2, M[Inimigo11Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

        PulaDesenhoI11: MOV R1, M[Inimigo12Ativo]
                        CMP R1, 0       
                        BR.Z PulaDesenhoI12    

                        MOV R1, M[InimigoLinha3]
                        SHL R1, 8
                        MOV R2, M[Inimigo12Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

        PulaDesenhoI12: MOV R1, M[Inimigo13Ativo]
                        CMP R1, 0       
                        BR.Z PulaDesenhoI13    

                        MOV R1, M[InimigoLinha3]
                        SHL R1, 8
                        MOV R2, M[Inimigo13Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

        PulaDesenhoI13: MOV R1, M[Inimigo14Ativo]
                        CMP R1, 0       
                        BR.Z FimDesenhaFrota    

                        MOV R1, M[InimigoLinha3]
                        SHL R1, 8
                        MOV R2, M[Inimigo14Col]
                        OR R1, R2

                        MOV M[CURSOR], R1
                        MOV R2, M[ImprimeInimigo]
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

        FimDesenhaFrota:RET

                        ; imprime as vidas 
        Vidas:          MOV R1, 1
                        SHL R1, 8
                        MOV R2, 75
                        OR R1, R2
                        MOV M[CURSOR], R1
                        MOV R2, 'V'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, ':'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, M[NumeroVidas]
                        ADD R2, '0'          ;soma 48 que é o numero do 0 em ascii para corresponder ao valor correto
                        MOV M[WRITE], R2
                        RET

                       ; reseta a fase (reseta as variáveis)
        ResetFase:      MOV R1, 0
                        MOV M[TiroAtivo], R1

                        MOV R1, 3
                        MOV M[InimigoLinha], R1
                        MOV R1, 5
                        MOV M[InimigoLinha2], R1
                        MOV R1, 7
                        MOV M[InimigoLinha3], R1

                        MOV R1, 11
                        MOV M[Inimigo1Col], R1
                        MOV M[Inimigo10Col], R1
                        MOV R1, 25
                        MOV M[Inimigo2Col], R1
                        MOV M[Inimigo11Col], R1
                        MOV R1, 39
                        MOV M[Inimigo3Col], R1
                        MOV M[Inimigo12Col], R1
                        MOV R1, 53
                        MOV M[Inimigo4Col], R1
                        MOV M[Inimigo13Col], R1
                        MOV R1, 67
                        MOV M[Inimigo5Col], R1
                        MOV M[Inimigo14Col], R1

                        MOV R1, 17
                        MOV M[Inimigo6Col], R1
                        MOV R1, 31
                        MOV M[Inimigo7Col], R1
                        MOV R1, 45
                        MOV M[Inimigo8Col], R1
                        MOV R1, 59
                        MOV M[Inimigo9Col], R1

                        MOV R1, 1
                        MOV M[DirecaoInim], R1
                        MOV R1, 40
                        MOV M[NaveColuna], R1

                        CALL LimpaTela
                        CALL DesenhaInim
                        CALL Vidas
                        
                        MOV R1, M[NaveLinha]
                        SHL R1, 8
                        MOV R2, M[NaveColuna]
                        OR R1, R2
                        MOV M[CURSOR], R1
                        MOV R1, 'A'
                        MOV M[WRITE], R1
                        RET

                        ; zera os pontos, vida e define os inimigos como ativos
        ResetCompleto:  MOV R1, 3
                        MOV M[NumeroVidas], R1
                        MOV R1, 14
                        MOV M[InimigosVivos], R1
                        MOV R1, 0
                        MOV M[PontosDezena], R1
                        MOV M[PontosCentena], R1
                        
                        MOV R1, 1
                        MOV M[Inimigo1Ativo], R1
                        MOV M[Inimigo2Ativo], R1
                        MOV M[Inimigo3Ativo], R1
                        MOV M[Inimigo4Ativo], R1
                        MOV M[Inimigo5Ativo], R1
                        MOV M[Inimigo6Ativo], R1
                        MOV M[Inimigo7Ativo], R1
                        MOV M[Inimigo8Ativo], R1
                        MOV M[Inimigo9Ativo], R1
                        MOV M[Inimigo10Ativo], R1
                        MOV M[Inimigo11Ativo], R1
                        MOV M[Inimigo12Ativo], R1
                        MOV M[Inimigo13Ativo], R1
                        MOV M[Inimigo14Ativo], R1

                        ; zera o placar
                        MOV R1, 1
                        SHL R1, 8
                        MOV R2, 9
                        OR R1, R2
                        MOV M[CURSOR], R1
                        MOV R2, '0'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV M[WRITE], R2

                        CALL ResetFase
                        RET

                        ; limpa a area do jogo (linhas 3 a 22)
        LimpaTela:      MOV R1, 3
        LoopLimpaLinha: MOV R2, 1
        LoopLimpaCol:   MOV R3, R1
                        SHL R3, 8
                        OR R3, R2
                        MOV M[CURSOR], R3
                        MOV R4, ' '
                        MOV M[WRITE], R4
                        INC R2
                        CMP R2, 79
                        BR.NZ LoopLimpaCol
                        INC R1
                        CMP R1, 23
                        BR.NZ LoopLimpaLinha
                        RET

                        ; pausa o jogo ate apertas espaço
        Espaco:  MOV R1, M[STATUS]
                        CMP R1, 0
                        BR.Z Espaco
                        MOV R1, M[READ]
                        CMP R1, ' '
                        BR.NZ Espaco
                        RET
                        
                        ;imprime mensagem de game over 
        MensagemGameOver: CALL LimpaTela
                        MOV R1, 1
                        SHL R1, 8
                        MOV R2, 77
                        OR R1, R2
                        MOV M[CURSOR], R1
                        MOV R3, '0'
                        MOV M[WRITE], R3

                        MOV R1, 12
                        SHL R1, 8
                        MOV R2, 35
                        OR R1, R2
                        MOV M[CURSOR], R1
                        MOV R2, 'G'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'A'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'M'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'E'
                        MOV M[WRITE], R2
                        INC R1
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'O'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'V'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'E'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'R'
                        MOV M[WRITE], R2
                        RET

                        ; imprime mensagem de vitoria
        MensagemVitoria: CALL LimpaTela
                        MOV R1, 12
                        SHL R1, 8
                        MOV R2, 36
                        OR R1, R2
                        MOV M[CURSOR], R1
                        MOV R2, 'V'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'I'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'T'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'O'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'R'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'I'
                        MOV M[WRITE], R2
                        INC R1
                        MOV M[CURSOR], R1
                        MOV R2, 'A'
                        MOV M[WRITE], R2
                        RET                     
;-----------------------------------------------------------------------------------------

;------ ÁREA DE DADOS --------------------------------------------------------------------
        
        ORIG 8000h

        CURSOR      EQU FFFCh  ; variavel de cursor da tela
        WRITE       EQU FFFEh  ; variavel para imprimir na tela
        CURSOR_INIT EQU FFFFh  ; define q o cursor fica inicialmente na posição 00 e e q a tela esteja limpa
        STATUS      EQU FFFDh  ; indica se alguem apertou alguma tecla (=!0)
        READ        EQU FFFFh  ; variavel que lê do teclado
        TIMER_VAL   EQU FFF6h  ; define velocidade do tempo do cronometro 
        TIMER_CTRL  EQU FFF7h  ; liga(1)/desliga(0) o cronometro 

        NaveLinha   WORD 21    ; linha da nave 
        NaveColuna  WORD 40    ; coluna da nave

        TiroAtivo   WORD 0     ; define se o tiro esta ativo na tela
        TiroLinha   WORD 0     ; variavel para saber em qual liha o tiro esta
        TiroColuna  WORD 0     ; variavel para saber em qual coluna o tiro esta

        InimigoLinha WORD 3    ; linha inicial da primeira fila de inimigos
        Inimigo1Col  WORD 11    ; coluna dos inimigos
        Inimigo2Col  WORD 25
        Inimigo3Col  WORD 39
        Inimigo4Col  WORD 53
        Inimigo5Col  WORD 67

        InimigoLinha2 WORD 5   ; linha inicial da segunda fila de inimigos
        Inimigo6Col   WORD 17
        Inimigo7Col   WORD 31
        Inimigo8Col   WORD 45
        Inimigo9Col   WORD 59

        InimigoLinha3 WORD 7   ; linha inicial da terceira fila de inimigos
        Inimigo10Col  WORD 11
        Inimigo11Col  WORD 25
        Inimigo12Col  WORD 39
        Inimigo13Col  WORD 53
        Inimigo14Col  WORD 67

        Inimigo1Ativo  WORD 1   ; define se cada inimigos esta ativo ou nao, todos começam como ativos
        Inimigo2Ativo  WORD 1
        Inimigo3Ativo  WORD 1
        Inimigo4Ativo  WORD 1
        Inimigo5Ativo  WORD 1
        Inimigo6Ativo  WORD 1
        Inimigo7Ativo  WORD 1
        Inimigo8Ativo  WORD 1
        Inimigo9Ativo  WORD 1
        Inimigo10Ativo WORD 1
        Inimigo11Ativo WORD 1
        Inimigo12Ativo WORD 1
        Inimigo13Ativo WORD 1
        Inimigo14Ativo WORD 1

        PontosDezena      WORD 0     ; valor da dezena dos pontos
        PontosCentena     WORD 0     ; valor da centena dos pontos 

        DirecaoInim       WORD 1     ; define se os inimigos estao indo para direita(1) ou esquerda(0) 
        ImprimeInimigo    WORD 'W'   ; controla se imprime 'W' ou apaga inimigos' '         
        TimerInim         WORD 0      ; timer das naves inimigas

        NumeroVidas       WORD 3     ; Numero de vidas. começa com 3 vidas
        InimigosVivos     WORD 14    ; contador para a condição de vitória
        EstadoJogo        WORD 0     ; estado do jogo: Jogando(0), inimigos atingiram a nave(1), matou todos os inimigos (2)
;-----------------------------------------------------------------------------------------
