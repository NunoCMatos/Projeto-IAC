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
MIN_LINHA		            EQU 0       ; número da coluna mais à esquerda do ecrã
MIN_COLUNA		            EQU 0		; número da coluna mais à esquerda do ecrã
MAX_LINHA		            EQU 31      ; número da coluna mais à direita do ecrã
MAX_COLUNA		            EQU 63      ; número da coluna mais à direita do ecrã
ATRASO			            EQU 10H     ; atraso para limitar a velocidade de movimento do boneco

; **********************************************************************
; * Periféricos
; **********************************************************************
DISPLAYS   EQU 0A000H   ; endereço dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H   ; endereço das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H   ; endereço das colunas do teclado (perif�rico PIN)
MOVE_METEORO EQU 0FH    ; tecla que faz o meteoro mover
MOVE_SONDA EQU 0BH      ; tecla que faz a sonda mover
INCREMENTA EQU 01H      ; tecla que incrementa o contador
DECREMENTA EQU 00H      ; tecla que decrementa o contador
C_LINHA    EQU 10H      ; número para o ciclo de varrimento do teclado

; **********************************************************************
; * Máscaras
; **********************************************************************
MASCARA    EQU 0FH  ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

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
SPAWN3_SND_COL  EQU 48  ; coluna do 3.º spawnpoint (direita do painel)

LIN_PAINEL  EQU 27      ; linha do painel da nave
COL_PAINEL  EQU 25      ; coluna do painel da nave

; * Tamanhos
LARGURA     EQU 5   ; largura dos meteoros (mineráveis ou não)
ALTURA      EQU 5   ; altura dos meteoros (mineráveis ou não)
LAR_PAINEL  EQU 15  ; largura do painel da nave
ALT_PAINEL  EQU 5   ; altura do painel da nave
LAR_SONDA   EQU 1   ; largura das sondas
ALT_SONDA   EQU 1   ; altura das sondas

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
    WORD SPAWN_LIN, SPAWN1_COL          ; localização do meteoro minerável (linha e coluna)

DEF_POS_METEORO_NMIN:
    WORD SPAWN_LIN, SPAWN3_COL          ; localização do meteoro não minerável(linha e coluna)

DEF_POS_SONDA:
    WORD SPAWN_SND_LIN, SPAWN2_SND_COL  ; localização da sonda(linha e coluna)

DEF_ENERGIA:
    WORD 0                              ; energia da nave
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
    MOV [APAGA_AVISO], R0	            ; apaga o aviso do ecrã
    MOV [APAGA_ECRA], R0	            ; apaga todos os pixels já desenhados
    MOV R0, 0                           ; cenário de fundo número 0
    MOV [SELECIONA_CENARIO_FUNDO], R0   ; seleciona o cenário de fundo

    ; * Gerais
    MOV R5, MASCARA

cria_bonecos:
    CALL cria_meteoro_mineravel         ; cria um meteoro minerável no 1.º spawnpoint
    CALL cria_meteoro_nao_mineravel     ; cria um meteoro não minerável no 3.º spawnpoint
    CALL cria_painel                    ; cria o painel na sua posição
    CALL cria_sonda                     ; cria uma sonda no 2.º spawnpoint
    CALL reseta_energia                 ; reinicia a energia guardada em memória
    CALL escreve_energia                ; escreve a energia no display
    JMP ciclo_teclado_tecla

espera_nao_tecla:			; neste ciclo espera-se até NÃO haver nenhuma tecla premida
	CALL teclado			; leitura às teclas
	CMP	 R0, 0
	JNZ	 espera_nao_tecla	; espera, enquanto houver tecla uma tecla carregada

ciclo_teclado_tecla:
    MOV R6, C_LINHA         ; reinicia o ciclo, começando em 10H para passar a 8
espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
	SHR R6, 1	            ; passa de linha
    JZ ciclo_teclado_tecla  ; Se o SHR der 0 volta ao início
	CALL teclado			; leitura às teclas
	CMP	 R0, 0
	JZ	 espera_tecla		; espera, enquanto não houver tecla carregada
	
    CALL converte

