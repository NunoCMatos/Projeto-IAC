; ******************************************************************************
; * IST-UL
; * Alunos: Nuno Correia de Matos - 105990
;           Duarte Ramires - 107090
;           Francisco Pinto - 106817
;
; * PROJETO
; * Descrição: Este programa corresponde à primeira fase do
;              projeto "Beyond Mars"
; ******************************************************************************


; **********************************************************************
; * Constantes
; **********************************************************************

; **********************************************************************
; * MediaCenter
; **********************************************************************
COMANDOS                    EQU 6000H   ; endereço base dos comandos do MediaCenter
APAGA_ECRA	 		        EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
DEFINE_ECRA                 EQU COMANDOS + 04H      ; endereço do comando para definir o ecrâ
DEFINE_LINHA    	        EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   	        EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
OBTEM_PIXEL                 EQU COMANDOS + 10H      
DEFINE_PIXEL                EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     	        EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
SELECIONA_CENARIO_FUNDO     EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
APAGA_ECRA_FRONTAL          EQU COMANDOS + 44H
SELECIONA_CENARIO_FRONTAL   EQU COMANDOS + 46H
TOCA_SOM                    EQU COMANDOS + 5AH		; endereço do comando para tocar um som
REPRODUZ_VIDEO              EQU COMANDOS + 5CH
PAUSA_VIDEO                 EQU COMANDOS + 62H
RETOMA_VIDEO                EQU COMANDOS + 64H
APAGA_VIDEO                 EQU COMANDOS + 68H

MIN_LINHA   EQU 0       ; número da coluna mais à esquerda do ecrã
MIN_COLUNA  EQU 0		; número da coluna mais à esquerda do ecrã
MAX_LINHA   EQU 32      ; número da coluna mais à direita do ecrã
MAX_COLUNA  EQU 64      ; número da coluna mais à direita do ecrã
ATRASO      EQU 10H     ; atraso para limitar a velocidade de movimento do boneco

; **********************************************************************
; * Periféricos
; **********************************************************************
DISPLAYS    EQU 0A000H  ; endereço dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN     EQU 0C000H  ; endereço das linhas do teclado (perif�rico POUT-2)
TEC_COL     EQU 0E000H  ; endereço das colunas do teclado (perif�rico PIN)
INCREMENTA  EQU 01H     ; tecla que incrementa o contador
DECREMENTA  EQU 00H     ; tecla que decrementa o contador
C_LINHA     EQU 10H     ; número para o ciclo de varrimento do teclado

; **********************************************************************
; * Máscaras
; **********************************************************************
ISOLA_03BITS    EQU 0FH  ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
ISOLA_07BITS    EQU 0FFH ; para isolar os 8 bits de maior peso

; **********************************************************************
; * Figuras
; **********************************************************************
; * Coordenadas
SPAWN_LIN   EQU 0       ; linha dos spawnpoints dos meteoros
SPAWN1_COL  EQU 0       ; coluna do 1.º spawnpoint (canto superior esquerdo)
SPAWN2_COL  EQU 30      ; coluna do 2.º spawnpoint (centro superior)
SPAWN3_COL  EQU 59      ; coluna do 3.º spawnpoint (canto superior direito)

SPAWN_SND_LIN   EQU 26  ; linhas dos spawnpoints das sondas
SPAWN1_SND_COL  EQU 26  ; coluna do 1.º spawnpoint (esquerda do painel)
SPAWN2_SND_COL  EQU 32  ; coluna do 2.º spawnpoint (meio do painel)
SPAWN3_SND_COL  EQU 38  ; coluna do 3.º spawnpoint (direita do painel)

LIN_PAINEL          EQU 27      ; linha do painel da nave
LIN_LUZES_PAINEL    EQU 29      ; linha das luzes do painel da nave
COL_PAINEL          EQU 25      ; coluna do painel da nave
COL_LUZES_PAINEL    EQU 29      ; coluna das luzes do painel da nave

; * Tamanhos
LARGURA             EQU 5   ; largura dos meteoros (mineráveis ou não)
ALTURA              EQU 5   ; altura dos meteoros (mineráveis ou não)
LAR_PAINEL          EQU 15  ; largura do painel da nave
ALT_PAINEL          EQU 5   ; altura do painel da nave
LAR_LUZES_PAINEL    EQU 7   ; largura das luzes do painel
ALT_LUZES_PAINEL    EQU 2   ; altura das luzes do painel
LAR_SONDA           EQU 1   ; largura das sondas
ALT_SONDA           EQU 1   ; altura das sondas

; * Cores
VERMELHO    EQU 0FF00H
VERDE       EQU 0F0F0H
AZUL        EQU 0F0FFH
AMARELO     EQU 0FFF0H
CASTANHO    EQU 0FAA6H
ROSA        EQU 0FF0FH
CINZENTO    EQU 0F777H
APAGADO     EQU 0000H

N_METEOROS      EQU 4H      ; numero de meteoros
N_SONDAS        EQU 3H      ; numero de sondas
PASSOS_SONDA    EQU 12      ; numero de posicoes de cada sonda
ENERGIA_INICIAL EQU 100H    ; valor inicial de energia

; **********************************************************************
; * Dados
; **********************************************************************

PLACE 1000H

; * Pilhas

    STACK 100H          ; espaço reservado para a pilha do processo "programa principal"
SP_inicial:             ; endereço da pilha

    STACK 100H          ; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:     ; endereço da pilha

    STACK 100H          ; espaço reservado para a pilha do processo "controlo"
