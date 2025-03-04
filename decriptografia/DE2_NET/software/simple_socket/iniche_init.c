/******************************************************************************
 * NicheStack TCP/IP stack initialization and Operating System Start in main()
 * for Simple Socket Server (SSS) example � Apenas para decriptografia AES.
 *
 * Este c�digo implementa somente a parte de decriptografia. Ele espera receber via
 * conex�o TCP uma mensagem no formato "texto;chave", onde:
 *   - "texto" � o bloco criptografado (16 bytes, ou 128 bits)
 *   - "chave" � a chave de criptografia (at� 16 bytes, ou 128 bits)
 *
 * O c�digo converte esses 16 bytes em 4 palavras de 32 bits cada, envia-os para o
 * m�dulo de decriptografia implementado via interface Avalon, aciona o m�dulo, e ent�o
 * l� o resultado (texto descriptografado) dos registradores de sa�da.
 *
 * Ajuste os endere�os e o protocolo de convers�o conforme sua implementa��o.
 ******************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <io.h>
#include <fcntl.h>

/* MicroC/OS-II definitions */
#include "../simple_socket_bsp/HAL/inc/includes.h"
#include "../simple_socket_bsp/system.h"
#include "dm9000a.h"

/* Simple Socket Server definitions */
#include "simple_socket_server.h"
#include "alt_error_handler.h"

/* Nichestack definitions */
#include "../simple_socket_bsp/iniche/src/h/nios2/ipport.h"
#include "../simple_socket_bsp/iniche/src/h/tcpport.h"
#include "../simple_socket_bsp/iniche/src/h/libport.h"
#include "../simple_socket_bsp/iniche/src/nios2/osport.h"

#include "basic_io.h"
#include "LCD.h"
#include "altera_avalon_pio_regs.h"

/* Defini��es de endere�os */
#define SDRAM_BASE 0x08000000     // Endere�o base da SDRAM (se necess�rio)
#define DEC0_BASE  0x00000000     // Endere�o base do m�dulo de decriptografia AES
                                  // Ajuste conforme seu sistema

/* Tamanho da stack da tarefa */
OS_STK SSSDecryptionTaskStk[TASK_STACKSIZE];

/* Declara��es para cria��o de tarefa com TK_NEWTASK */
TK_OBJECT(to_ssstask);
TK_ENTRY(SSSDecryptionTask);  // Renomeamos a fun��o para evitar conflito

struct inet_taskinfo ssstask = {
    &to_ssstask,
    "simple socket decryption",
    SSSDecryptionTask,
    4,
    APP_STACK_SIZE,
};

