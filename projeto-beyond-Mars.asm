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
LARGURA     EQU 5
COMPRIMENTO EQU 5
LAR_PAINEL  EQU 15
COM_PAINEL  EQU 5
LAR_SONDA   EQU 1
COM_SONDA   EQU 1

VERMELHO    EQU 0FF00H
VERDE       EQU 0F0F0H
AZUL        EQU 0F00FH
AMARELO     EQU 0F0F0H
CASTANHO    EQU 0F0F0H
ROSA        EQU 0F0F0H
CINZENTO    EQU 0F0F0H
APAGADO     EQU 0000H

DEF_MET_MIN:
    WORD COMPRIMENTO, LARGURA
    WORD     0, VERDE, VERDE, VERDE, 0
    WORD VERDE, VERDE, VERDE, VERDE, VERDE
    WORD VERDE, VERDE, VERDE, VERDE, VERDE
    WORD VERDE, VERDE, VERDE, VERDE, VERDE
    WORD     0, VERDE, VERDE, VERDE, 0

DEF_MET_NMIN:
    WORD COMPRIMENTO, LARGURA
    WORD VERMELHO, 0, VERMELHO, 0, VERMELHO
    WORD 0, VERMELHO, VERMELHO, VERMELHO, 0
    WORD VERMELHO, VERMELHO, 0, VERMELHO, VERMELHO
    WORD 0, VERMELHO, VERMELHO, VERMELHO, 0
    WORD VERMELHO, 0, VERMELHO, 0, VERMELHO

DEF_PAINEL:
    WORD COM_PAINEL, LAR_PAINEL
    WORD 0, 0, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, 0, 0
    WORD 0, VERMELHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, VERMELHO, 0
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO, 0, 0, 0, 0, 0, 0, 0, CASTANHO, CASTANHO, CASTANHO, VERMELHO
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO, 0, 0, 0, 0, 0, 0, 0, CASTANHO, CASTANHO, CASTANHO, VERMELHO
    WORD VERMELHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, CASTANHO, VERMELHO

DEF_SONDA:
    WORD COM_SONDA, LAR_SONDA
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
    MOV  SP, SP_Inicial; Inicialização do Stack Pointer
    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso
    MOV  R8, 0H        ; contador de clicks

; corpo principal do programa
ciclo:                   ; inicia o ciclo
    MOV  R9, 0H          ; auxiliar para apresentar no display
    MOV  R7, 0H          ; auxiliar para calcular a tecla
    MOVB [R4], R7        ; escreve linha e coluna a zero nos displays

    MOV  R1, U_LINHA     ; volta à última linha
    JMP espera_tecla

passa_linha:
    SHR R1, 1          ; decrementa uma linha
    JZ ciclo           ; se for 0, reinicia o ciclo

espera_tecla:          ; neste ciclo espera-se até uma tecla ser premida
    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JZ   passa_linha   ; se nenhuma tecla premida, repete
                       ; vai mostrar a linha e a coluna da tecla

    ADD R8, 1
    MOV R6, R1         ; guarda a linha atual, e R1 passa a auxiliar

    CALL converte      ; converte a linha
    MOV R1, 4
    MUL R7, R1         ; multiplica a linha por 4
    MOV R1, R0         ; passa a coluna para o registo R1
    CALL converte      ; converte a coluna
    OR R9, R8
    SHL R9, 4
    OR R9, R7
    MOVB [R4], R9      ; escreve linha e coluna nos displays

ha_tecla:              ; neste ciclo espera-se até NENHUMA tecla estar premida
    MOVB [R2], R6      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera até não haver
    JMP  ciclo         ; repete ciclo


; R1 - numero a transformar, R2 - contador, return R7 somado
converte:
    PUSH R2
    PUSH R1
    MOV R2, 0
converte_loop:
    ADD R2, 1
    SHR R1, 1
    JNZ converte_loop
    SUB R2, 1           ; retira 1 para passar a um numero entre 0 e 3
    ADD R7, R2
    POP R1
    POP R2
    RET