SP_inicial_controlo:    ; endereço da pilha

    STACK 100H          ; espaço reservado para a pilha do processo "painel nave"
SP_inicial_nave:        ; endereço da pilha

    STACK 100H          ; espaço reservado para a pilha do processo "meteoro"
SP_inicial_meteoro_0:   ; endereço da pilha

    STACK 100H          
SP_inicial_meteoro_1:

    STACK 100H          
SP_inicial_meteoro_2:

    STACK 100H          
SP_inicial_meteoro_3:

    STACK 100H          ; espaço reservado para a pilha do processo "sonda"
SP_inicial_sonda_0:     ; endereço da pilha

    STACK 100H          
SP_inicial_sonda_1:

    STACK 100H          
SP_inicial_sonda_2:

    STACK 100H          ; espaço reservado para a pilha do processo "energia"
SP_inicial_energia:     ; endereço da pilha

    STACK 100H
SP_pausa:

tab:
    WORD int_meteoro            ; rotina de atendimento da interrupção 0
    WORD int_sonda              ; rotina de atendimento da interrupção 1
    WORD int_energia            ; rotina de atendimento da interrupção 2
    WORD int_luzes_painel       ; rotina de atendimento da interrupção 3

; * Definições

; * definicao_do_boneco:
; *     tamanho do boneco (altura e largura)
; *     cores dos pixeis
; *

DEF_MET_MIN:
    WORD ALTURA, LARGURA
    WORD     0, VERDE, VERDE, VERDE, 0
    WORD VERDE, VERDE, VERDE, VERDE, VERDE
    WORD VERDE, VERDE, VERDE, VERDE, VERDE
    WORD VERDE, VERDE, VERDE, VERDE, VERDE
    WORD     0, VERDE, VERDE, VERDE, 0

DEF_MET_MIN_EXP1:
    WORD ALTURA, LARGURA
    WORD 0, 0, 0, 0, 0
    WORD 0, VERDE, VERDE, VERDE, 0
    WORD 0, VERDE, VERDE, VERDE, 0
    WORD 0, VERDE, VERDE, VERDE, 0
    WORD 0, 0, 0, 0, 0

DEF_MET_MIN_EXP2:
    WORD ALTURA, LARGURA
    WORD 0, 0, 0, 0, 0
    WORD 0, 0, 0, 0, 0
    WORD 0, 0, VERDE, 0, 0
    WORD 0, 0, 0, 0, 0
    WORD 0, 0, 0, 0, 0

DEF_MET_NMIN:
    WORD ALTURA, LARGURA
    WORD VERMELHO, 0, VERMELHO, 0, VERMELHO
    WORD 0, VERMELHO, VERMELHO, VERMELHO, 0
    WORD VERMELHO, VERMELHO, 0, VERMELHO, VERMELHO
    WORD 0, VERMELHO, VERMELHO, VERMELHO, 0
    WORD VERMELHO, 0, VERMELHO, 0, VERMELHO

DEF_EXPLOSAO:
    WORD ALTURA, LARGURA
    WORD 0, AZUL, 0, AZUL, 0
    WORD AZUL, 0, AZUL, 0, AZUL
    WORD 0, AZUL, 0, AZUL, 0
    WORD AZUL, 0, AZUL, 0, AZUL
    WORD 0, AZUL, 0, AZUL, 0

DEF_PAINEL:
    WORD ALT_PAINEL, LAR_PAINEL
    WORD 0, 0, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, 0, 0
    WORD 0, VERMELHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, VERMELHO, 0
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO,  0, 0, 0, 0, 0, 0, 0, CASTANHO, CASTANHO, CASTANHO, VERMELHO
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO, 0, 0, 0, 0, 0, 0, 0, CASTANHO, CASTANHO, CASTANHO, VERMELHO
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, VERMELHO

DEF_LUZES_PAINEL1:
    WORD ALT_LUZES_PAINEL, LAR_LUZES_PAINEL
    WORD CINZENTO, AMARELO, VERMELHO, AZUL, VERDE, VERDE, VERMELHO
    WORD AMARELO, VERDE, VERMELHO, AMARELO, AZUL, CINZENTO, AZUL

DEF_LUZES_PAINEL2:
    WORD ALT_LUZES_PAINEL, LAR_LUZES_PAINEL
    WORD VERMELHO, VERDE, AMARELO, AZUL, CINZENTO, CINZENTO, VERDE
    WORD CINZENTO, CINZENTO, VERDE, VERMELHO, AMARELO, AZUL, VERMELHO

DEF_LUZES_PAINEL3:
    WORD ALT_LUZES_PAINEL, LAR_LUZES_PAINEL
    WORD AMARELO, VERDE, VERMELHO, VERDE, CINZENTO, VERMELHO, AZUL
    WORD VERDE, CINZENTO, CINZENTO, VERDE, AMARELO, AZUL, VERMELHO

DEF_LUZES_PAINEL4:
    WORD ALT_LUZES_PAINEL, LAR_LUZES_PAINEL
    WORD VERDE, AMARELO, AZUL, VERMELHO, VERDE, CINZENTO, AZUL
    WORD VERMELHO, AMARELO, VERMELHO, AMARELO, VERDE, AZUL, CINZENTO

DEF_LUZES_PAINEL5:
    WORD ALT_LUZES_PAINEL, LAR_LUZES_PAINEL
    WORD AZUL, CINZENTO, CINZENTO, VERDE, VERMELHO, VERDE, AMARELO
    WORD AZUL, AMARELO, VERMELHO, VERDE, VERDE, CINZENTO, AZUL

