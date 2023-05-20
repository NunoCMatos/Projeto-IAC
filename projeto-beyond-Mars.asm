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
SPAWN3_COL  EQU 58      ; coluna do 3.º spawnpoint (canto superior direito)

SPAWN_SND_LIN   EQU 26
SPAWN1_SND_COL  EQU 26
SPAWN2_SND_COL  EQU 32
SPAWN3_SND_COL  EQU 48

LIN_PAINEL  EQU 25
COL_PAINEL  EQU 27

; * Tamanhos
LARGURA     EQU 5
ALTURA EQU 5
LAR_PAINEL  EQU 15
ALT_PAINEL  EQU 5
LAR_SONDA   EQU 1
ALT_SONDA   EQU 1

; * Cores
VERMELHO    EQU 0FF00H
VERDE       EQU 0F0F0H
AZUL        EQU 0F00FH
AMARELO     EQU 0F0F0H
CASTANHO    EQU 0F0F0H
ROSA        EQU 0F0F0H
CINZENTO    EQU 0F0F0H
APAGADO     EQU 0000H

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
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO, 0, 0, 0, 0, 0, 0, 0, CASTANHO, CASTANHO, CASTANHO, VERMELHO
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO, 0, 0, 0, 0, 0, 0, 0, CASTANHO, CASTANHO, CASTANHO, VERMELHO
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, VERMELHO

DEF_SONDA:
    WORD ALT_SONDA, LAR_SONDA
    WORD ROSA


; **********************************************************************
; * Dados
; **********************************************************************

PLACE 1000H

pilha:
    STACK 100H

SP_Inicial:


; **********************************************************************
; * Código
; **********************************************************************

PLACE 0

; corpo principal do programa

inicializacoes:
    ; * Stack Pointer
    MOV SP, SP_Inicial      ; Inicialização do Stack Pointer

    ; * Ecrâ
    MOV [APAGA_AVISO], R0	            ; apaga o aviso do ecrã (R0 não é relevante)
    MOV [APAGA_ECRÃ], R0	            ; apaga todos os pixels já desenhados (R0 não é relevante)
    MOV R0, 0                           ; cenário de fundo número 0
    MOV [SELECIONA_CENARIO_FUNDO], R0   ; seleciona o cenário de fundo

    ; * Gerais
    MOV R5, MASCARA                     ; para isolar os 4 bits de menor peso
    MOV R7, 0H                          ; contador de clicks no teclado

; desenhar meteoro minerável
posicao_boneco:
    MOV R1, SPAWN_LIN   ; linha do meteoro
    MOV R2, SPAWN1_COL  ; linha do meteoro
    MOV R4, DEF_MET_MIN ; endereço da tabela do meteoro minerável

mostra_boneco:
    CALL desenha_boneco ; desenha o boneco a partir da tabela

ciclo_teclado:              ; inicia o ciclo
    MOV  R4, 0H             ; auxiliar para apresentar no display
    MOV  R3, 0H             ; auxiliar para calcular a tecla
    MOVB [DISPLAYS], R3     ; escreve linha e coluna a zero nos displays

    MOV  R1, U_LINHA        ; volta à última linha
    JMP espera_tecla

passa_linha:
    SHR R1, 1          ; decrementa uma linha
    JZ ciclo           ; se for 0, reinicia o ciclo

espera_tecla:          ; neste ciclo espera-se até uma tecla ser premida
    MOVB [TEC_LIN], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [TEC_COL]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JZ   passa_linha   ; se nenhuma tecla premida, repete
                       ; vai mostrar a linha e a coluna da tecla

    ADD R7, 1
    MOV R6, R1         ; guarda a linha atual, e R1 passa a auxiliar

    CALL converte      ; converte a linha
    MOV R1, 4
    MUL R3, R1         ; multiplica a linha por 4
    MOV R1, R0         ; passa a coluna para o registo R1
    CALL converte      ; converte a coluna
    OR R4, R7
    SHL R4, 4
    OR R4, R3
    MOVB [DISPLAYS], R4      ; escreve linha e coluna nos displays

ha_tecla:              ; neste ciclo espera-se até NENHUMA tecla estar premida
    MOVB [TEC_LIN], R6      ; escrever no periférico de saída (linhas)
    MOVB R0, [TEC_COL]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera até não haver
    JMP  ciclo_teclado ; repete ciclo


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
	MOV	 R5, [R4]		; obtém a altura do boneco
    MOV  R6, [R4+2]     ; obtém a largura do boneco
	ADD	 R4, 4			; endereço da cor do 1º pixel
desenha_pixels:       	; desenha os pixels do boneco a partir da tabela
	MOV	 R3, [R4]		; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel  ; escreve cada pixel do boneco
	ADD	 R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1          ; próxima coluna
    SUB  R6, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels ; continua até percorrer toda a largura do objeto
    ADD	 R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R1, 1          ; próxima linha
    SUB  R5, 1			; menos uma linha para tratar
    JNZ  desenha_pixels ; continua até percorrer toda a largura do objeto
    POP  R6
	POP	 R5
	POP	 R4
	POP	 R3
	POP	 R2
	RET


; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
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

