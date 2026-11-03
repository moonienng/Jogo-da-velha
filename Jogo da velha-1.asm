TITLE TICTACTOE
.MODEL SMALL
.STACK 100H
.DATA
    ;Mensagens do jogo

        ;cenários possíveis
        winj db 10,13,"O vencedor ",082h," o jogador $" ;na frente imprime o jogador que ganhou por dl
        empate db 10,13,"O jogo empatou$",10,13

        ;Instruções
        novamente db 10,13,"GOSTARIA DE JOGAR NOVAMENTE?[S/N]$"
        mdj db 10,13,"SELECIONE O MODO DE JOGO:",10,13,"1 - Jogador 1 X Jogador 2",10,13,"2 - Jogador X M",0A0h,"quina",10,13,"$"
        indlinha db 10,13,"INSIRA A LINHA DESEJADA:$"
        indcol db 10,13,"INSIRA A COLUNA DESEJADA:$"
        vez db 10,13,"Vez do jogador $"
    
        ;erros possíveis 

        erro1 db 10,13,"Modo de jogo inv",0A0h,"l",0A1h,"do. Tente novamente!$"
        erro2 db 10,13,"Posic",0A0h,"o inv",0A0h,"lida. Tente novamente!$"
    
        ;Definições de jogo
        N equ 3
        V equ 9
         jogo db N dup (' ')
              db N dup (' ')
              db N dup (' ')
        