DEF_LUZES_PAINEL6:
    WORD ALT_LUZES_PAINEL, LAR_LUZES_PAINEL
    WORD CINZENTO, VERMELHO, VERMELHO, CINZENTO, AMARELO, VERDE, AZUL
    WORD CINZENTO, CINZENTO, VERDE, AZUL, VERMELHO, VERDE, CINZENTO

DEF_LUZES_PAINEL7:
    WORD ALT_LUZES_PAINEL, LAR_LUZES_PAINEL
    WORD VERDE, CINZENTO, CINZENTO, VERDE, AMARELO, AMARELO, AZUL
    WORD CINZENTO, AMARELO, VERMELHO, VERMELHO, VERDE, CINZENTO, VERMELHO

DEF_LUZES_PAINEL8:
    WORD ALT_LUZES_PAINEL, LAR_LUZES_PAINEL
    WORD CINZENTO, AZUL, CINZENTO, VERMELHO, AZUL, AMARELO, VERDE
    WORD AZUL, AMARELO, VERDE, CINZENTO, CINZENTO, AZUL, AMARELO 

DEF_SONDA:
    WORD ALT_SONDA, LAR_SONDA
    WORD ROSA

METEORO_FUNCAO: ; estado do meteoro (-1 - INEXISTENTE, 0 - BOM, 1 - MAU)
    WORD -1
    WORD -1
    WORD -1
    WORD -1

METEORO_LINHA:
    WORD 0
    WORD 0
    WORD 0
    WORD 0

METEORO_COLUNA:
    WORD 0
    WORD 0
    WORD 0
    WORD 0

esquerda_meteoro:
    WORD SPAWN1_COL, +1     ; canto superior esquerdo, move para a direita

centro_esquerda_meteoro:
    WORD SPAWN2_COL, -1     ; centro, move para a esquerda

centro_meteoro:
    WORD SPAWN2_COL, 0      ; centro, nao mexe nas colunas

centro_direita_meteoro:
    WORD SPAWN2_COL, +1     ; centro, move para a direita

direita_meteoro:
    WORD SPAWN3_COL, -1     ; canto superior direito, move para a esquerda

POSICOES_METEORO:
    WORD esquerda_meteoro
    WORD centro_esquerda_meteoro
    WORD centro_meteoro
    WORD centro_direita_meteoro
    WORD direita_meteoro

SONDAS:      ; (0 - INEXISTENTE, 1 - EXISTENTE)
    WORD 0  ; esquerda
    WORD 0  ; centro
    WORD 0  ; direita

esquerda_sonda:
    WORD SPAWN1_SND_COL, -1

centro_sonda:
    WORD SPAWN2_SND_COL, 0

direita_sonda:
    WORD SPAWN3_SND_COL, +1
    
POSICOES_SONDA:
    WORD esquerda_sonda
    WORD centro_sonda
    WORD direita_sonda

energia:            WORD ENERGIA_INICIAL    ; energia da nave
INICIO_JOGO:        WORD 1                  ; flag que indica se estamos no início do jogo
GAME_OVER:          LOCK 0                  ; flag que indica se o jogo acabou e como acabou
luzes_painel:       LOCK 0                  ; flag para a mudanca das luzes do painel
tecla_carregada:    LOCK 0                  ; flag de tecla carregada
anima_meteoro:      LOCK 0                  ; flag para o movimento do meteoro
anima_sonda:        LOCK 0                  ; flag para o movimento da sonda
decresce_energia:   LOCK 0                  ; flag de decrescimento de energia


; **********************************************************************
; * Código
; **********************************************************************

PLACE 0

; corpo principal do programa

inicializacoes:
    ; * Stack Pointer
    MOV SP, SP_inicial  ; Inicialização do Stack Pointer
    MOV BTE, tab

    EI0
    EI1
    EI2
    EI3
    EI

cria_bonecos:
    CALL repoe_jogo
    CALL inicio_controlo  
    CALL inicio_energia
    CALL inicio_painel
    CALL inicio_teclado

    MOV R11, N_METEOROS
    SUB R11, 1          ; contar com o meteoro 0
    cria_meteoros:
        CALL inicio_meteoro
        SUB R11, 1
        JNN cria_meteoros

    MOV R11, N_SONDAS
    SUB R11, 1          ; contar com a sonda 0
    cria_sondas:
        CALL inicio_sonda
        SUB R11, 1
        JNN cria_sondas

fim:
    YIELD
    JMP fim    ; volta a espera que não haja tecla carregada


; **********************************************************************
; Processo
;
; Controlo - Processo responsavel por tratar das teclas de começar, 
;            pausar e terminar o jogo.
;
; **********************************************************************