testa_meteoro:
    MOV R1, MOVE_METEORO
	CMP	R0, R1                      ; verifica se a tecla carregada foi a que move o meteoro
	JNZ	testa_sonda                 ; se não for, testa outra tecla

    MOV	R9, 0			            ; som com número 0
	MOV [TOCA_SOM], R9		        ; toca som
	MOV	R7, +1			            ; vai deslocar para baixo
    MOV R8, +1                      ; vai deslocar para a direita
    MOV R3, DEF_POS_METEORO_MIN     ; ativa a tabela com a posição do meteoro
    CALL ativa_meteoro_mineravel    ; ativa as informações sobre o meteoro
	JMP	move_boneco                 ; move o boneco

testa_sonda:
    MOV R1, MOVE_SONDA
	CMP	R0, R1              ; verifica se a tecla carregada foi a que move a sonda
	JNZ	testa_incremento    ; se não for, testa outra tecla

	MOV	R7, -1              ; vai deslocar para cima
    MOV R8, 0               ; matem-se nas colunas
    MOV R3, DEF_POS_SONDA   ; ativa a tabela com a posição da sonda
    CALL ativa_sonda        ; ativa as informações sobre a sonda

    move_boneco:
    	CALL apaga_boneco		        ; apaga o boneco na sua posição atual

    coluna_seguinte:
    	CALL define_novas_coordenadas	; escreve as novas coordenadas na memória

    	CALL desenha_boneco		        ; desenha o boneco nas novas coordenadas

    JMP espera_nao_tecla                ; volta a esperar que não haja tecla carregada

testa_incremento:
    MOV R1, INCREMENTA
    CMP R0, R1              ; verifica se a tecla carregada foi a que incrementa o display
    JNZ testa_decremento    ; se não for, testa outra tecla

    MOV R3, [DEF_ENERGIA]   ; lê a energia guardada em memória
    INC R3                  ; incrementa
    MOV [DEF_ENERGIA], R3   ; escreve a energia atualizada na memória
    CALL escreve_energia    ; escreve a energia atualizada no display

    JMP espera_nao_tecla    ; volta a espera que não haja tecla carregada

testa_decremento:
    MOV R1, DECREMENTA
    CMP R0, R1              ; verifica se a tecla carregada foi a que incrementa o display
    JNZ espera_nao_tecla    ; se não for, nenhuma tecla interessa

    MOV R3, [DEF_ENERGIA]   ; lê a energia guardada em memória
    SUB R3, 1               ; decrementa
    MOV [DEF_ENERGIA], R3   ; escreve a energia atualizada na memória
    CALL escreve_energia    ; escreve a energia atualizada no display

    JMP espera_nao_tecla    ; volta a espera que não haja tecla carregada

; **********************************************************************
; * ROTINAS
; **********************************************************************

; **********************************************************************
; ATIVA_METEORO_NAO_MINERAVEL - Retorna as informações para desenhar 
;                               o meteoro minerável.
;
; Retorna:      R1 - Linha atual
;               R2 - Coluna atual
;               R4 - Tabela do meteoro minerável
;
; **********************************************************************
ativa_meteoro_mineravel:
    MOV R1, [DEF_POS_METEORO_MIN]   ; escreve a linha em que o meteoro minerável está em R1
    MOV R2, [DEF_POS_METEORO_MIN+2] ; escreve a coluna em que o meteoro minerável está em R2
    MOV R4, DEF_MET_MIN             ; escreve a tabela que define o meteoro minerável em R4
    RET


; **********************************************************************
; ATIVA_METEORO_NAO_MINERAVEL - Retorna as informações para desenhar 
;                               o meteoro não minerável.
;
; Retorna:      R1 - Linha atual
;               R2 - Coluna atual
;               R4 - Tabela do meteoro não minerável
;
; **********************************************************************
ativa_meteoro_nao_mineravel:
    MOV R1, [DEF_POS_METEORO_NMIN]      ; escreve a linha em que o meteoro não minerável está em R1
    MOV R2, [DEF_POS_METEORO_NMIN+2]    ; escreve a coluna em que o meteoro não minerável está em R2
    MOV R4, DEF_MET_NMIN                ; escreve a tabela que define o meteoro não minerável em R4
    RET