.CODE 
    ;RESUMO E LÓGICA DO CÓDIGO
    MAIN PROC
        ;INICIALIZA O SEGUIMENTO DE DADOS
        MOV AX,@DATA
        MOV DS, AX

        INICIO:
            CALL CLRSCR
                ;EXIBE PRIMEIRAS MENSAGENS E SELEÇÃO DE MODO DE JOGO
                MOV AH, 09H
                LEA DX, mdj
                INT 21H

                ;LE O MODO DE JOGO
                MOV AH, 01H
                INT 21H

                AND AL,0FH

                ;SE 1 ENTÃO JOGADOR X JOGADOR -> MODO 1
                ;SE 2 ENTÃO JOGADOR X MAQUINA -> MODO 2
                ;SENÃO ERRO
                CMP AL, 1
                JE M1
                CMP AL, 2
                JE M2

                MOV AH,09H 
                LEA DX, erro1
                INT 21H
            JMP INICIO

            M1:
            CALL MODO1
            JMP FIM
            M2: 
            CALL MODO2
            
            FIM:
            MOV AH, 09
            LEA DX, novamente
            INT 21H

            MOV AH, 1
            INT 21H

            CMP AL, 'S'
            JE INICIO
            CMP AL, 's'
            JE INICIO
            cmp al, 'N'
            je acabar
            cmp al, 'n'
            je acabar
            jmp fim


            acabar:
            MOV AH, 4CH
            INT 21H
    MAIN ENDP

    ;JOGADOR X JOGADOR
    MODO1 PROC
        call limpatabuleiro
        XOR BX,BX
        XOR AX,AX
        XOR CX,CX
        XOR DX,DX
        ;LIMPOS

        MOV AL,2   
        MOV BL,1 

        MOV CX, V

        RODADA:
            CALL CLRSCR
            PUSH CX ;salva o contralador do loop
            XCHG AL,BL
            push ax
            mov ah, 9
            lea dx, vez
            int 21h
            pop ax
            push ax
            mov ah, 2
            mov dl, al
            add dl, 48
            int 21h
            pop ax
            PUSH AX
            PUSH BX
            CALL VER ;VERIFICA SE ALGUEM GANHOU
            CMP CX, '*'
            JE DVICC

            MOV AH,2
            MOV DL, 13
            INT 21H

            MOV AH, 2
            MOV DL, 10
            INT 21H
            CALL IMPTAB ;IMPRIME O TABULEIRO

            ;exibe mensagem pedindo o indice da linha
            leituraj:
            MOV AH,09
            LEA DX, indlinha
            INT 21H

            XOR CX,CX
            CALL LEPOSI ;PEDE O INDICE DA LINHA
            MOV SI,DX

            ;exibe mensagem pedindo o indice da coluna
            MOV AH,09
            LEA DX, indcol
            INT 21H
            
            INC CX
            CALL LEPOSI ;PEDE O INDICE DA COLUNA
            MOV DI,DX
            MOV BX,DI
                ADD BX,SI
                CMP jogo[BX], ' '
                JE FRJJ
                MOV AH, 9
                LEA DX, erro2
                int 21h
                jmp leituraj

            FRJJ:
            POP BX
            POP AX
           CALL OCPOSI ;OCUPA POSIÇÃO

            POP CX ;restaura o valor que controla do loop
        LOOP RODADA
            call ver
            cmp cx, '*'
            je dvicc
            jmp fmodo1
        DVICC:
        POP BX
        POP AX
        POP CX
        JMP fmodo1
        DEMP:
        mov ah, 09
        lea dx, empate
        int 21h

        fmodo1:
        call imptab
        RET
    MODO1 ENDP

    ;JOGADOR X MAQUINA
     MODO2 PROC
        call limpatabuleiro
         XOR BX,BX
         XOR AX,AX
         XOR CX,CX
         XOR DX,DX
         ;LIMPOS

         MOV AL,2
         MOV BL,1

         MOV CX, V

         RODADAJM:
              CALL CLRSCR
              PUSH CX ;salva o contralador do loop
              CALL VER ;VERIFICA SE ALGUEM GANHOU
             CMP CX, '*'
             JE DVICMQN

            ;pula uma linha
             PUSH AX
              MOV AH,2
              MOV DL, 13
              INT 21H

              MOV AH, 2
              MOV DL, 10
              INT 21H
              POP AX

              CALL IMPTAB ;IMPRIME O TABULEIRO

              XCHG AL,BL
              PUSH AX
              PUSH BX

              ;se for a rodada do jogador, então seguir o mesmo padrão de jogo do modo 1
              CMP AL,1
              JE VJOGADOR 
             ;SE FOR A RODADA DA MÁQUINA ENTÃO SEGUE O ALGORITMO DEFINIDO DA MAQUINA EM RMQN
              CALL RMQN
              JMP FRJM

             VJOGADOR:
                 ; ;exibe mensagem pedindo o indice da linha
                  LEITURAJM:
                  MOV AH,09
                  LEA DX, indlinha
                  INT 21H
                  
                  XOR CX,CX
                  CALL LEPOSI ;PEDE O INDICE DA LINHA
                  MOV SI,DX

                  ;exibe mensagem pedindo o indice da coluna
                  MOV AH,09
                  LEA DX, indcol
                  INT 21H
                
                  INC CX
                  CALL LEPOSI ;PEDE O INDICE DA COLUNA
                  MOV DI,DX
                  MOV BX,DI
                  ADD BX,SI
                  CMP jogo[BX], ' '
                  JE FRJM
                  MOV AH, 9
                  LEA DX, erro2
                  int 21h
                  jmp leiturajm

             FRJM:
             POP BX
             POP AX
             CALL OCPOSI ;OCUPA POSIÇÃO
             POP CX ;restaura o valor que controla do loop
         LOOP RODADAJM
            call ver
            cmp cx, '*'
            je fmodo2
        jmp DEMPJM
        DVICMQN:
        POP CX
        JMP fmodo2
         DEMPJM:
         mov ah, 09
         lea dx, empate
         int 21h

         fmodo2:
         CALL IMPTAB
         RET
     MODO2 ENDP

    ;VERIFICA SE HÁ VitÓRIA
    VER PROC
        PUSH BX
        PUSH AX
        XOR SI,SI ;0
        MOV CX, 3
        VERLINHA:
            XOR DI,DI ;0
            XOR BX,BX ;0
            CELULAVER:
                ADD SI, DI
                MOV Bl, jogo[SI] ;JOGO[0][0]
                CMP Bl, ' '
                JE FINALLINHA
                XOR AX,AX 
                MOV Al, jogo[SI + 1]
                CMP Bl,Al
                JNE FINALLINHA
                INC DI
                CMP DI, 2
            JNE CELULAVER
            CALL VIC 
            jmp fimVER
            FINALLINHA:
            ADD SI, 3
        LOOP VERLINHA
        XOR DI,DI ;0
        MOV CX, 3
        VERCOL:
            XOR SI,SI ;0
            XOR BX,BX ;0
            CELULAVERCOL:
                MOV Bl, jogo[DI] 
                CMP Bl, ' '
                JE FINALCOL
                XOR AX,AX 
                MOV Al, jogo[DI + 3] 
                CMP Bl,Al 
                JNE FINALCOL
                MOV Al, jogo[DI + 6] 
                CMP Bl,Al
                JNE FINALCOL
            CALL VIC 
            jmp fimVER
            FINALCOL: 
            INC DI
        LOOP VERCOL
        VERDIAG:
            MOV AL, jogo[4]
            CMP AL, ' '
            JE fimVER
            MOV DL, jogo[2]
            CMP DL, AL
            JE DIAG1
            VERDIAG2:
            MOV DL, jogo[0]
            CMP DL, AL
            JE DIAG2
            JMP fimVER
            DIAG1:
                MOV DL, jogo[6]
                CMP DL, AL
                JNE VERDIAG2
                JMP VITORIA
            DIAG2:
            MOV DL, jogo[8]
            CMP DL, AL
            JNE fimVER
            VITORIA:
            MOV BL, jogo[4]
            CALL VIC
        fimVER:
            POP AX
            POP BX
        RET
    VER ENDP


    VIC PROC
        PUSH AX
        MOV CX, '*'
        CMP BL, 'X'
        JE JG2
        MOV BL, '1'
        JMP IMPRIMEVIC
        JG2:
            MOV BL, '2'
        IMPRIMEVIC:
            MOV AH,09
            LEA DX, winj
            INT 21H

        MOV AH,2
        MOV DL,BL
        INT 21H
        POP AX
        RET
    VIC ENDP
    ;IMPRIME O TABULEIRO
    IMPTAB PROC
        
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    mov ah,2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    LEA BX, jogo      
    MOV CH, N
    dec ch