PROCESS SP_inicial_controlo
    inicio_controlo:
    MOV R1, [INICIO_JOGO]       ; coloca em R1 se estamos no início do jogo 
    CMP R1, 1                   ; verifica se estamos no início do jogo
    JNZ running                  ; se não, salta para o ciclo de jogo
        start:                  ; iníco do jogo
            MOV R1, 0
            MOV [INICIO_JOGO], R1                   ; altera a flag de inicio de jogo para não voltar a entrar em start
            tela_inicial:
                MOV [APAGA_AVISO], R0	            ; apaga o aviso do ecrã
                MOV [APAGA_ECRA], R0	            ; apaga todos os pixels já desenhados
                MOV [APAGA_ECRA_FRONTAL], R0
                MOV R0, 0
                MOV [DISPLAYS], R0
                MOV R0, 1                           ; tela inicial (fundo número 1)
                MOV [SELECIONA_CENARIO_FUNDO], R0   ; seleciona o cenário de fundo
                MOV R6, 8                           ; quarta linha
                MOV R1, 1                           ; primeira coluna
                
            espera_c:                         
                CALL teclado
                CMP  R0, R1                          ;verifica se foi pressionada a tecla C
                JNZ  espera_c

        CALL reseta_energia
        CALL escreve_energia
        running:                                ; ciclo do jogo 
            MOV R0, 0                           ; cenário de fundo número 0
            MOV [REPRODUZ_VIDEO], R0   ; seleciona o cenário de fundo
            MOV R0, [GAME_OVER]                 ; le a flag
            CMP R0, 0                           ; verifica se foi alterada
            JZ inicio_controlo                         ; se nao foi alterada, continua o jogo
            CMP R0, 1                           ; se foi alterada para 1, o jogo foi colocado em pausa
            JZ pausa
            CMP R0, 2                           ; se foi alterada para 2, o jogo foi perdido devido a uma colisão
            JZ derrota_colisao
            CMP R0, 3                           ; se foi alterada para 3, o jogo foi perdido devido a acabar a energia
            JZ derrota_energia
            CMP R0, 4                           ; se foi alterada para 4, o jogo foi terminado manualmente
            JZ terminado

        pausa:
            MOV R6, 0
            MOV [GAME_OVER], R6                 ; flag volta a 0 para que quando o programa saia deste ciclo saber que pode voltar ao jogo principal
            MOV R0, 5                           ; tela de pausa (fundo número 5)
            MOV [PAUSA_VIDEO], R0
            MOV [SELECIONA_CENARIO_FRONTAL], R0   ; seleciona o cenário de fundo
            MOV R6, 8                           ; quarta linha
            MOV R1, 2                           ; segunda coluna
            CALL espera_nao_tecla
            testa_D:
                CALL teclado
                MOV  R1, 4
                CMP  R0, R1
                JZ running
                SHR  R1, 1
                CMP  R0, R1                         ; verifica se foi pressionada a tecla D
                JNZ testa_D
            acaba_pausa:
                CALL espera_nao_tecla
                MOV [APAGA_ECRA_FRONTAL], R0	            ; apaga todos os pixels já desenhados
                JMP running

        derrota_colisao:
            MOV R6, 0
            MOV [GAME_OVER], R6                 ; flag volta a 0 para que quando o programa saia deste ciclo saber que pode voltar ao jogo principal
            MOV [APAGA_ECRA], R0                ; apaga todos os pixels já desenhados
            MOV R0, 2                           ; tela inicial (fundo número 2)
            MOV [SELECIONA_CENARIO_FUNDO], R0   ; seleciona o cenário de fundo
            MOV R6, 8                           ; quarta linha
            MOV R1, 1                           ; primeira coluna
            testa_C_colisao:
                CALL teclado
                CMP  R0, R1                         ; verifica se foi pressionada a tecla C
                JNZ testa_C_colisao
            acaba_der_colisao:
                JMP start

        derrota_energia:
            MOV R6, 0
            MOV [GAME_OVER], R6                 ; flag volta a 0 para que quando o programa saia deste ciclo saber que pode voltar ao jogo principal
            MOV [APAGA_ECRA], R0                ; apaga todos os pixels já desenhados
            MOV R0, 3                           ; tela inicial (fundo número 3)
            MOV [SELECIONA_CENARIO_FUNDO], R0   ; seleciona o cenário de fundo
            MOV R6, 8                           ; quarta linha
            MOV R1, 1                           ; primeira coluna
            testa_C_energia:
                CALL teclado
                CMP  R0, R1                         ; verifica se foi pressionada a tecla C
                JNZ testa_C_energia
            acaba_der_energia:
                JMP start
        
        terminado:
            MOV R6, 0
            MOV [GAME_OVER], R6                 ; flag volta a 0 para que quando o programa saia deste ciclo saber que pode voltar ao jogo principal
            MOV [DISPLAYS], R6
            MOV [APAGA_ECRA], R0                ; apaga todos os pixels já desenhados
            MOV R0, 4                           ; tela inicial (fundo número 4)
            MOV [SELECIONA_CENARIO_FUNDO], R0   ; seleciona o cenário de fundo
            MOV [APAGA_VIDEO], R0               ; para o vídeo de fundo
            MOV [APAGA_ECRA_FRONTAL], R0
            MOV R6, 8                           ; quarta linha
            MOV R1, 1                           ; primeira coluna
            CALL espera_nao_tecla
            testa_C_terminado:
                CALL teclado
                CMP  R0, R1                         ; verifica se foi pressionada a tecla C
                JNZ testa_C_terminado
            acaba_terminado:
                CALL espera_nao_tecla
                CALL repoe_jogo
                JMP running


; **********************************************************************
; Processo
;
; Teclado - Processo que deteta quando se carrega numa tecla
;		  do teclado e escreve o valor da tecla num LOCK.
;
; **********************************************************************

