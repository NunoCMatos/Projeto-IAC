; *********************************************************************************
; * IST-UL
; * Alunos: Nuno Correia de Matos - 105990
;           Duarte Ramires -
;
; * PROJETO
; * Descrição: Este programa corresponde à primeira fase do
;              projeto "Beyond Mars"
; *********************************************************************************


; **********************************************************************
; * Constantes
; **********************************************************************

; **********************************************************************
; * MediaCenter
; **********************************************************************
COMANDOS                 EQU 6000H   ; endereço base dos comandos do MediaCenter
DEFINE_LINHA    	     EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   	     EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    	     EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     	     EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA	 		     EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
MIN_LINHA		         EQU 0		 ; número da coluna mais à esquerda do ecrã
MIN_COLUNA		         EQU 0		 ; número da coluna mais à esquerda do ecrã
MAX_LINHA		         EQU 31      ; número da coluna mais à direita do ecrã
MAX_COLUNA		         EQU 63      ; número da coluna mais à direita do ecrã
ATRASO			         EQU 10H     ; atraso para limitar a velocidade de movimento do boneco

; **********************************************************************
; * Periféricos
; **********************************************************************
DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (perif�rico PIN)
U_LINHA    EQU 8       ; última linha do teclado

; **********************************************************************
; * Máscaras
; **********************************************************************
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; **********************************************************************
; * Figuras
; **********************************************************************
; * Coordenadas
SPAWN_LIN   EQU 0       ; linha dos spawnpoints dos meteoros
SPAWN1_COL  EQU 0       ; coluna do 1.º spawnpoint (canto superior esquerdo)
SPAWN2_COL  EQU 30      ; coluna do 2.º spawnpoint (centro superior)
SPAWN3_COL  EQU 59      ; coluna do 3.º spawnpoint (canto superior direito)

SPAWN_SND_LIN   EQU 26
SPAWN1_SND_COL  EQU 26
SPAWN2_SND_COL  EQU 32
SPAWN3_SND_COL  EQU 48

LIN_PAINEL  EQU 27
COL_PAINEL  EQU 25

; * Tamanhos
LARGURA     EQU 5
ALTURA      EQU 5
LAR_PAINEL  EQU 15
ALT_PAINEL  EQU 5
LAR_SONDA   EQU 1
ALT_SONDA   EQU 1

; * Cores
VERMELHO    EQU 0FF00H
VERDE       EQU 0F0F0H
AZUL        EQU 0F0FFH
AMARELO     EQU 0FFF0H
CASTANHO    EQU 0FAA6H
ROSA        EQU 0FF0FH
CINZENTO    EQU 0F777H
APAGADO     EQU 0000H


; **********************************************************************
; * Dados
; **********************************************************************

PLACE 1000H

; * Pilhas

    STACK 100H  ; espaço reservado para a pilha do processo "programa principal"
SP_Inicial:     ; endereço da pilha


; * Definições
DEF_MET_MIN:
    WORD ALTURA, LARGURA
    WORD     0, VERDE, VERDE, VERDE, 0
    WORD VERDE, VERDE, VERDE, VERDE, VERDE
    WORD VERDE, VERDE, VERDE, VERDE, VERDE
    WORD VERDE, VERDE, VERDE, VERDE, VERDE
    WORD     0, VERDE, VERDE, VERDE, 0

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
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO, CINZENTO, VERMELHO, VERDE, CINZENTO, VERDE, CINZENTO, CINZENTO, CASTANHO, CASTANHO, CASTANHO, VERMELHO
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO, VERDE, CINZENTO, VERMELHO, VERDE, AMARELO, AZUL, CINZENTO, CASTANHO, CASTANHO, CASTANHO, VERMELHO
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, VERMELHO

DEF_SONDA:
    WORD ALT_SONDA, LAR_SONDA
    WORD ROSA

; **********************************************************************
; * Código
; **********************************************************************

PLACE 0

; corpo principal do programa

inicializacoes:
    ; * Stack Pointer
    MOV SP, SP_Inicial  ; Inicialização do Stack Pointer
    MOV R9, TEC_LIN
    MOV R10, TEC_COL
    MOV R11, DISPLAYS

    ; * Ecrâ
    MOV [APAGA_AVISO], R0	            ; apaga o aviso do ecrã (R0 não é relevante)
    MOV [APAGA_ECRA], R0	            ; apaga todos os pixels já desenhados (R0 não é relevante)
    MOV R0, 0                           ; cenário de fundo número 0
    MOV [SELECIONA_CENARIO_FUNDO], R0   ; seleciona o cenário de fundo

    ; * Gerais
    MOV R5, MASCARA                     ; para isolar os 4 bits de menor peso
    MOV R7, 0H                          ; contador de clicks no teclado

desenha:
    CALL desenha_meteoro_mineravel
    CALL desenha_meteoro_nao_mineravel
    CALL desenha_painel
    CALL desenha_sonda

ciclo_teclado:          ; inicia o ciclo
    MOV  R4, 0H         ; auxiliar para apresentar no display
    MOV  R3, 0H         ; auxiliar para calcular a tecla
    MOVB [R11], R3      ; escreve linha e coluna a zero nos displays

    MOV  R1, U_LINHA    ; volta à última linha
    JMP espera_tecla

