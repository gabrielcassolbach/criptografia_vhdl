/******************************************************************************
* Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
*******************************************************************************                                                                             *
* Date - October 24, 2006                                                     *
* Module - iniche_init.c                                                      *
*                                                                             *                                                                             *
******************************************************************************/

/******************************************************************************
 * NicheStack TCP/IP stack initialization and Operating System Start in main()
 * for Simple Socket Server (SSS) example.
 *
 * This example demonstrates the use of MicroC/OS-II running on NIOS II.
 * In addition it is to serve as a good starting point for designs using
 * MicroC/OS-II and Altera NicheStack TCP/IP Stack - NIOS II Edition.
 *
 * Please refer to the Altera NicheStack Tutorial documentation for details on
 * this software example, as well as details on how to configure the NicheStack
 * TCP/IP networking stack and MicroC/OS-II Real-Time Operating System.
 */

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

 OS_STK    SSSInitialTaskStk[TASK_STACKSIZE];

 TK_OBJECT(to_ssstask);
 TK_ENTRY(SSSSimpleSocketServerTask);

 struct inet_taskinfo ssstask = {
       &to_ssstask,
       "simple socket server",
       SSSSimpleSocketServerTask,
       4,
       APP_STACK_SIZE,
 };

 void decrypt(char* buf, clientFD, listenFD) {
     printf("inside decrypt\n");

     unsigned int encrypted_word[4];
     unsigned int key_word[4];
     unsigned int decrypted_word[4];
     int i;

     /* Search for separator ';' (0x3B) in the received data */
     int sep_index = -1;
     for (i = 0; i < sizeof(buf); i++)
     {
         if (buf[i] == 0x3B)
         {
             sep_index = i;
             break;
         }
     }

     if (sep_index == -1)
     {
         printf("Separator ';' (0x3B) not found in the message.\n");
         fflush(stdout);
         close(clientFD);
         close(listenFD);
         exit(EXIT_FAILURE);
     }
     printf("Separator found at position %d\n", sep_index);

     /* Determine lengths for ciphertext and key */
     int text_len = sep_index;                     /* Bytes before separator */
     int key_len = sizeof(buf) - sep_index - 1; /* Bytes after separator */


     /* Prepare 16-byte arrays for ciphertext and key, zero-padded */
     unsigned char text_buffer[16] = {0};
     unsigned char key_buffer[16] = {0};

     memcpy(text_buffer, buf, text_len);
     memcpy(key_buffer, buf + sep_index + 1, key_len);

     for (i = 0; i < 4; i++)
     {
         encrypted_word[i] = ((unsigned int)text_buffer[i * 4] << 24) |
                             ((unsigned int)text_buffer[i * 4 + 1] << 16) |
                             ((unsigned int)text_buffer[i * 4 + 2] << 8) |
                             ((unsigned int)text_buffer[i * 4 + 3]);
     }
     for (i = 0; i < 4; i++)
     {
         key_word[i] = ((unsigned int)key_buffer[i * 4] << 24) |
                       ((unsigned int)key_buffer[i * 4 + 1] << 16) |
                       ((unsigned int)key_buffer[i * 4 + 2] << 8) |
                       ((unsigned int)key_buffer[i * 4 + 3]);
     }

     /* Write the 4 words of ciphertext to the AES module.
      * (If required by your design, the order may be reversed; adjust as needed.)
      */
     for (i = 0; i < 4; i++)
     {
         IOWR(AES_DEC_0_BASE, 4 * i, encrypted_word[3 - i]);
     }
     /* Write the 4 words of the key to the AES module, starting at offset 16 */
     for (i = 0; i < 4; i++)
     {
         IOWR(AES_DEC_0_BASE, 4 * i + 16, key_word[3 - i]);
     }

     /* Trigger decryption by writing 1 to the start register (offset 60) */
     IOWR(AES_DEC_0_BASE, 60, 1);

     /* Wait (polling) until the finished register (offset 48) becomes 1 */
     while (IORD(AES_DEC_0_BASE, 48) != 1)
         TK_SLEEP(1);

     /* Read the plaintext from the AES module (offsets 32, 36, 40, 44) */
     for (i = 0; i < 4; i++)
     {
         decrypted_word[i] = IORD(AES_DEC_0_BASE, 4 * i + 32);
     }

     /* Print the decrypted text in hexadecimal */
     printf("Decrypted text:\n");
     for (i = 0; i < 4; i++)
     {
         printf("0x%08X ", decrypted_word[i]);
     }
     printf("\n");
     fflush(stdout);

     close(clientFD);
     close(listenFD);
 }

 void SSSInitialTask(void *task_data)
 {
   INT8U error_code;

   alt_iniche_init();
   netmain();

   while (!iniche_net_ready)
     TK_SLEEP(1);

   printf("\nSimple Socket Decryption starting up\n");
   fflush(stdout);
   LCD_Init();
   LCD_Show_Text("Waiting for client");

   int listenFD, clientFD;
   struct sockaddr_in server_addr, client_addr;
   int addr_len = sizeof(client_addr);
   char buf[2000]; /* Buffer to accumulate data from socket */
   int total_received = 0;
   int num_bytes;

   /* Create server socket */
   listenFD = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
   if (listenFD < 0)
   {
       perror("socket failed");
       exit(EXIT_FAILURE);
   }
   printf("Socket created: %d\n", listenFD);
   fflush(stdout);

   memset(&server_addr, 0, sizeof(server_addr));
   server_addr.sin_family = AF_INET;
   server_addr.sin_port = htons(7777);       /* Desired port */
   server_addr.sin_addr.s_addr = INADDR_ANY;   /* Listen on all interfaces */

   if (bind(listenFD, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
   {
       perror("bind failed");
       close(listenFD);
       exit(EXIT_FAILURE);
   }
   if (listen(listenFD, 5) < 0)
   {
       perror("listen failed");
       close(listenFD);
       exit(EXIT_FAILURE);
   }
   printf("Server waiting for connection on port 7777...\n");
   fflush(stdout);
   LCD_Show_Text("Waiting for client...");

   clientFD = accept(listenFD, (struct sockaddr *)&client_addr, (int *)&addr_len);
   if (clientFD < 0)
   {
       perror("accept failed");
       close(listenFD);
       exit(EXIT_FAILURE);
   }
   printf("Cliente conectado!\n");
   fflush(stdout);
   LCD_Show_Text("Cliente conectado");

   while (1){
           int sw = IORD_ALTERA_AVALON_PIO_DATA(SWITCH_PIO_BASE) & 0x03;
         int but = IORD_ALTERA_AVALON_PIO_DATA(BUTTON_PIO_BASE) & 0x0F;

         if (recv(clientFD, buf, sizeof(buf), 0) < 0) //exemplo de recebimento
         {
             decrypt(buf, clientFD, listenFD);
         }else{
             perror("Recv()");
             exit(EXIT_FAILURE);
         }

         msleep(100);
   }
 }

 /* Main creates a single task, SSSInitialTask, and starts task scheduler.
  */

 int main (int argc, char* argv[], char* envp[])
 {

   INT8U error_code;

   DM9000A_INSTANCE( DM9000A_0, dm9000a_0 );
   DM9000A_INIT( DM9000A_0, dm9000a_0 );

   /* Clear the RTOS timer */
   OSTimeSet(0);

   /* SSSInitialTask will initialize the NicheStack
    * TCP/IP Stack and then initialize the rest of the Simple Socket Server example
    * RTOS structures and tasks.
    */
   error_code = OSTaskCreateExt(SSSInitialTask,
                              NULL,
                              (void *)&SSSInitialTaskStk[TASK_STACKSIZE],
                              SSS_INITIAL_TASK_PRIORITY,
                              SSS_INITIAL_TASK_PRIORITY,
                              SSSInitialTaskStk,
                              TASK_STACKSIZE,
                              NULL,
                              0);
   alt_uCOSIIErrorHandler(error_code, 0);

   /*
    * As with all MicroC/OS-II designs, once the initial thread(s) and
    * associated RTOS resources are declared, we start the RTOS. That's it!
    */
   OSStart();

   while(1); /* Correct Program Flow never gets here. */

   return -1;
 }