; **********************************************************************
; ATIVA_SONDA - Retorna as informações para desenhar a sonda.
;
; Retorna:      R1 - Linha atual
;               R2 - Coluna atual
;               R4 - Tabela da sonda
;
; **********************************************************************
ativa_sonda:
    MOV R1, [DEF_POS_SONDA]     ; escreve a linha em que a sonda está em R1
    MOV R2, [DEF_POS_SONDA+2]   ; escreve a coluna em que a sonda está em R2
    MOV R4, DEF_SONDA           ; escreve a tabela que define a sonda em R4
    RET


; **********************************************************************
; DEFINE_NOVAS_COORDENADAS - Define as novas coordenadas.
;
; Argumentos:   R1 - Linha atual
;               R2 - Coluna atual
;               R3 - Tabela das coordenadas
;               R7 - (In/De)cremento das linhas
;               R8 - (In/De)cremento das colunas
; 
; Retorna:      R1 - Linha atualizada
;               R2 - Coluna atualizada
;
; **********************************************************************
define_novas_coordenadas:
    ADD R1, R7      ; avança a coordenada nas linhas
    ADD R2, R8      ; avança a coordenada nas colunas
    MOV [R3], R1    ; guarda a coordenada da linha na memória
    MOV [R3+2], R2  ; guarda as coordenada da coluna na memória
    RET


; **********************************************************************
; ESCREVE_ENERGIA - Lê a energia em memória e escreve no display.
;
; **********************************************************************
escreve_energia:
    PUSH R3
    MOV R3, [DEF_ENERGIA]   ; lê a energia guardada em memória
    MOV [DISPLAYS], R3      ; escreve a energia no display
    POP R3
    RET


; **********************************************************************
; RESETA_ENERGIA - Reinicia a energia em memória.
;
; **********************************************************************
reseta_energia:
    PUSH R0
    MOV  R0, 0              
    MOV  [DEF_ENERGIA], R0  ; reinicia a energia em memória  
    POP  R0
    RET


; **********************************************************************
; CRIA_METEORO_MINERAVEL - Cria um meteoro minerável no 1.º spawnpoint.
;
; **********************************************************************
cria_meteoro_mineravel:
    PUSH R1
    PUSH R2
    PUSH R4
    MOV R1, SPAWN_LIN
    MOV R2, SPAWN1_COL
    MOV [DEF_POS_METEORO_MIN], R1   ; define a coordenada inicial das linhas do meteoro minerável
    MOV [DEF_POS_METEORO_MIN+2], R2 ; define a coordenada inicial das colunas do meteoro minerável
    CALL ativa_meteoro_mineravel
    CALL desenha_boneco             ; desenha o meteoro minerável
    POP R4
    POP R2
    POP R1
    RET

; **********************************************************************
; CRIA_METEORO_NAO_MINERAVEL - Cria um meteoro não minerável no
;                              3.º spawnpoint.
;
; **********************************************************************
cria_meteoro_nao_mineravel:
    PUSH R1
    PUSH R2
    PUSH R4
    MOV R1, SPAWN_LIN
    MOV R2, SPAWN3_COL
    MOV [DEF_POS_METEORO_NMIN], R1      ; define a coordenada inicial das linhas do meteoro não minerável
    MOV [DEF_POS_METEORO_NMIN+2], R2    ; define a coordenada inicial das colunas do meteoro não minerável
    CALL ativa_meteoro_nao_mineravel
    CALL desenha_boneco                 ; desenha o meteoro não minerável
    POP R4
    POP R2
    POP R1
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
    CALL desenha_boneco ; desenha o painel
    POP R4
    POP R2
    POP R1
    RET

; **********************************************************************
; CRIA_SONDA - Cria uma sonda no 2.º spawnpoint.
;
; **********************************************************************
cria_sonda:
    PUSH R1
    PUSH R2
    PUSH R4
    MOV R1, SPAWN_SND_LIN
    MOV R2, SPAWN2_SND_COL
    MOV [DEF_POS_SONDA], R1     ; define a coordenada inicial das linhas da sonda
    MOV [DEF_POS_SONDA+2], R2   ; define a coordenada inicial das colunas da sonda
    CALL ativa_sonda
    CALL desenha_boneco         ; desenha a sonda
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