PROCESS SP_inicial_teclado
    inicio_teclado:
        MOV R9, TEC_LIN
        MOV R10, TEC_COL
        MOV R5, ISOLA_03BITS    ; para isolar os 4 bits de menor peso

    espera_tecla:
        YIELD
        MOV  R6, C_LINHA        ; reinicia o ciclo, começando em 10H para passar a 8
    linha:				        ; neste ciclo espera-se até uma tecla ser premida
        SHR  R6, 1	            ; passa de linha
        JZ   espera_tecla       ; Se o SHR der 0 volta ao início
        CALL teclado			; leitura às teclas
        CMP	 R0, 0
        JZ	 linha		        ; espera, enquanto não houver tecla carregada
        
        CALL converte                   ;R0 é a tecla pressionada
        MOV [tecla_carregada], R0
        MOV R1, 0DH                    
        CMP R0, R1                      ;verifica se foi pressionado D
        JZ testa_pausa
        MOV R1, 0EH
        CMP R0, R1                      ;verifica se foi pressionado D
        JZ testa_fim
        JMP ha_tecla
        testa_pausa:
            MOV R1, 1
            MOV [GAME_OVER], R1
            JMP ha_tecla
        testa_fim:
            MOV R1, 4
            MOV [GAME_OVER], R1

    ha_tecla:
        YIELD
        CALL teclado
        CMP  R0, 0
        JNZ  ha_tecla
    
    JMP espera_tecla


; **********************************************************************
; Processo
;
; Painel Nave - Processo responsavell pela mudanca do padrao das luzes
;             do painel da nave.
;
; **********************************************************************

PROCESS SP_inicial_nave
    inicio_painel:
        MOV R1, LIN_LUZES_PAINEL
        MOV R2, COL_LUZES_PAINEL
        MOV R9, 0
        reinicia_ciclo_paineis:
            MOV R3, 8
            MOV R4, DEF_LUZES_PAINEL1
        ciclo_paineis:
            CALL cria_painel                    ; cria o painel na sua posição
            CALL desenha_boneco
            MOV R0, [luzes_painel]
            MOV R0, 20H
            ADD R4, R0 ; distância entre tabelas das luzes
            SUB R3, 1
            JNZ ciclo_paineis
            JMP reinicia_ciclo_paineis
        
int_luzes_painel:
    PUSH R0
    MOV R0, 1
    MOV [luzes_painel], R0
    POP R0
    RFE


; **********************************************************************
; Processo
;
; Meteoro - Processo responsavel por controlar o movimento de
;           cada um dos meteoros.
;
; **********************************************************************

PROCESS SP_inicial_meteoro_0
    inicio_meteoro:
        MOV R10, R11    ; número de meteoro
        MOV R1, 200H
        MUL R1, R11
        ADD SP, R1
        SHL R10, 1
        INC R11         ; número do ecrã
        MOV R7, +1
        MOV R9, R11

    inicia_meteoro:
        CALL cria_meteoro
    testa_meteoro:
        CALL ativa_coordenadas_meteoro
        CALL desenha_boneco
        YIELD
        MOV R0, [anima_meteoro]
        MOV R0, METEORO_FUNCAO
        MOV R3, [R0+R10]
        CMP R3, -1
        JZ inicia_meteoro
    	CALL apaga_boneco		        ; apaga o boneco na sua posição atual

    	CALL define_novas_coordenadas_meteoro	; escreve as novas coordenadas na memória
        MOV R0, MAX_LINHA
        CMP R1, R0
        JZ inicia_meteoro
    JMP testa_meteoro                ; volta a esperar que não haja tecla carregada

int_meteoro:
    PUSH R0
    MOV R0, 1
    MOV [anima_meteoro], R0
    POP R0
    RFE


; **********************************************************************
; Processo
;
; Sonda - Processo responsavel por controlar o movimento de
;        cada uma das sondas.
;
; **********************************************************************

PROCESS SP_inicial_sonda_0
    inicio_sonda:
        MOV R10, R11    ; número de meteoro
        MOV R1, 200H
        MUL R1, R11
        ADD SP, R1
        SHL R10, 1
        MOV R7, -1
        MOV R4, DEF_SONDA
        
    inicia_sonda:
        MOV R3, PASSOS_SONDA
        MOV R0, [tecla_carregada]
        CMP R0, R11
        JNZ inicia_sonda
        CALL decrementa5
        MOV R1, POSICOES_SONDA
        MOV R0, [R10+R1]
    ativa_coordenadas_sonda:
        MOV R1, SPAWN_SND_LIN
        MOV R2, [R0]
        MOV R8, [R0+2]

    ciclo_sonda:
        YIELD
        MOV R9, 5
        CALL desenha_boneco
        MOV R0, [anima_sonda]
        MOV R9, 5
        CALL apaga_boneco
        ADD R1, R7
        ADD R2, R8
        CALL verifica_colisao
        CMP R0, 1
        JZ inicia_sonda
        SUB R3, 1
        JNZ ciclo_sonda
        JMP inicia_sonda

int_sonda:
    PUSH R0
    MOV R0, 1
    MOV [anima_sonda], R0
    POP R0
    RFE


; **********************************************************************
; Processo
;
; Energia - Processo responsavel por controlar a variaçâo do valor de
;         energia da nave.
;
; **********************************************************************

PROCESS SP_inicial_energia
    inicio_energia:
        MOV R1, ENERGIA_INICIAL
        MOV [energia], R1
        MOV R0, 3H
        MUL R1, R0
        MOV R0, 100H
        DIV R1, R0
        reseta_ciclo_energia:
            MOV R0, [decresce_energia]
            MOV R0, R1
        ciclo_energia:
            CALL decrementa_energia
            SUB R0, 1
            JNZ ciclo_energia
        JMP reseta_ciclo_energia


; **********************************************************************
; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna 
;         o valor lido.
; Argumentos:	R6 - linha a testar (em formato 1, 2, 4 ou 8)
;
; Retorna: 	R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)	
; **********************************************************************

