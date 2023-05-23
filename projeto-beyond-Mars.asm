; ******************************************************************************
; * IST-UL
; * Alunos: Nuno Correia de Matos - 105990
;           Duarte Ramires -
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
DEFINE_LINHA    	        EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   	        EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL                EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     	        EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA	 		        EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO     EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
TOCA_SOM                    EQU COMANDOS + 5AH		; endereço do comando para tocar um som
MIN_LINHA		            EQU 0		 ; número da coluna mais à esquerda do ecrã
MIN_COLUNA		            EQU 0		 ; número da coluna mais à esquerda do ecrã
MAX_LINHA		            EQU 31      ; número da coluna mais à direita do ecrã
MAX_COLUNA		            EQU 63      ; número da coluna mais à direita do ecrã
ATRASO			            EQU 10H     ; atraso para limitar a velocidade de movimento do boneco

; **********************************************************************
; * Periféricos
; **********************************************************************
DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (perif�rico PIN)
MOVE_METEORO EQU 0FH
MOVE_SONDA EQU 0BH
INCREMENTA EQU 01H
DECREMENTA EQU 00H
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

DEF_POS_METEORO_MIN:
    WORD SPAWN_LIN, SPAWN1_COL          ; localização do meteoro minerável(linha e coluna)

DEF_POS_METEORO_NMIN:
    WORD SPAWN_LIN, SPAWN3_COL          ; localização do meteoro não minerável(linha e coluna)

DEF_POS_SONDA:
    WORD SPAWN_SND_LIN, SPAWN2_SND_COL  ; localização da sonda(linha e coluna)

DEF_ENERGIA:
    WORD 0
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

    ; * Ecrâ
    MOV [APAGA_AVISO], R0	            ; apaga o aviso do ecrã (R0 não é relevante)
    MOV [APAGA_ECRA], R0	            ; apaga todos os pixels já desenhados (R0 não é relevante)
    MOV R0, 0                           ; cenário de fundo número 0
    MOV [SELECIONA_CENARIO_FUNDO], R0   ; seleciona o cenário de fundo

    ; * Gerais
    MOV R5, MASCARA                     ; para isolar os 4 bits de menor peso

cria_bonecos:
    CALL cria_meteoro_mineravel
    CALL cria_meteoro_nao_mineravel
    CALL cria_painel
    CALL cria_sonda
    CALL reseta_energia
    CALL escreve_energia
    JMP ciclo_teclado_tecla

espera_nao_tecla:			; neste ciclo espera-se até NÃO haver nenhuma tecla premida
	CALL teclado			; leitura às teclas
	CMP	 R0, 0
	JNZ	 espera_nao_tecla	; espera, enquanto houver tecla uma tecla carregada

ciclo_teclado_tecla:
    MOV R6, 10H
espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
	SHR R6, 1	            ; linha a testar no teclado
    JZ ciclo_teclado_tecla  ; Se o SHR der 0 volta à linha 8
	CALL teclado			; leitura às teclas
	CMP	 R0, 0
	JZ	 espera_tecla		; espera, enquanto não houver tecla
	
    CALL converte

testa_meteoro:
    MOV R1, MOVE_METEORO
	CMP	R0, R1
	JNZ	testa_sonda

    MOV	R9, 0			    ; som com número 0
	MOV [TOCA_SOM], R9		; comando para tocar o som
	MOV	R7, +1			; vai deslocar para baixo
    MOV R8, +1          ; vai deslocar para a direita
    MOV R3, DEF_POS_METEORO_MIN
    CALL ativa_meteoro_mineravel
	JMP	move_boneco