L1:  
    XOR SI, SI       
    MOV CL, N         
    MOV AH, 02
    dec cl
    MOV DL, ' '
    INT 21H
L2:     

    MOV DL, [BX + SI] ;
    INT 21H 
    
    ; Adiciona separador " | "
    PUSH DX
    MOV DL, ' '
    INT 21H
    MOV DL, '|'
    INT 21H  
    MOV DL, ' '
    INT 21H
    POP DX
    
    INC SI            ; próxima coluna
    DEC CL            ; decrementa contador de colunas
    JNZ L2            ; repete enquanto não termina a linha

    MOV DL, [BX + SI] ;
    INT 21H

    ; Remove o último " | " ou adiciona quebra de linha
    MOV AH, 02
    MOV DL, 13
    INT 21H
    MOV DL, 10
    INT 21H
    
    ; Adiciona linha separadora "-----------"
    MOV DL, ' '
    INT 21H
    PUSH CX
    MOV CX, 9        ; tamanho da linha
    MOV AH, 02
    MOV DL, '-'
    
SEPARADOR:

    INT 21H
    LOOP SEPARADOR
    POP CX
    
    MOV AH, 02
    MOV DL, 13
    INT 21H
    MOV DL, 10
    INT 21H
    
    ADD BX, N 
            
    
    DEC CH            ; decrementa linhas restantes
    JNZ L1            ; se não acabou, imprime a próxima
    ;-----------------------------------------
      
    XOR SI, SI       
    MOV CL, N         
    MOV AH, 02
    dec cl
    MOV DL, ' '
    INT 21H
               
    L3:     

    MOV DL, [BX + SI] ;
    INT 21H 
    
    ; Adiciona separador " | "
    PUSH DX
    MOV DL, ' '
    INT 21H
    MOV DL, '|'
    INT 21H  
    MOV DL, ' '
    INT 21H
    POP DX
    
    INC SI            ; próxima coluna
    DEC CL            ; decrementa contador de colunas
    JNZ L3            ; repete enquanto não termina a linha

    MOV DL, [BX + SI] ;
    INT 21H
    
    ; Remove o último " | " ou adiciona quebra de linha
    MOV AH, 02
    MOV DL, 13
    INT 21H
    MOV DL, 10
    INT 21H
    
    
    MOV AH, 02
    MOV DL, 13
    INT 21H
    MOV DL, 10
    INT 21H
    
    ADD BX, N 
            
    
    DEC CH            ; decrementa linhas restantes
    ;-----------------------------------------

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX 
    RET
