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

DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (perif�rico PIN)
U_LINHA    EQU 8       ; última linha do teclado
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado


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
