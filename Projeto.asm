; =============================================================================
;  TRABALHO 1 - ANALISE E MANIPULACAO DE DADOS EM MEMORIA SEGMENTADA
;  Microprocessador 8086 - Emulator YJDoc2
;  (https://yjdoc2.github.io/8086-emulator-web/)
; -----------------------------------------------------------------------------
;  Programa que armazena um vetor de inteiros de 8 bits, percorre-o com SI,
;  e calcula SOMA (em AX), MAIOR (em BH) e MENOR (em DL).
;  Resultados sao gravados em memoria nas variaveis soma, maior, menor.
; =============================================================================
;
;  REGISTRADORES UTILIZADOS
;    DS  - Data Segment (base implicita dos acessos a memoria)
;    SI  - Source Index (ponteiro que percorre o vetor)
;    CX  - Contador do laco (LOOP decrementa CX a cada iteracao)
;    AX  - Acumulador da SOMA (16 bits: AH alto + AL baixo)
;    BL  - Byte atual lido do vetor
;    BH  - MAIOR valor encontrado ate o momento
;    DL  - MENOR valor encontrado ate o momento
;
;  FLAGS OBSERVADAS
;    ZF (Zero Flag)  - liga quando o resultado e zero (fim do laco)
;    SF (Sign Flag)  - liga quando o bit mais alto do resultado e 1
;    CF (Carry Flag) - liga em "vai-um" na soma ou "empresta-um" em CMP/SUB
; =============================================================================


; -----------------------------------------------------------------------------
; SECAO DE DADOS
;   Neste emulador, todas as diretivas de dados (DB/DW) DEVEM vir antes
;   do codigo. Os dados ficam no inicio do segmento (offset 0 em diante).
; -----------------------------------------------------------------------------

vetor:  DB 25            ; VETOR[0] -> offset 0
        DB 47            ; VETOR[1] -> offset 1
        DB 12            ; VETOR[2] -> offset 2
        DB 89            ; VETOR[3] -> offset 3
        DB 3             ; VETOR[4] -> offset 4
        DB 56            ; VETOR[5] -> offset 5
        DB 71            ; VETOR[6] -> offset 6
        DB 34            ; VETOR[7] -> offset 7

soma:   DW 0             ; resultado: SOMA (16 bits) -> offset 8-9
maior:  DB 0             ; resultado: MAIOR (8 bits) -> offset 10
menor:  DB 0             ; resultado: MENOR (8 bits) -> offset 11


; -----------------------------------------------------------------------------
; CODIGO
;   O rotulo "start:" e o ponto de entrada obrigatorio do programa.
; -----------------------------------------------------------------------------

start:

; Imprime o estado inicial (vetor carregado, resultados ainda zerados)
print mem 0:11

; --- PASSO 1: Inicializar ponteiro, contador e acumuladores ---
mov si, offset vetor    ; SI <- offset do primeiro byte do vetor (= 0)
mov cx, 8               ; CX <- 8 (tamanho do vetor)
mov ax, 0               ; AX <- 0 (acumulador da SOMA)
mov bh, 0               ; BH <- 0 (candidato a MAIOR)
mov dl, 0xFF            ; DL <- 255 (candidato a MENOR)


; -----------------------------------------------------------------------------
; LACO PRINCIPAL - repete 8 vezes (controlado por CX via instrucao LOOP)
; -----------------------------------------------------------------------------
laco:
    ; --- Le o byte atual do vetor: BL <- DS:[SI] ---
    mov bl, byte ds[si]     ; aqui acontece o acesso SEGMENTADO

    ; --- Soma BL no acumulador AX (16 bits) ---
    add al, bl              ; AL <- AL + BL (afeta CF, ZF, SF)
    adc ah, 0               ; AH <- AH + 0 + CF (propaga o vai-um)

    ; --- Atualiza o MAIOR ---
    ; CMP faz BL - BH (so atualiza flags).
    ; JBE = Jump if Below or Equal (CF=1 OU ZF=1)
    cmp bl, bh
    jbe nao_e_maior
    mov bh, bl              ; BH <- BL (novo maior)
nao_e_maior:

    ; --- Atualiza o MENOR ---
    ; JAE = Jump if Above or Equal (CF=0)
    cmp bl, dl
    jae nao_e_menor
    mov dl, bl              ; DL <- BL (novo menor)
nao_e_menor:

    ; --- Avanca o ponteiro e fecha o laco ---
    inc si                  ; SI <- SI + 1 (proximo byte)
    loop laco               ; CX <- CX - 1; se CX != 0, volta para laco


; -----------------------------------------------------------------------------
; PASSO 2: Gravar resultados na memoria
; -----------------------------------------------------------------------------
mov word soma, ax           ; SOMA  <- AX (2 bytes, little-endian)
mov byte maior, bh          ; MAIOR <- BH
mov byte menor, dl          ; MENOR <- DL


; Imprime o estado final: memoria atualizada, registradores e flags
print mem 0:11
print reg
print flags


; -----------------------------------------------------------------------------
; PASSO 3: Encerrar o programa
; -----------------------------------------------------------------------------
hlt