IMPTAB ENDP

    ;RODADA DA MAQUINA
    ;simula as ações de um jogador
    RMQN PROC
        XOR SI,SI
        XOR DI,DI
       ;GARANTE SUA PRÓPRIA VITORIA
       MOV BL,'X'
       CALL VERMAQ
       CMP BL,0 ;BL É ALTERADO CASO ALGUMA POSSÍVEL VITORIA EXISTIR E VIRA 0
       JE FRMQN ;SE BL ZERO ENTÃO OCUPA A POSIÇÃO ALTERADA

       ;GARANTE A DERROTA IMINENTE DO JOGADOR 1
       MOV BL, 'O'
       CALL VERMAQ
       CMP BL,0 ;BL É ALTERADO CASO ALGUMA POSSÍVEL VITORIA EXISTIR E VIRA 0
       JE FRMQN ;SE BL ZERO ENTÃO OCUPA A POSIÇÃO ALTERADA

       ;OCUPA UMA POSIÇÃO ALEATÓRIA VAZIA
       CALL RANDNUM
       FRMQN:
        RET
    RMQN ENDP

    VERMAQ PROC
        ;VERIFICA POSSÍVEIS VITÓRIAS EM LINHAS, COLUNAS E DIAGONAIS
        ;RECEBE O SIMBOLO QUE VAI SER VERIFICADO EM BL
        ;ENTREGA A POSIÇÃO PRA SER OCUPADA EM SI
        PUSH AX
        PUSH CX
        PUSH DX
        XOR SI,SI ;ZERA DI PARA SER MANIPULADO
        MOV CX, 3 ; 3 LINHAS PRA VERIFICAR
        ;VERIFICA AS POSSÍVEIS VITÓRIAS NAS LINHAS
        LINHASMQN:
            MOV DI, 1 ;FIXA COLUNA 1 
            ADD DI, SI ;GERA O INDICE DO MEIO DA LINHA
            CMP jogo[DI], ' ' ;VERIFICA SE O MEIO TA VAZIO
            JE CASO1 ;VERIFICA AS LATERAIS DA LINHA SE O MEIO TÁ VAZIO
            ;SE PREENCHIDO
            CMP jogo[DI], BL ;VE SE O MEIO TEM O SIMBOLO QUE ESTA SENDO PROCURADO 
            ;SE SIM ENTÃO É HORA DE VERIFICAR SE ALGUÉM DO LADO É IGUAL
            JE CASO2
            JMP FLMQN
            CASO1:
                ;MEIO VAZIO
                MOV DL, jogo[DI - 1] 
                CMP DL, BL
                JNE FLMQN ;SE UMA DAS LATERAIS FOR DIFERENTE DO SIMBOLO PROCURADO E O MEIO ESTÁ VAZIO ENTÃO AQUELA LINHA NÃO TEM UMA POSSIVEL VITORIA
                MOV DL, jogo[DI + 1]
                CMP DL, BL
                JNE FLMQN ;SE UMA DAS LATERAIS FOR DIFERENTE DO SIMBOLO PROCURADO E O MEIO ESTÁ VAZIO ENTÃO AQUELA LINHA NÃO TEM UMA POSSIVEL VITORIA
                xor bx, bx
                MOV SI, DI
                XOR DI, DI
                JMP FVERMQNLIN
            CASO2:
                ;MEIO OCUPADO
                MOV DL, jogo[DI]
                CMP DL, BL
                JNE FLMQN ;O MEIO TEM QUE ESTAR OCUPADO COM O SIMBOLO PROCURADO, SENÃO ENTÃO PODE IR PRA PROXIMA LINHA
                MOV DL, jogo[DI + 1]
                CMP DL, BL ;COMPARA O DA FRENTE COM O SIMBOLO PROCURADO
                JNE CASO22 ;SE NÃO FOR IGUAL TEM A OUTRA LATERAL PRA VER
                
                MOV SI, DI
                DEC SI
                cmp jogo[si], ' '
                jne FVERMQNLIN
                xor bx, bx

                XOR DI,DI
                JMP FVERMQNLIN
            CASO22:
                MOV DL, jogo[DI - 1]
                CMP DL, BL ;COMPARA O DA FRENTE COM O SIMBOLO PROCURADO
                JNE FLMQN ;SE NÃO FOR IGUAL ENTÃO NÃO TEM POSSIVEL VITORIA NAQUELA LINHA
                
                MOV SI, DI
                INC SI
                cmp jogo[si], ' '
                jne fvermqnLIN
                xor bx, bx
                XOR DI,DI
                JMP FVERMQNLIN
            FLMQN:
            ADD SI, 3 ;SE NÃO FOR NENHUM DOS CASOS É HORA DE VERIFICAR A PROXIMA LINHA
            LOOP LINHASMQN
            FVERMQNLIN:
            CMP BX, 0
            JE FVERMQNCOL
          ;---------------------------------------------------------------------------------------------------------------
          XOR SI, SI
          MOV CX, 3
          COLUNASMQN:
            MOV DI, 3 ;FIXA LINHA 1 
            ADD DI, SI ;GERA O INDICE DO MEIO DA LINHA
            CMP jogo[DI], ' ' ;VERIFICA SE O MEIO TA VAZIO
            JE COLCASO1 ;VERIFICA AS LATERAIS DA LINHA SE O MEIO TÁ VAZIO
            ;SE PREENCHIDO
            CMP jogo[DI], BL ;VE SE O MEIO TEM O SIMBOLO QUE ESTA SENDO PROCURADO 
            ;SE SIM ENTÃO É HORA DE VERIFICAR SE ALGUÉM DO LADO É IGUAL
            JE COLCASO2
            JMP FCMQN
            COLCASO1:
                ;MEIO VAZIO
                MOV DL, jogo[DI - 3] 
                CMP DL, BL
                JNE FCMQN ;SE UMA DAS LATERAIS FOR DIFERENTE DO SIMBOLO PROCURADO E O MEIO ESTÁ VAZIO ENTÃO AQUELA LINHA NÃO TEM UMA POSSIVEL VITORIA
                MOV DL, jogo[DI + 3]
                CMP DL, BL
                JNE FCMQN ;SE UMA DAS LATERAIS FOR DIFERENTE DO SIMBOLO PROCURADO E O MEIO ESTÁ VAZIO ENTÃO AQUELA LINHA NÃO TEM UMA POSSIVEL VITORIA
                xor bx, bx
                MOV SI, DI
                XOR DI, DI
                JMP FVERMQNCOL

            COLCASO2:
                ;MEIO OCUPADO
                MOV DL, jogo[DI]
                CMP DL, BL
                JNE FCMQN ;O MEIO TEM QUE ESTAR OCUPADO COM O SIMBOLO PROCURADO, SENÃO ENTÃO PODE IR PRA PROXIMA LINHA
                MOV DL, jogo[DI + 3]
                CMP DL, BL ;COMPARA O DA FRENTE COM O SIMBOLO PROCURADO
                JNE COLCASO22 ;SE NÃO FOR IGUAL TEM A OUTRA LATERAL PRA VER
                
                MOV SI, DI
                SUB SI, 3
                cmp jogo[si], ' '
                jne fvermqnCOL
                xor bx, bx

                XOR DI,DI
                JMP FVERMQNCOL
            COLCASO22:
                MOV DL, jogo[DI - 3]
                CMP DL, BL ;COMPARA O DA FRENTE COM O SIMBOLO PROCURADO
                JNE FCMQN ;SE NÃO FOR IGUAL ENTÃO NÃO TEM POSSIVEL VITORIA NAQUELA LINHA
                
                MOV SI, DI
                ADD SI, 3
                cmp jogo[si], ' '
                jne fvermqnCOL
                xor bx, bx
                XOR DI,DI
                JMP FVERMQNCOL
            FCMQN:
            ADD SI, 1 ;SE NÃO FOR NENHUM DOS CASOS É HORA DE VERIFICAR A PROXIMA LINHA
            LOOP COLUNASMQN
            FVERMQNCOL:
            CMP BX, 0
            JE FVERMQNDIAG1
          ;---------------------------------------------------------------------------------------------------------------
          XOR SI,SI
          DIAG1MQN:
            MOV DI, 4 ;FIXA CENTRO
            CMP jogo[DI], ' ' ;VERIFICA SE O MEIO TA VAZIO
            JE DIAG1CASO1 ;VERIFICA AS LATERAIS DA LINHA SE O MEIO TÁ VAZIO
            ;SE PREENCHIDO
            CMP jogo[DI], BL ;VE SE O MEIO TEM O SIMBOLO QUE ESTA SENDO PROCURADO 
            ;SE SIM ENTÃO É HORA DE VERIFICAR SE ALGUÉM DO LADO É IGUAL
            JE DIAG1CASO2
            JMP FD1MQN
            DIAG1CASO1:
                ;MEIO VAZIO
                MOV DL, jogo[DI - 4] 
                CMP DL, BL
                JNE FD1MQN ;SE UMA DAS LATERAIS FOR DIFERENTE DO SIMBOLO PROCURADO E O MEIO ESTÁ VAZIO ENTÃO AQUELA LINHA NÃO TEM UMA POSSIVEL VITORIA
                MOV DL, jogo[DI + 4]
                CMP DL, BL
                
                JNE FD1MQN ;SE UMA DAS LATERAIS FOR DIFERENTE DO SIMBOLO PROCURADO E O MEIO ESTÁ VAZIO ENTÃO AQUELA LINHA NÃO TEM UMA POSSIVEL VITORIA
                xor bx, bx
                MOV SI, DI
                XOR DI, DI
                JMP FVERMQNDIAG1

            DIAG1CASO2:
                ;MEIO OCUPADO
                MOV DL, jogo[DI]
                CMP DL, BL
                JNE FD1MQN ;O MEIO TEM QUE ESTAR OCUPADO COM O SIMBOLO PROCURADO, SENÃO ENTÃO PODE IR PRA PROXIMA LINHA
                MOV DL, jogo[DI + 4]
                CMP DL, BL ;COMPARA O DA FRENTE COM O SIMBOLO PROCURADO
                JNE DIAG1CASO22 ;SE NÃO FOR IGUAL TEM A OUTRA LATERAL PRA VER
                
                MOV SI, DI
                SUB SI, 4
                cmp jogo[si], ' '
                jne fvermqnDIAG1
                xor bx, bx

                XOR DI,DI
                JMP FVERMQNDIAG1
            DIAG1CASO22:
                MOV DL, jogo[DI - 4]
                CMP DL, BL ;COMPARA O DA FRENTE COM O SIMBOLO PROCURADO
                JNE FD1MQN ;SE NÃO FOR IGUAL ENTÃO NÃO TEM POSSIVEL VITORIA NAQUELA LINHA
                
                MOV SI, DI
                ADD SI, 4
                cmp jogo[si], ' '
                jne fvermqnDIAG1
                xor bx, bx
                XOR DI,DI
                JMP FVERMQNDIAG1
            FD1MQN:
            FVERMQNDIAG1:
            CMP BX, 0
            JE FVERMQNDIAG2

          XOR SI,SI
          DIAG2MQN:
            MOV DI, 4 ;FIXA CENTRO
            CMP jogo[DI], ' ' ;VERIFICA SE O MEIO TA VAZIO
            JE DIAG2CASO1 ;VERIFICA AS LATERAIS DA LINHA SE O MEIO TÁ VAZIO
            ;SE PREENCHIDO
            CMP jogo[DI], BL ;VE SE O MEIO TEM O SIMBOLO QUE ESTA SENDO PROCURADO 
            ;SE SIM ENTÃO É HORA DE VERIFICAR SE ALGUÉM DO LADO É IGUAL
            JE DIAG2CASO2
            JMP FD2MQN
            DIAG2CASO1:
                ;MEIO VAZIO
                MOV DL, jogo[DI - 2] 
                CMP DL, BL
                JNE FD2MQN ;SE UMA DAS LATERAIS FOR DIFERENTE DO SIMBOLO PROCURADO E O MEIO ESTÁ VAZIO ENTÃO AQUELA LINHA NÃO TEM UMA POSSIVEL VITORIA
                MOV DL, jogo[DI + 2]
                CMP DL, BL
                
                JNE FD2MQN ;SE UMA DAS LATERAIS FOR DIFERENTE DO SIMBOLO PROCURADO E O MEIO ESTÁ VAZIO ENTÃO AQUELA LINHA NÃO TEM UMA POSSIVEL VITORIA
                xor bx, bx
                MOV SI, DI
                XOR DI, DI
                JMP FVERMQNDIAG2

            DIAG2CASO2:
                ;MEIO OCUPADO
                MOV DL, jogo[DI]
                CMP DL, BL
                JNE FD2MQN ;O MEIO TEM QUE ESTAR OCUPADO COM O SIMBOLO PROCURADO, SENÃO ENTÃO PODE IR PRA PROXIMA LINHA
                MOV DL, jogo[DI + 2]
                CMP DL, BL ;COMPARA O DA FRENTE COM O SIMBOLO PROCURADO
                JNE DIAG2CASO22 ;SE NÃO FOR IGUAL TEM A OUTRA LATERAL PRA VER
                
                MOV SI, DI
                SUB SI, 2
                cmp jogo[si], ' '
                jne fvermqnDIAG2
                xor bx, bx

                XOR DI,DI
                JMP FVERMQNDIAG2
            DIAG2CASO22:
                MOV DL, jogo[DI - 2]
                CMP DL, BL ;COMPARA O DA FRENTE COM O SIMBOLO PROCURADO
                JNE FD2MQN ;SE NÃO FOR IGUAL ENTÃO NÃO TEM POSSIVEL VITORIA NAQUELA LINHA
                
                MOV SI, DI
                ADD SI, 2
                cmp jogo[si], ' '
                jne fvermqnDIAG2
                xor bx, bx
                XOR DI,DI
                JMP FVERMQNDIAG2
            FD2MQN:
            FVERMQNDIAG2:
            ;---------------------------------------------------------------------------------------------------------------
         FVERMQN:
            
            POP DX
            POP CX
            POP AX
            RET
    VERMAQ ENDP

    ;gera um número aleatório não preenchido pra maquina jogar
    ;usamos a int 1Ah pra gerar uma semente
    ;devolve a posição em si e di zerado para fazer o indice
    RANDNUM PROC
        RANDGEN:
        PUSH AX
        PUSH DX
        PUSH CX 
        XOR AX, AX
        XOR DX, DX
        XOR CX, CX
      
        RANDSTART:
            INT 1AH   ;semente      

            mov  ax, dx
            xor  dx, dx
            mov  cx, 10
            div  cx      

            cmp dx, 9
            je RANDSTART
            XOR DI,DI
            MOV si, dx 

            cmp jogo[SI], ' '
            jne RANDSTART

            POP CX
            POP DX
            POP AX
            RET