void SSSDecryptionTask(void *task_data)
{
    INT8U error_code;

    /* Inicializa a pilha TCP/IP e espera que esteja pronta */
    alt_iniche_init();
    netmain();
    while (!iniche_net_ready)
        TK_SLEEP(1);

    printf("\nSimple Socket Decryption starting up\n");
    LCD_Init();
    LCD_Show_Text("Aguardando cliente");

    int listenFD, clientFD;
    struct sockaddr_in server_addr, client_addr;
    int addr_len = sizeof(client_addr);
    char buf[2000];

    /* Buffers para armazenar os 16 bytes do texto criptografado e da chave */
    char text_buffer[64];  // Supomos que os 16 bytes �teis estar�o aqui
    char key_buffer[64];   // idem para a chave

    /* Cria o socket para o servidor */
    listenFD = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (listenFD < 0) {
        perror("socket falhou");
        exit(EXIT_FAILURE);
    }
    printf("Socket criado\n");

    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(7777);      // Porta desejada
    server_addr.sin_addr.s_addr = INADDR_ANY;  // Aceita conex�es de qualquer endere�o

    if (bind(listenFD, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("bind falhou");
        close(listenFD);
        exit(EXIT_FAILURE);
    }

    if (listen(listenFD, 5) < 0) {
        perror("listen falhou");
        close(listenFD);
        exit(EXIT_FAILURE);
    }
    printf("Servidor aguardando conexao na porta 7777...\n");
    LCD_Show_Text("Aguardando cliente...");

    clientFD = accept(listenFD, (struct sockaddr *)&client_addr, (int *)&addr_len);
    if (clientFD < 0) {
        perror("accept falhou");
        close(listenFD);
        exit(EXIT_FAILURE);
    }
    printf("Cliente conectado!\n");
    LCD_Show_Text("Cliente conectado");

    /* Vari�veis para a convers�o para 32 bits */
    unsigned int encrypted_word[4];  // Bloco de 128 bits do texto criptografado
    unsigned int key_word[4];        // Bloco de 128 bits da chave
    unsigned int decrypted_word[4];  // Bloco de 128 bits do resultado descriptografado
    int i;

    /* Loop para receber dados via TCP */
    while ((i = recv(clientFD, buf, sizeof(buf) - 1, 0)) > 0) {
        buf[i] = '\0';  // Termina a string
        printf("Recebido: %s\n", buf);

        /* Espera-se o formato "texto;chave" */
        char *token = strtok(buf, ";");
        if (token != NULL) {
            strncpy(text_buffer, token, sizeof(text_buffer));
            token = strtok(NULL, ";");
            if (token != NULL) {
                strncpy(key_buffer, token, sizeof(key_buffer));
            } else {
                printf("Formato invalido: chave nao encontrada.\n");
                continue;
            }
        } else {
            printf("Formato invalido: texto nao encontrado.\n");
            continue;
        }

        /* Converte os 16 bytes do texto para 4 palavras de 32 bits */
        for (i = 0; i < 4; i++) {
            encrypted_word[i] = ((unsigned int)(unsigned char)text_buffer[i*4]   << 24) |
                                ((unsigned int)(unsigned char)text_buffer[i*4+1] << 16) |
                                ((unsigned int)(unsigned char)text_buffer[i*4+2] << 8)  |
                                ((unsigned int)(unsigned char)text_buffer[i*4+3]);
        }
        /* Converte os 16 bytes da chave para 4 palavras de 32 bits */
        for (i = 0; i < 4; i++) {
            key_word[i] = ((unsigned int)(unsigned char)key_buffer[i*4]   << 24) |
                          ((unsigned int)(unsigned char)key_buffer[i*4+1] << 16) |
                          ((unsigned int)(unsigned char)key_buffer[i*4+2] << 8)  |
                          ((unsigned int)(unsigned char)key_buffer[i*4+3]);
        }

        /* Escreve o bloco de texto criptografado nos registradores do m�dulo de decriptografia.
         * Conforme o protocolo descrito, a ordem � invertida.
         * Registradores de entrada (texto) localizados em offsets 0, 4, 8 e 12.
         */
        for (i = 0; i < 4; i++) {
            IOWR(DEC0_BASE, 4 * i, encrypted_word[3 - i]);
        }

        /* Escreve a chave nos registradores do m�dulo de decriptografia a partir do offset 16 */
        for (i = 0; i < 4; i++) {
            IOWR(DEC0_BASE, 4 * i + 16, key_word[3 - i]);
        }

        /* Aciona a opera��o de decriptografia: escreve 1 no registrador de start (offset 60) */
        IOWR(DEC0_BASE, 60, 1);

        /* Aguarda at� que a opera��o termine: polling do registrador finished (offset 48) */
        while (IORD(DEC0_BASE, 48) != 1) {
            ; // Pode-se incluir um delay se necess�rio
        }

        /* L� o bloco de sa�da (texto descriptografado) dos registradores (offsets 32, 36, 40 e 44) */
        for (i = 0; i < 4; i++) {
            decrypted_word[i] = IORD(DEC0_BASE, 4 * i + 32);
        }

        /* Exibe o resultado em hexadecimal */
        printf("Texto descriptografado:\n");
        for (i = 0; i < 4; i++) {
            printf("0x%08X ", decrypted_word[i]);
        }
        printf("\n");

        /* Aqui voc� pode enviar o resultado de volta via socket, armazen�-lo, etc. */
    }

    if (i < 0) {
        perror("recv falhou");
    }

    close(clientFD);
    close(listenFD);

    while (1)
        TK_SLEEP(100);
}

int main (int argc, char* argv[], char* envp[])
{
    INT8U error_code;

    DM9000A_INSTANCE(DM9000A_0, dm9000a_0);
    DM9000A_INIT(DM9000A_0, dm9000a_0);

    OSTimeSet(0);

    error_code = OSTaskCreateExt(SSSDecryptionTask,
                                 NULL,
                                 (void *)&SSSDecryptionTaskStk[TASK_STACKSIZE],
                                 SSS_INITIAL_TASK_PRIORITY,
                                 SSS_INITIAL_TASK_PRIORITY,
                                 SSSDecryptionTaskStk,
                                 TASK_STACKSIZE,
                                 NULL,
                                 0);
    alt_uCOSIIErrorHandler(error_code, 0);

    OSStart();

    while (1)
        TK_SLEEP(100);
    return -1;
}

/******************************************************************************
 *                                                                             *
 * License Agreement                                                           *
 *                                                                             *
 * (restante do license header...)                                             *
 ******************************************************************************/