passa_linha:
    SHR R1, 1           ; decrementa uma linha
    JZ ciclo_teclado    ; se for 0, reinicia o ciclo

espera_tecla:           ; neste ciclo espera-se até uma tecla ser premida
    MOVB [R9], R1       ; escrever no periférico de saída (linhas)
    MOVB R0, [R10]      ; ler do periférico de entrada (colunas)
    AND  R0, R5         ; elimina bits para além dos bits 0-3
    CMP  R0, 0          ; há tecla premida?
    JZ   passa_linha    ; se nenhuma tecla premida, repete
                        ; vai mostrar a linha e a coluna da tecla

    ADD R7, 1
    MOV R6, R1          ; guarda a linha atual, e R1 passa a auxiliar

    CALL converte       ; converte a linha
    MOV R1, 4
    MUL R3, R1          ; multiplica a linha por 4
    MOV R1, R0          ; passa a coluna para o registo R1
    CALL converte       ; converte a coluna
    OR R4, R7
    SHL R4, 4
    OR R4, R3
    MOVB [R11], R4      ; escreve linha e coluna nos displays

ha_tecla:               ; neste ciclo espera-se até NENHUMA tecla estar premida
    MOVB [R9], R6       ; escrever no periférico de saída (linhas)
    MOVB R0, [R10]      ; ler do periférico de entrada (colunas)
    AND  R0, R5         ; elimina bits para além dos bits 0-3
    CMP  R0, 0          ; há tecla premida?
    JNZ  ha_tecla       ; se ainda houver uma tecla premida, espera até não haver
    JMP  ciclo_teclado  ; repete ciclo


; **********************************************************************
; DESENHA_METEORO_MINERAVEL - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_meteoro_mineravel:
    PUSH R1
    PUSH R2
    PUSH R4
posicao_meteoro_mineravel:
    MOV R1, SPAWN_LIN   ; linha do meteoro
    MOV R2, SPAWN1_COL  ; linha do meteoro
    MOV R4, DEF_MET_MIN ; endereço da tabela do meteoro minerável
mostra_meteoro_mineravel:
    CALL desenha_boneco ; desenha o boneco a partir da tabela
    POP R4
    POP R2
    POP R1
    RET

; **********************************************************************
; DESENHA_METEORO_NAO_MINERAVEL - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_meteoro_nao_mineravel:
    PUSH R1
    PUSH R2
    PUSH R4
posicao_meteoro_nao_mineravel:
    MOV R1, SPAWN_LIN   ; linha do meteoro
    MOV R2, SPAWN3_COL  ; linha do meteoro
    MOV R4, DEF_MET_NMIN ; endereço da tabela do meteoro minerável
mostra_meteoro_nao_mineravel:
    CALL desenha_boneco ; desenha o boneco a partir da tabela
    POP R4
    POP R2
    POP R1
    RET

; **********************************************************************
; DESENHA_PAINEL - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_painel:
    PUSH R1
    PUSH R2
    PUSH R4
posicao_painel:
    MOV R1, LIN_PAINEL  ; linha do meteoro
    MOV R2, COL_PAINEL  ; linha do meteoro
    MOV R4, DEF_PAINEL  ; endereço da tabela do meteoro minerável
mostra_painel:
    CALL desenha_boneco
    POP R4
    POP R2
    POP R1
    RET

; **********************************************************************
; DESENHA_SONDA - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_sonda:
    PUSH R1
    PUSH R2
    PUSH R4
posicao_sonda:
    MOV R1, SPAWN_SND_LIN
    MOV R2, SPAWN2_SND_COL
    MOV R4, DEF_SONDA
mostra_sonda:
    CALL desenha_boneco
    POP R4
    POP R2
    POP R1
    RET

; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_boneco:
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
	MOV	 R5, [R4]		; obtém a altura do boneco
    MOV  R8, R4         ; guarda o início da tabela que define o boneco
	ADD	 R8, 4			; endereço da cor do 1.º pixel
reinicia:
    MOV  R7, R2         ; guarda a coluna inicial
    MOV  R6, [R4+2]     ; obtém a largura do boneco
desenha_pixels:       	; desenha os pixels do boneco a partir da tabela
	MOV	 R3, [R8]		; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel  ; escreve cada pixel do boneco
	ADD	 R8, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R7, 1          ; próxima coluna
    SUB  R6, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels ; continua até percorrer toda a largura do objeto
    ADD  R1, 1          ; próxima linha
    SUB  R5, 1			; menos uma linha para tratar
    JNZ  reinicia       ; continua até percorrer toda a largura do objeto
	POP	 R8
    POP  R7
    POP  R6
	POP	 R5
	POP	 R4
	POP	 R3
    POP  R2
	RET


; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R7 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R7		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
; CONVERTE - Converte a linha, ou coluna, para um número entre 0 e 3.
;
; Argumentos:   R1 - linha/coluna
;
; Retorna:      R3 - Soma das conversões
; **********************************************************************
converte:
    PUSH R2
    PUSH R1
    MOV R2, 0
converte_loop:
    ADD R2, 1
    SHR R1, 1
    JNZ converte_loop
    SUB R2, 1           ; retira 1 para passar a um numero entre 0 e 3
    ADD R3, R2
    POP R1
    POP R2
    RET