teclado:
	PUSH	R2
	PUSH	R3
	PUSH	R5
	MOV  R2, TEC_LIN        ; endereço do periférico das linhas
	MOV  R3, TEC_COL        ; endereço do periférico das colunas
	MOV  R5, ISOLA_03BITS   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6           ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]           ; ler do periférico de entrada (colunas)
	AND  R0, R5             ; elimina bits para além dos bits 0-3
    JNZ teclado_saida
teclado_saida:
    POP	R5
	POP	R3
	POP	R2
	RET


; **********************************************************************
; ESPERA_NAO_TECLA - Espera até NÃO haver nenhuma tecla premida na linha
;                    guardada em R6
; Argumentos:   R6 - linha
;
; **********************************************************************

espera_nao_tecla:
    PUSH R0
    espera_nao_tecla_ciclo:
	CALL teclado			           ; leitura às teclas
	CMP	R0, 0                          ; verifica se há alguma tecla a ser primida
	JNZ	espera_nao_tecla_ciclo	       ; espera enquanto houver tecla uma tecla carregada
    POP R0
    RET


; **********************************************************************
; CONVERTE - Converte a linha, ou coluna, para um número entre 0 e 3.
;
; Argumentos:   R6 - linha
;               R0 - coluna
;
; Retorna:      R0 - valor lido do teclado (0 a F)
; **********************************************************************

converte:
    PUSH R3
    PUSH R6
    MOV  R3, 0
    CALL converte_loop  ; converte a linha e recebe o resultado da soma em R3
    SHL  R3, 2          ; multiplica o resultado por 4
    MOV  R6, R0         
    CALL converte_loop  ; converte a coluna e recebe o resultado da soma em R3
    MOV  R0, R3
    POP  R6
    POP  R3
    RET

converte_loop:
    PUSH R2
    MOV R2, 0
loop:                   ; conta quantos bits o bit 1 se tem que mover para ficar a 0
    ADD R2, 1
    SHR R6, 1
    JNZ loop
    SUB R2, 1           ; retira 1 para passar a um numero entre 0 e 3
    ADD R3, R2          ; soma 
    POP R2
    RET
    

; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
;
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;               R9 - ecrã a escrever
;
; **********************************************************************

desenha_boneco:
    PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    MOV [DEFINE_ECRA], R9
	MOV	 R5, [R4]		    ; obtém a altura do boneco
    MOV  R8, R4             ; guarda o início da tabela que define o boneco
	ADD	 R8, 4			    ; endereço da cor do 1.º pixel
reinicia_desenha:
    MOV  R7, R2             ; guarda a coordenada da coluna inicial
    MOV  R6, [R4+2]         ; obtém a largura do boneco
desenha_pixels:       	    ; desenha os pixels do boneco a partir da tabela
	MOV	 R3, [R8]		    ; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel      ; escreve cada pixel do boneco
	ADD	 R8, 2			    ; endereço da cor do próximo pixel
    ADD  R7, 1              ; próxima coluna
    SUB  R6, 1			    ; decrementa a largura
    JNZ  desenha_pixels     ; continua até percorrer toda a largura do objeto
    ADD  R1, 1              ; próxima linha
    SUB  R5, 1			    ; decrementa a altura
    JNZ  reinicia_desenha   ; continua até percorrer toda a altura do objeto
    POP  R9
	POP	 R8
    POP  R7
    POP  R6
	POP	 R5
	POP	 R4
	POP	 R3
    POP  R2
    POP  R1
	RET


; **********************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;               R9 - ecrã a escrever
;
; **********************************************************************

apaga_boneco:
    PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    MOV [DEFINE_ECRA], R9
	MOV	 R5, [R4]		; obtém a altura do boneco
    MOV  R8, R4         ; guarda o início da tabela que define o boneco
	MOV	 R3, APAGADO    ; pixeis sempre com cor apagado
reinicia_apaga:
    MOV  R7, R2         ; guarda a coluna inicial
    MOV  R6, [R4+2]     ; obtém a largura do boneco
apaga_pixels:       	; desenha os pixels do boneco a partir da tabela
	CALL escreve_pixel  ; escreve cada pixel do boneco
    ADD  R7, 1          ; próxima coluna
    SUB  R6, 1			; decrementa na largura
    JNZ  apaga_pixels   ; continua até percorrer toda a largura do objeto
    ADD  R1, 1          ; próxima linha
    SUB  R5, 1			; decrementa a altura
    JNZ  reinicia_apaga ; continua até percorrer toda a altura do objeto
    POP  R9
	POP	 R8
    POP  R7
    POP  R6
	POP	 R5
	POP	 R4
	POP	 R3
    POP  R2
    POP  R1
	RET


; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R7 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************

escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; define a linha a desenhar
	MOV  [DEFINE_COLUNA], R7	; define a coluna a desenhar
	MOV  [DEFINE_PIXEL], R3		; define a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
; CRIA_PAINEL - Cria o painel na sua posição.
;
; **********************************************************************

cria_painel:
    PUSH R1
    PUSH R2
    PUSH R4
posicao_painel:
    MOV R1, LIN_PAINEL  ; linha do meteoro
    MOV R2, COL_PAINEL  ; linha do meteoro
    MOV R4, DEF_PAINEL  ; endereço da tabela do meteoro minerável
mostra_painel:
    MOV R9, 0
    CALL desenha_boneco ; desenha o painel
    POP R4
    POP R2
    POP R1
    RET


; **********************************************************************
; ATIVA_COORDENADAS_METEORO - Retorna as informações para desenhar 
;                            o meteoro minerável.
;
; Argumentos: R10 - Número meteoro
;             
; **********************************************************************

