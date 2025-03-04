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

#define AES_DEC_0_BASE 0x0

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

void encrypt(char* buf) {
	printf("Em cima\n");
	unsigned int plaintext[4];
	unsigned int cyphertext[4];
	unsigned int enc_key[4];
	int i;
	for(i = 0; i < 4; ++i){
		plaintext[i] = ((unsigned char) buf[0 + i*4] << 24) |
				       ((unsigned char) buf[1 + i*4] << 16) |
				       ((unsigned char) buf[2 + i*4] << 8)  |
				       ((unsigned char) buf[3 + i*4]);
	}


	for(i = 0; i < 4; ++i){
		enc_key[i] =   ((unsigned char) buf[16 + i*4] << 24) |
				       ((unsigned char) buf[17 + i*4] << 16) |
				       ((unsigned char) buf[18 + i*4] << 8)  |
				       ((unsigned char) buf[19 + i*4]);
	}



	// write input text.
	for(i = 0; i < 4; ++i){
		IOWR(AES_DEC_0_BASE, 4*i, plaintext[4-1-i]);
	}


	// write key
	for(i = 0; i < 4; ++i) {
		IOWR(AES_DEC_0_BASE, 4*i + 16, enc_key[4-1-i]);
	}
	printf("Final\n");


	// write at start reg
	IOWR(AES_DEC_0_BASE, 60, 1);
	while(IORD(AES_DEC_0_BASE, 48) != 1){
		printf("IORD: %d\n", IORD(AES_DEC_0_BASE, 48));
	}
	// read from output regs
	for(i = 0; i < 4; ++i) {
		cyphertext[i] = IORD(AES_DEC_0_BASE, 4*i + 32);
	}

	// print cryptography:
	printf("Mensagem Decriptografada: ");
	for(i = 0; i < 4; ++i){
		printf("%X", cyphertext[4-1-i]);
	}

}

void SSSInitialTask(void *task_data)
{
  INT8U error_code;

  alt_iniche_init();
  netmain();

  while (!iniche_net_ready)
    TK_SLEEP(1);

  int sw, but;
  char flag = 0;
  char lastbut = 0x0F;
  char choice = 0;
  struct sockaddr_in sa;
  int res;
  int SocketFD;
  char reqA[6]= "queroa";
  char buf[2000];
  SocketFD = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
  printf("Socket criado\n");
  memset(&sa, 0, sizeof sa);
  sa.sin_family = AF_INET;
  sa.sin_port = htons(7777); // ALTERAR PORTA A SER UTILIZADA AQUI
  res = inet_pton(AF_INET, "192.168.88.254", &sa.sin_addr); //ALTERAR O IP DO SERVIDOR AQUI
  if (connect(SocketFD, (struct sockaddr *)&sa, sizeof sa) == -1) {
	perror("connect failed");
	close(SocketFD);
	exit(EXIT_FAILURE);
  }

  while (1){
	  	sw = IORD_ALTERA_AVALON_PIO_DATA(SWITCH_PIO_BASE) & 0x03;
		but = IORD_ALTERA_AVALON_PIO_DATA(BUTTON_PIO_BASE) & 0x0F;

		  	if(flag == 0)
		  	{
		  		if(but == 13 && but != lastbut)
		  		{
		  			flag = 1;
		  			if(sw == 0)
		  			{
		  				choice = 1;
		  			    if (send(SocketFD, reqA, sizeof(reqA), 0) < 0) //exemplo de envio
		  			    {
		  			        perror("Send()");
		  			        exit(EXIT_FAILURE);
		  			    }
		  			    if (recv(SocketFD, buf, sizeof(buf), 0) < 0) //exemplo de recebimento
		  			    {
		  			        perror("Recv()");
		  			        exit(EXIT_FAILURE);
		  			    }else{
		  			    	encrypt(buf);
		  			    }
		  			}
		  		}
		  	}
		  	lastbut=but;

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