testa_sonda:
    MOV R1, MOVE_SONDA
	CMP	R0, R1
	JNZ	testa_incremento		; tecla que não interessa

	MOV	R7, -1			; vai deslocar para cima
    MOV R8, 0
    MOV R3, DEF_POS_SONDA
    CALL ativa_sonda

    move_boneco:
    	CALL apaga_boneco		; apaga o boneco na sua posição corrente

    coluna_seguinte:
    	CALL define_novas_coordenadas			; para desenhar objeto na coluna seguinte (direita ou esquerda)

    	CALL desenha_boneco		; vai desenhar o boneco de novo

    JMP espera_nao_tecla

testa_incremento:
    MOV R1, INCREMENTA
    CMP R0, R1
    JNZ testa_decremento

    MOV R3, [DEF_ENERGIA]
    INC R3
    MOV [DEF_ENERGIA], R3
    CALL escreve_energia

    JMP espera_nao_tecla

testa_decremento:
    MOV R1, DECREMENTA
    CMP R0, R1
    JNZ espera_nao_tecla

    MOV R3, [DEF_ENERGIA]
    SUB R3, 1
    MOV [DEF_ENERGIA], R3
    CALL escreve_energia

    JMP espera_nao_tecla

; **********************************************************************
; * ROTINAS
; **********************************************************************

; * Definem em R1 a linha atual, R2 a coluna atual e R4 a tabela do objeto escolhido
ativa_meteoro_mineravel:
    MOV R1, [DEF_POS_METEORO_MIN]
    MOV R2, [DEF_POS_METEORO_MIN+2]
    MOV R4, DEF_MET_MIN
    RET


ativa_meteoro_nao_mineravel:
    MOV R1, [DEF_POS_METEORO_NMIN]
    MOV R2, [DEF_POS_METEORO_NMIN+2]
    MOV R4, DEF_MET_NMIN
    RET


ativa_sonda:
    MOV R1, [DEF_POS_SONDA]
    MOV R2, [DEF_POS_SONDA+2]
    MOV R4, DEF_SONDA
    RET


; * Define as novas coordenadas no objeto na tabela especificada em R3
define_novas_coordenadas:
    ADD R1, R7  ; quanto anda nas linhas
    ADD R2, R8  ; quanto anda nas colunas
    MOV [R3], R1
    MOV [R3+2], R2
    MOV R7, 0
    MOV R8, 0
    RET


; * Vai buscar à memória a energia
escreve_energia:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    MOV R3, [DEF_ENERGIA]
    MOV R0, 0H
    CALL hex_para_dec
    MOV [DISPLAYS], R0
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET


reseta_energia:
    PUSH R0
    MOV  R0, 0
    MOV  [DEF_ENERGIA], R0
    POP  R0
    RET


; **********************************************************************
; CRIA_METEORO_MINERAVEL - Cria um meteoro mineravel nas suas coordenadas
;			               inicais.
;
; **********************************************************************
cria_meteoro_mineravel:
    PUSH R1
    PUSH R2
    PUSH R4
    MOV R1, SPAWN_LIN
    MOV R2, SPAWN1_COL
    MOV [DEF_POS_METEORO_MIN], R1
    MOV [DEF_POS_METEORO_MIN+2], R2
    CALL ativa_meteoro_mineravel
    CALL desenha_boneco ; desenha o boneco a partir da tabela
    POP R4
    POP R2
    POP R1
    RET

; **********************************************************************
; CRIA_METEORO_NAO_MINERAVEL - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
cria_meteoro_nao_mineravel:
    PUSH R1
    PUSH R2
    PUSH R4
    MOV R1, SPAWN_LIN
    MOV R2, SPAWN3_COL
    MOV [DEF_POS_METEORO_NMIN], R1
    MOV [DEF_POS_METEORO_NMIN+2], R2
    CALL ativa_meteoro_nao_mineravel
    CALL desenha_boneco
    POP R4
    POP R2
    POP R1
    RET

; **********************************************************************
; CRIA_PAINEL - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
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
    CALL desenha_boneco
    POP R4
    POP R2
    POP R1
    RET