ativa_coordenadas_meteoro:
    PUSH R0
    PUSH R3
    PUSH R10
    MOV R0, METEORO_LINHA
    MOV R1, [R10+R0]
    MOV R0, METEORO_COLUNA
    MOV R2, [R10+R0]
    MOV R0, METEORO_FUNCAO
    MOV R3, [R10+R0]
    CMP R3, 0
    JNZ e_nmin
    e_min:
        MOV R4, DEF_MET_MIN
        JMP coordenadas_saida
    e_nmin:
        MOV R4, DEF_MET_NMIN
    coordenadas_saida:
    POP R10
    POP R3
    POP R0
    RET


; **********************************************************************
; VERIFICA_COLISAO - Verifica se ocorreu uma colisão.
;
; Argumentos:   R1 - Linha atual
;               R2 - Coluna atual
;               R9 - Ecrã das sondas
;
; Retorno: R0 - Houve colisao ou n
; **********************************************************************

verifica_colisao:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R9
    ciclo_lepixel:
        SUB R9, 1
        JZ saida_colisao
        MOV [DEFINE_ECRA], R9
        MOV R0, [OBTEM_PIXEL]
        MOV R3, VERDE
        CMP R0, R3
        JZ colisao_mineravel
        MOV R3, VERMELHO
        CMP R0, R3
        JZ colisao_nao_mineravel
        JMP ciclo_lepixel
    colisao_nao_mineravel:
        CALL explode_nao_mineravel
        MOV R0, 1
        JMP saida_colisao
    colisao_mineravel:
        CALL explode_mineravel
        CALL incrementa25
        MOV R0, 1
saida_colisao:
    POP R9
    POP R3
    POP R2
    POP R1
    RET

; **********************************************************************
; EXPLODE_MINERAVEL - Rotina responsãvel pela explosao de um meteoro 
;                   mineravel.
;
; Argumentos:   R9 - Ecrã das sondas
;
; **********************************************************************

explode_mineravel:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R9
    PUSH R10
    MOV R10, R9
    SUB R10, 1
    SHL R10, 1
    CALL ativa_coordenadas_meteoro
    MOV R0, 36H
    MOV R3, 2
    ciclo_explosao_mineravel:
        ADD R4, R0
        CALL desenha_boneco
        CALL atraso
        SUB R3, 1
        JNZ ciclo_explosao_mineravel
    CALL apaga_boneco
    MOV R0, METEORO_FUNCAO
    MOV R1, -1
    MOV [R0+R10], R1
    POP R10
    POP R9
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; **********************************************************************
; EXPLODE_NAO_MINERAVEL - Rotina responsãvel pela explosao de um meteoro 
;                   mineravel.
;
; Argumentos:   R9 - Ecrã das sondas
;
; **********************************************************************

explode_nao_mineravel:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R9
    PUSH R10
    MOV R10, R9
    SUB R10, 1
    SHL R10, 1
    CALL ativa_coordenadas_meteoro
    MOV R0, 36H
    ADD R4, R0
    CALL apaga_boneco
    CALL desenha_boneco
    CALL atraso
    CALL apaga_boneco
    MOV R0, METEORO_FUNCAO
    MOV R1, -1
    MOV [R0+R10], R1
    POP R10
    POP R9
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R11 - valor que define o atraso
;
; **********************************************************************

atraso:
	PUSH R11
ciclo_atraso:
	SUB	 R11, 1
	JNZ	 ciclo_atraso
	POP	 R11
	RET


; **********************************************************************
; DEFINE_NOVAS_COORDENADAS_METEORO - Define as novas coordenadas.
;
; Argumentos:   R1 - Linha atual
;               R2 - Coluna atual
;               R7 - (In/De)cremento das linhas
;               R8 - (In/De)cremento das colunas
;               R10 - Número do meteoro
; 
; Retorna:      R1 - Linha atualizada
;               R2 - Coluna atualizada
;
; **********************************************************************

define_novas_coordenadas_meteoro:
    ADD R1, R7      ; avança a coordenada nas linhas
    ADD R2, R8      ; avança a coordenada nas colunas
    MOV R3, METEORO_LINHA
    MOV [R3+R10], R1    ; guarda a coordenada da linha na memória
    MOV R3, METEORO_COLUNA
    MOV [R3+R10], R2  ; guarda as coordenada da coluna na memória
    RET


; **********************************************************************
; CRIA_METEORO - Cria um meteoro.
; 
; Argumentos: R10 - Número do meteoro
;
; Retorna: R8 - Direção do meteoro
;
; **********************************************************************

cria_meteoro:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R10
    PUSH R11
    funcao_meteoro:
    MOV R1, METEORO_FUNCAO
    MOV R11, 8
    CALL gera_numero_aleatorio
    CMP R0, 2
    JGE nao_mineravel
    mineravel:
        MOV R2, 0
        JMP coordenadas_meteoro
    nao_mineravel:
        MOV R2, 1
    coordenadas_meteoro:
    MOV [R1+R10], R2
    MOV R11, 5
    CALL gera_numero_aleatorio
    SHL R0, 1
    MOV R11, POSICOES_METEORO
    MOV R3, [R11+R0]
    MOV R2, [R3]                    ; Posição nas colunas
    MOV R1, METEORO_COLUNA
    MOV [R1+R10], R2
    MOV R1, METEORO_LINHA
    MOV R2, 0
    MOV [R1+R10], R2
    MOV R8, [R3+2]                  ; Direção do meteoro
    POP R11
    POP R10
    POP R3
    POP R2
    POP R1
    POP R0
    RET


