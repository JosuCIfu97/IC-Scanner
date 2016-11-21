#define _XOPEN_SOURCE 700

#include <stdio.h>

#include <stdlib.h>

#include <signal.h>

#include <string.h>

#include <termios.h>

#include <time.h>

#include <unistd.h>


struct termios config_actual;

struct termios config_nueva;



void enable_key_config()
{
    
	tcgetattr(fileno(stdin), &config_actual); // Cargar a la estructura la configuraciond de la terminal

	memcpy(&config_nueva, &config_actual, sizeof(struct termios)); // Copiar a la nueva estructura
    
	config_nueva.c_lflag &= ~(ECHO|ICANON); // Eliminar la impresion en la consola mientras se lee
    
	config_nueva.c_cc[VTIME] = 0; // Cambiar atributo para que el poll sea inmediato
    
	config_nueva.c_cc[VMIN] = 0; // Cambiar atributo para que el poll sea inmediato 
    
	tcsetattr(fileno(stdin), TCSANOW, &config_nueva);
	
}



/* funcion que regresa a su estado inicial la consola */

void disable_key_config()
{
    
	tcsetattr(fileno(stdin), TCSANOW, &config_actual);   
	
}



/* Funcion en caso de emergencia */

void secure_leave(int s)
{
    
	disable_key_config();
    
	exit(1);
}



/* Preprar la salida de ctrl + c*/

void handle_ctrl_c()
{
    
	struct sigaction handler;

    
	handler.sa_handler = secure_leave;
    
	sigemptyset(&handler.sa_mask);
    
	handler.sa_flags = 0;

    
	sigaction(SIGINT, &handler, NULL);

	}



int getKey() 
{
    
	int caracter_leido;
    
	caracter_leido = fgetc(stdin); // Cargar al caracter
    
	fflush(stdin); // Vaciar el buffer     
    
	return caracter_leido;

	}