; **********************************************************************
; CRIA_SONDA - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
cria_sonda:
    PUSH R1
    PUSH R2
    PUSH R4
    MOV R1, SPAWN_SND_LIN
    MOV R2, SPAWN2_SND_COL
    MOV [DEF_POS_SONDA], R1
    MOV [DEF_POS_SONDA+2], R2
    CALL ativa_sonda
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
    PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
	MOV	 R5, [R4]		    ; obtém a altura do boneco
    MOV  R8, R4             ; guarda o início da tabela que define o boneco
	ADD	 R8, 4			    ; endereço da cor do 1.º pixel
reinicia_desenha:
    MOV  R7, R2             ; guarda a coluna inicial
    MOV  R6, [R4+2]         ; obtém a largura do boneco
desenha_pixels:       	    ; desenha os pixels do boneco a partir da tabela
	MOV	 R3, [R8]		    ; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel      ; escreve cada pixel do boneco
	ADD	 R8, 2			    ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R7, 1              ; próxima coluna
    SUB  R6, 1			    ; menos uma coluna para tratar
    JNZ  desenha_pixels     ; continua até percorrer toda a largura do objeto
    ADD  R1, 1              ; próxima linha
    SUB  R5, 1			    ; menos uma linha para tratar
    JNZ  reinicia_desenha   ; continua até percorrer toda a largura do objeto
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
	MOV	 R5, [R4]		; obtém a altura do boneco
    MOV  R8, R4         ; guarda o início da tabela que define o boneco
reinicia_apaga:
    MOV  R7, R2         ; guarda a coluna inicial
    MOV  R6, [R4+2]     ; obtém a largura do boneco
apaga_pixels:       	; desenha os pixels do boneco a partir da tabela
	MOV	 R3, 0		    ; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel  ; escreve cada pixel do boneco
    ADD  R7, 1          ; próxima coluna
    SUB  R6, 1			; menos uma coluna para tratar
    JNZ  apaga_pixels   ; continua até percorrer toda a largura do objeto
    ADD  R1, 1          ; próxima linha
    SUB  R5, 1			; menos uma linha para tratar
    JNZ  reinicia_apaga ; continua até percorrer toda a largura do objeto
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
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R7		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
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
; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
; Argumentos:	R6 - linha a testar (em formato 1, 2, 4 ou 8)
;
; Retorna: 	R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)	
; **********************************************************************
teclado:
	PUSH	R2
	PUSH	R3
	PUSH	R5
	MOV  R2, TEC_LIN   ; endereço do periférico das linhas
	MOV  R3, TEC_COL   ; endereço do periférico das colunas
	MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6      ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
	AND  R0, R5        ; elimina bits para além dos bits 0-3
    JNZ teclado_saida
teclado_saida:
    POP	R5
	POP	R3
	POP	R2
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
    CALL converte_loop
    SHL  R3, 2
    MOV  R6, R0
    CALL converte_loop
    MOV  R0, R3
    POP  R6
    POP  R3
    RET

converte_loop:
    PUSH R2
    MOV R2, 0
loop:
    ADD R2, 1
    SHR R6, 1
    JNZ loop
    SUB R2, 1           ; retira 1 para passar a um numero entre 0 e 3
    ADD R3, R2
    POP R2
    RET


; **********************************************************************
; HEX_PARA_DEC - Converte um número hexadecimal num número decimal.
;
; Argumentos:   R3 - número hexadecimal
;
; Retorna:      R0 - número decimal correspondente
; **********************************************************************
hex_para_dec:
    SHL R0, 4
    MOV R1, R3   
    AND R1, MASCARA   ;obter apenas o último dígito
    MOV R2, 9H
    CMP R2, R1   ;verificar se é de A a F
    JNN 
   
    MOV R4, 0AH
    MOD R1, R4   ;dígito que deve substituir o anterior
monta_decimal:
   
    ADD R0, R1
    SHR R3, 4
    JNZ hex_para_dec
    RET