; **********************************************************************
; GERA_NUMERO_ALEATORIO - Rotina para gerar um numero aleatorio.
; Argumentos:   R11 - Módulo
;
; Retorna:      R0 - Numero aleatorio
; **********************************************************************

gera_numero_aleatorio:
    PUSH R1
    PUSH R11
    MOV R0, [DISPLAYS]
    MOV R1, [TEC_COL]
    MUL R0, R1
    MOD R0, R11
    POP R11
    POP R1
    RET


; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   impede o movimento (força R7 a 0)
; Argumentos:	R2 - coluna em que o objeto está
;			R6 - largura do boneco
;			R7 - sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário	
; **********************************************************************

testa_limites:
	PUSH	R5
	PUSH	R6
testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JGT	testa_limite_direito
	CMP	R7, 0			; passa a deslocar-se para a direita
	JGE	sai_testa_limites
	JMP	impede_movimento	; entre limites. Mantém o valor do R7
testa_limite_direito:		; vê se o boneco chegou ao limite direito
	ADD	R6, R2			; posição a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JLE	sai_testa_limites	; entre limites. Mantém o valor do R7
	CMP	R7, 0			; passa a deslocar-se para a direita
	JGT	impede_movimento
	JMP	sai_testa_limites
impede_movimento:
	MOV	R7, 0			; impede o movimento, forçando R7 a 0
sai_testa_limites:	
	POP	R6
	POP	R5
	RET


; **********************************************************************
; INT_ENERGIA - Decrementa a energia em memória e escreve no display.
;   
; **********************************************************************

int_energia:
    PUSH R0
    MOV R0, 1
    MOV [decresce_energia], R0
    POP R0
    RFE


; **********************************************************************
; ESCREVE_ENERGIA - Lê a energia em memória e escreve no display.
;
; **********************************************************************

escreve_energia:
    PUSH R3
    MOV R3, [energia]   ; lê a energia guardada em memória
    MOV [DISPLAYS], R3      ; escreve a energia no display
    POP R3
    RET


; **********************************************************************
; RESETA_ENERGIA - Reinicia a energia em memória.
;
; **********************************************************************

reseta_energia:
    PUSH R0
    MOV  R0, ENERGIA_INICIAL              
    MOV  [energia], R0  ; reinicia a energia em memória 
    CALL escreve_energia
    POP  R0
    RET


; **********************************************************************
; INCREMENTA_ENERGIA - Incrementa uma unidade na energia recebida.
; 
; Argumentos: R3 - Energia atual
;
; Retorno: R3 - Energia Atualizada
; **********************************************************************

incrementa_energia:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R4
    MOV R0, 000AH
    MOV R1, 1H
    MOV R2, ISOLA_03BITS
    MOV R3, [energia]
    MOV R4, 3
    JMP incrementa_corpo_ciclo
ciclo_incrementa:
    SUB R3, R0
    SHL R1, 4
    SHL R2, 4
    SHL R0, 4
incrementa_corpo_ciclo:
    ADD R3, R1
    AND R2, R3
    CMP R2, R0
    JLT incrementa_saida
    SUB R4, 1
    JNZ ciclo_incrementa
    MOV R3, 999H
incrementa_saida:
    MOV [energia], R3
    CALL escreve_energia
    POP R4
    POP R2
    POP R1
    POP R0
    RET


; **********************************************************************
; DECREMENTA_ENERGIA - Decrementa uma unidade na energia recebida.
;
; Argumentos: R3 - Energia atual
;
; Retorno: R3 - Energia Atualizada
; **********************************************************************

decrementa_energia:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R4
    PUSH R5
    MOV R0, 0009H
    MOV R1, 1H
    MOV R2, ISOLA_03BITS
    MOV R3, [energia]
    MOV R4, 3
    MOV R5, 0006H
    SUB R3, R1
    JMP decrementa_corpo_ciclo
ciclo_decrementa:
    SUB R3, R5
    SHL R5, 4
    SHL R0, 4
    SHL R2, 4
decrementa_corpo_ciclo:
    AND R2, R3
    CMP R2, R0
    JLT decrementa_saida    ; Menos que porque o 9 é um dos casos limite
    SUB R4, 1
    JNZ ciclo_decrementa
    MOV R3, 0H
    MOV R0, 1
    MOV [GAME_OVER], R0
decrementa_saida:
    MOV [energia], R3
    CALL escreve_energia
    POP R5
    POP R4
    POP R2
    POP R1
    POP R0
    RET

decrementa5:
    PUSH R0
    PUSH R1
    PUSH R3
    MOV R1, ENERGIA_INICIAL
    MOV R0, 5H
    MUL R1, R0
    MOV R0, 100H
    DIV R1, R0
    ciclo_decrementa5:
        CALL decrementa_energia
        SUB R1, 1
        JNZ ciclo_decrementa5
    POP R3
    POP R1
    POP R0
    RET

incrementa25:
    PUSH R0
    PUSH R1
    PUSH R3
    MOV R1, ENERGIA_INICIAL
    MOV R0, 19H ; 25 em hexadecimal
    MUL R1, R0
    MOV R0, 100H
    DIV R1, R0
    ciclo_incrementa25:
        CALL incrementa_energia
        SUB R1, 1
        JNZ ciclo_incrementa25
    POP R3
    POP R1
    POP R0
    RET

repoe_jogo:
    PUSH R0
    PUSH R1
    CALL reseta_energia
    MOV R0, METEORO_FUNCAO
    MOV R1, -1
    MOV [R0], R1
    MOV [R0+2], R1
    MOV [R0+4], R1
    MOV [R0+6], R1
    POP R1
    POP R0
    RET