RANDNUM ENDP
    ;lE POSIÇÃO DO JOGADOR
    LEPOSI PROC
        PUSH AX
        PUSH BX
        LELIN:
        ;LEITURA DO INDICE

        ;captura um caracter
        MOV AH,1
        INT 21H

        AND AL,0FH

        CMP AL,3
        JA LELIN
        CMP AL,1
        JB LELIN
        ;GARANTE QUE O NÚMERO DIGITADO ESTA ENTRE 1 E 3
        
        DEC AL ;TRANFORMA AL EM UM INDICE 

        CMP CX,1 ;VE SE A LEITURA É UMA COLUNA
        JE FINALL ;SE FOR COLUNA O DEC AL FOI SUFICIENTE 

        MOV BL,3
        MUL BL
        ;A LEITURA É DE UMA LINHA LOGO PARA SER O INDICE CERTO MULTIPLICA POR 3

        FINALL:
        XOR DX,DX
        MOV DL,AL
        POP BX
        POP AX
        RET
    LEPOSI ENDP

    ;OCUPA A POSIÇÃO
    ;recebe a posição da linha em si e da coluna em di
    ;altera jogo[si][di] 
    OCPOSI PROC
        ;empilha
        PUSH BX
        PUSH AX

        ;onde vemos quem vai realmente achar quem que vai ocupar a posição
        CMP AL, 1
        JE JOG1 ;se jogador 1 então o al recebe o simbolo do jogador 2
        MOV AL, 'X' ;não sendo o caso vai ser o simbolo do jogador 1
        JMP OCUP 
        JOG1:
        MOV AL, 'O'
        ;onde a posição realmente vai ser ocupada
        OCUP:
        MOV BX, SI
        ADD BX, DI ;cria o indice da matriz
        MOV jogo[BX], AL ;coloca o simbolo do jogador dentro da posição selecionada

        ;desempilha
        POP AX
        POP BX
        RET
    OCPOSI ENDP
    
    ;LIMPA A TELA
    ;não recebe nada
    ;não devolve nada
    ;só limpa
    ;e coloca o cursor no lugar certo
    CLRSCR PROC
        ;limpa a tela usando 10h 
        ;empilha pra não bagunçar
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        ; Função 06h – Scroll up toda a janela preenchendo com espaço
        MOV AH, 06h     ; função scroll up
        MOV AL, 0       ; AL = 0 → limpar toda a tela
        MOV BH, 07h     ; atributo (cinza claro sobre preto)
        MOV CX, 0000h   ; canto superior esquerdo (linha 0, coluna 0)
        MOV DX, 184Fh   ; canto inferior direito (linha 24, coluna 79)
        INT 10h ; Int 10h é uma interrupção que manipula vídeo

        ; reposiciona cursor no canto superior
        MOV AH, 02h
        MOV BH, 0
        MOV DX, 0000h
        INT 10h

        ;desempilha
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    CLRSCR ENDP

    ;pra garantir que não vá interferir nas jogadas depois da primeira
    limpatabuleiro proc
        push bx
        push cx
        ;empilha pra não bagunçar nada
        xor bx,bx ;jogo[0]
        mov cx, V ;cx=9 pq tem 9 lugares na matriz
        faxina:
            mov jogo[bx], ' '
            inc bx
        loop faxina ;limpa todos os espaços de jogo
        pop bx
        pop cx
        ;desempilha
        ret
    limpatabuleiro endp
END MAIN