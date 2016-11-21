/*------------------------------------------------------------------------
*Universidad del Valle de Guatemala
*Taller de Assembler
*Sección 21
*Josué Cifuentes #15275
*Josué Jacobs #15041
*Pablo Muñoz #15258
*Marcel Velásquez #15534
*21/11/16
*Subrutinas necesarias para análisis de piezas
*subrutinas.s
------------------------------------------------------------------------*/

/*------------------------------------------------------------------------
*Distribución de pines de GPIO:
*Pines del lado izquierdo del socket:
*GPIO 4, 17, 27, 22, 5 y 6
*Pines del lado derecho del socket:
*GPIO 18, 23, 24, 25, 12, 16
------------------------------------------------------------------------*/

.global paint, figure, block, delay, setUnary, setBinary, setAnd3, setOr3
.global cicloNot, cicloAnd2, cicloOr2, cicloXor, cicloAnd3, cicloOr3

/*Subrutina paint:
*Pinta una imagen en pantalla
*Parámetros:
*r0 <- dirección virtual de monitor
*r1 <- posición inicial en x
*r2 <- posición inicial en y
*r3 <- dirección inicial de vector con colores de imagen
*r4 <- ancho de la imagen
*r5 <- altura de la imagen
*Salida: Coloreado en monitor*/
paint:
	mov r6,r0 @Dirección de monitor
	mov r7,r1 @Posición inicial en x
	mov r8,r2 @Posición inicial en y
	mov r9,r3 @Vector de colores
	mov r10,#0 @Contador de columnas
	mov r11,#0 @Contador de filas
fory:
	cmp r11,r5 @Compara altura imagen con contador de filas pintadas
	movge pc,lr
	add r8,#1 @Se le suma uno a la posición en y
	add r11,#1 @Se le suma uno al contador de filas
forx:
	mov r0,r6 @Dirección de monitor
	mov r1,r7 @Posición inicial en x
	mov r2,r8 @Posición inicial en y
	ldrb r3,[r9],#1 @Color de dicha posición y avanza al siguiente byte
	push {r4-r11,lr}
	bl pixel
	pop {r4-r11,lr}
	add r7,#1 @Si no es igual o mayor al ancho, avanza al siguiente pixel de la fila
	add r10,#1 @Suma uno también al contador de columnas.
	cmp r10,r4 @Compara ancho de imagen con contador de columnas pintadas
	subge r7,r4 @Si el contador es mayor o igual a la altura, reinicia la posición en x
	movge r10,#0 @Se reinicia contador también.
	bge fory @Se avanza a la siguiente fila (for en y).
	b forx @Repite el for en x hasta acabar con la fila.

/*Subrutina figure:
*Pinta una imagen omitiendo su color de fondo.
*Parámetros:
*r0 <- dirección virtual de monitor
*r1 <- posición inicial en x
*r2 <- posición inicial en y
*r3 <- dirección inicial de vector con colores de imagen
*r4 <- ancho de la imagen
*r5 <- altura de la imagen
*r6 <- color de fondo a omitir
*Salida: Coloreado en monitor*/
figure:
	mov r12,r6 @Color de fondo a omitir
	mov r6,r0 @Dirección de monitor
	mov r7,r1 @Posición inicial en x
	mov r8,r2 @Posición inicial en y
	mov r9,r3 @Vector de colores
	mov r10,#0 @Contador de columnas
	mov r11,#0 @Contador de filas
foryP:
	cmp r11,r5 @Compara altura imagen con contador de filas pintadas
	movge pc,lr
	add r8,#1 @Se le suma uno a la posición en y
	add r11,#1 @Se le suma uno al contador de filas
forxP:
	mov r0,r6 @Dirección de monitor
	mov r1,r7 @Posición inicial en x
	mov r2,r8 @Posición inicial en y
	ldrb r3,[r9],#1 @Color de dicha posición y avanza al siguiente byte
	cmp r3,r12 @Si el color que toca es el que debe omitirse, no se pinta el pixel.
	push {r4-r12,lr}
	blne pixel
	pop {r4-r12,lr}
	add r7,#1 @Si no es igual o mayor al ancho, avanza al siguiente pixel de la fila
	add r10,#1 @Suma uno también al contador de columnas.
	cmp r10,r4 @Compara ancho de imagen con contador de columnas pintadas
	subge r7,r4 @Si el contador es mayor o igual a la altura, reinicia la posición en x
	movge r10,#0 @Se reinicia contador también.
	bge foryP @Se avanza a la siguiente fila (for en y).
	b forxP @Repite el for en x hasta acabar con la fila.

/*Subrutina block:
*Pinta de un color la pantalla lentamente.
*Parámetros:
*r0 <- dirección virtual de monitor
*r1 <- posición inicial en x
*r2 <- posición inicial en y
*r3 <- color de pantalla
*r4 <- ancho de la imagen
*r5 <- altura de la imagen
*Salida: Coloreado en monitor*/
block:
	mov r6,r0 @Dirección de monitor
	mov r7,r1 @Posición inicial en x
	mov r8,r2 @Posición inicial en y
	mov r9,r3 @Vector de colores
	mov r10,#0 @Contador de columnas
	mov r11,#0 @Contador de filas
foryB:
	push {lr}
	bl delay
	pop {lr}
	cmp r11,r5 @Compara altura imagen con contador de filas pintadas
	movge pc,lr
	add r8,#1 @Se le suma uno a la posición en y
	add r11,#1 @Se le suma uno al contador de filas
forxB:
	mov r0,r6 @Dirección de monitor
	mov r1,r7 @Posición inicial en x
	mov r2,r8 @Posición inicial en y
	mov r3,r9 @Color a utilizar
	push {r4-r11,lr}
	bl pixel
	pop {r4-r11,lr}
	add r7,#1 @Si no es igual o mayor al ancho, avanza al siguiente pixel de la fila
	add r10,#1 @Suma uno también al contador de columnas.
	cmp r10,r4 @Compara ancho de imagen con contador de columnas pintadas
	subge r7,r4 @Si el contador es mayor o igual a la altura, reinicia la posición en x
	movge r10,#0 @Se reinicia contador también.
	bge foryB @Se avanza a la siguiente fila (for en y).
	b forxB @Repite el for en x hasta acabar con la fila.

/*Subrutina setUnary:
*Modifica los pines GPIO para analizar piezas de una entrada (NOT)
*Parámetros: Ninguno
*Salidas: Ninguna*/
setUnary:
	push {lr}
	@Pines Compuerta 1
	@Pin 4 escritura
	mov r0,#4
	mov r1,#1
	bl SetGpioFunction
	@Pin 17 lectura
	mov r0,#17
	mov r1,#0
	bl SetGpioFunction

	@Pines Compuerta 2
	@Pin 27 escritura
	mov r0,#27
	mov r1,#1
	bl SetGpioFunction
	@Pin 22 lectura
	mov r0,#22
	mov r1,#0
	bl SetGpioFunction

	@Pines Compuerta 3
	@Pin 5 escritura
	mov r0,#5
	mov r1,#1
	bl SetGpioFunction
	@Pin 6 lectura
	mov r0,#6
	mov r1,#0
	bl SetGpioFunction

	@Pines Compuerta 4
	@Pin 18 escritura
	mov r0,#18
	mov r1,#1
	bl SetGpioFunction
	@Pin 23 lectura
	mov r0,#23
	mov r1,#0
	bl SetGpioFunction

	@Pines Compuerta 5
	@Pin 24 escritura
	mov r0,#24
	mov r1,#1
	bl SetGpioFunction
	@Pin 25 lectura
	mov r0,#25
	mov r1,#0
	bl SetGpioFunction

	@Pines Compuerta 6
	@Pin 12 escritura
	mov r0,#12
	mov r1,#1
	bl SetGpioFunction
	@Pin 16 lectura
	mov r0,#16
	mov r1,#0
	bl SetGpioFunction
	pop {pc}

/*Subrutina setBinary:
*Modifica los pines GPIO para analizar piezas de dos entradas (AND, OR, XOR)
*Parámetros: Ninguno
*Salidas: Ninguna*/
setBinary:
	push {lr}
	@Pines de Compuerta 1
	@Pin 4 escritura
	mov r0,#4
	mov r1,#1
	bl SetGpioFunction
	@Pin 17 escritura
	mov r0,#17
	mov r1,#1
	bl SetGpioFunction
	@Pin 27 lectura
	mov r0,#27
	mov r1,#0
	bl SetGpioFunction

	@Pines de Compuerta 2
	@Pin 22 escritura
	mov r0,#22
	mov r1,#1
	bl SetGpioFunction
	@Pin 5 escritura
	mov r0,#5
	mov r1,#1
	bl SetGpioFunction
	@Pin 6 lectura
	mov r0,#6
	mov r1,#0
	bl SetGpioFunction

	@Pines de Compuerta 3
	@Pin 18 escritura
	mov r0,#18
	mov r1,#1
	bl SetGpioFunction
	@Pin 23 escritura
	mov r0,#23
	mov r1,#1
	bl SetGpioFunction
	@Pin 24 lectura
	mov r0,#24
	mov r1,#0
	bl SetGpioFunction

	@Pines de Compuerta 4
	@Pin 25 escritura
	mov r0,#25
	mov r1,#1
	bl SetGpioFunction
	@Pin 12 escritura
	mov r0,#12
	mov r1,#1
	bl SetGpioFunction
	@Pin 16 lectura
	mov r0,#16
	mov r1,#0
	bl SetGpioFunction
	pop {pc}

/*Subrutina setAnd3:
*Modifica los pines GPIO para analizar AND's de tres entradas
*Parámetros: Ninguno
*Salidas: Ninguna*/
setAnd3:
	push {lr}
	@Pines AND 1
	@Pin 4 escritura
	mov r0,#4
	mov r1,#1
	bl SetGpioFunction
	@Pin 17 escritura
	mov r0,#17
	mov r1,#1
	bl SetGpioFunction
	@Pin 18 escritura
	mov r0,#18
	mov r1,#1
	bl SetGpioFunction
	@Pin 23 lectura
	mov r0,#23
	mov r1,#0
	bl SetGpioFunction

	@Pines AND 2
	@Pin 27 escritura
	mov r0,#27
	mov r1,#1
	bl SetGpioFunction
	@Pin 22 escritura
	mov r0,#22
	mov r1,#1
	bl SetGpioFunction
	@Pin 5 escritura
	mov r0,#5
	mov r1,#1
	bl SetGpioFunction
	@Pin 6 lectura
	mov r0,#6
	mov r1,#0
	bl SetGpioFunction

	@Pines AND 3
	@Pin 24 escritura
	mov r0,#24
	mov r1,#1
	bl SetGpioFunction
	@Pin 25 escritura
	mov r0,#25
	mov r1,#1
	bl SetGpioFunction
	@Pin 12 escritura
	mov r0,#12
	mov r1,#1
	bl SetGpioFunction
	@Pin 16 lectura
	mov r0,#16
	mov r1,#0
	bl SetGpioFunction
	pop {pc}

/*Subrutina setOr3:
*Modifica los pines GPIO para analizar OR's de tres entradas
*Parámetros: Ninguno
*Salidas: Ninguna*/
setOr3:
	push {lr}
	@Pines OR 1
	@Pin 4 escritura
	mov r0,#4
	mov r1,#1
	bl SetGpioFunction
	@Pin 17 escritura
	mov r0,#17
	mov r1,#1
	bl SetGpioFunction
	@Pin 16 escritura
	mov r0,#16
	mov r1,#1
	bl SetGpioFunction
	@Pin 12 lectura
	mov r0,#12
	mov r1,#0
	bl SetGpioFunction

	@Pines OR 2
	@Pin 27 escritura
	mov r0,#27
	mov r1,#1
	bl SetGpioFunction
	@Pin 22 escritura
	mov r0,#22
	mov r1,#1
	bl SetGpioFunction
	@Pin 5 escritura
	mov r0,#5
	mov r1,#1
	bl SetGpioFunction
	@Pin 6 lectura
	mov r0,#6
	mov r1,#0
	bl SetGpioFunction

	@Pines OR 3
	@Pin 18 escritura
	mov r0,#18
	mov r1,#1
	bl SetGpioFunction
	@Pin 23 escritura
	mov r0,#23
	mov r1,#1
	bl SetGpioFunction
	@Pin 24 escritura
	mov r0,#24
	mov r1,#1
	bl SetGpioFunction
	@Pin 25 lectura
	mov r0,#16
	mov r1,#0
	bl SetGpioFunction
	pop {pc}

/*Subrutina: cicloNot
*Verifica si un Not del integrado funciona correctamente.
*Parámetros:
*R0 <- pin de salida
*R1 <- pin de entrada
*Salidas:
*R0 <- 1 si se ha producido un error, 0 si es correcto*/
cicloNot:
	mov r4,r0
	mov r5,r1
not0:
	mov r0,r5
	mov r1,#0
	push {r4,r5,lr}
	bl SetGpio
	bl delay
	pop {r4,r5,lr}
	mov r0,r4
	push {r4,r5,lr}
	bl GetGpio
	pop {r4,r5,lr}
	cmp r0,#0
	beq failNot
not1:
	mov r0,r5
	mov r1,#1
	push {r4,r5,lr}
	bl SetGpio
	bl delay
	pop {r4,r5,lr}
	mov r0,r4
	push {r4,r5,lr}
	bl GetGpio
	pop {r4,r5,lr}
	cmp r0,#0
	bne failNot
	mov r0,#0
	mov pc,lr
failNot:
	mov r0,#1
	mov pc,lr

/*Subrutina: cicloAnd2
*Verifica si un AND de dos entradas del integrado funciona correctamente.
*Parámetros:
*R0 <- pin de salida
*R1 <- pin de entrada
*R2 <- pin de entrada
*Salidas:
*R0 <- 1 si se ha producido un error, 0 si es correcto*/
cicloAnd2:
	mov r4,r0
	mov r5,r1
	mov r6,r2
and00:
	mov r0,r5
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	bne failAnd2
and01:
	mov r0,r5
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	bne failAnd2
and10:
	mov r0,r5
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	bne failAnd2
and11:
	mov r0,r5
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	beq failAnd2
	mov r0,#0
	mov pc,lr
failAnd2:
	mov r0,#1
	mov pc,lr

/*Subrutina: cicloOr2
*Verifica si un OR de dos entradas del integrado funciona correctamente.
*Parámetros:
*R0 <- pin de salida
*R1 <- pin de entrada
*R2 <- pin de entrada
*Salidas:
*R0 <- 1 si se ha producido un error, 0 si es correcto*/
cicloOr2:
	mov r4,r0
	mov r5,r1
	mov r6,r2
or00:
	mov r0,r5
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	bne failOr2
or01:
	mov r0,r5
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	beq failOr2
or10:
	mov r0,r5
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	beq failOr2
or11:
	mov r0,r5
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	beq failOr2
	mov r0,#0
	mov pc,lr
failOr2:
	mov r0,#1
	mov pc,lr

/*Subrutina: cicloXor
*Verifica si un XOR de dos entradas del integrado funciona correctamente.
*Parámetros:
*R0 <- pin de salida
*R1 <- pin de entrada
*R2 <- pin de entrada
*Salidas:
*R0 <- 1 si se ha producido un error, 0 si es correcto*/
cicloXor:
	mov r4,r0
	mov r5,r1
	mov r6,r2
xor00:
	mov r0,r5
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	bne failXor
xor01:
	mov r0,r5
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	beq failXor
xor10:
	mov r0,r5
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	beq failXor
xor11:
	mov r0,r5
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	pop {r4-r6,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r6,lr}
	bl SetGpio
	bl delay
	pop {r4-r6,lr}
	mov r0,r4
	push {r4-r6,lr}
	bl GetGpio
	pop {r4-r6,lr}
	cmp r0,#0
	bne failXor
	mov r0,#0
	mov pc,lr
failXor:
	mov r0,#1
	mov pc,lr

/*Subrutina: cicloAnd3
*Verifica si un AND de tres entradas del integrado funciona correctamente.
*Parámetros:
*R0 <- pin de salida
*R1 <- pin de entrada
*R2 <- pin de entrada
*R3 <- pin de entrada
*Salidas:
*R0 <- 1 si se ha producido un error, 0 si es correcto*/
cicloAnd3:
	mov r4,r0
	mov r5,r1
	mov r6,r2
	mov r7,r3
and000:
	mov r0,r5
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	bne failAnd3
and001:
	mov r0,r5
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	bne failAnd3
and010:
	mov r0,r5
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	bne failAnd3
and011:
	mov r0,r5
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	bne failAnd3
and100:
	mov r0,r5
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	bne failAnd3
and101:
	mov r0,r5
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	bne failAnd3
and110:
	mov r0,r5
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	bne failAnd3
and111:
	mov r0,r5
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	beq failAnd3
	mov r0,#0
	mov pc,lr
failAnd3:
	mov r0,#1
	mov pc,lr

/*Subrutina: cicloOr3
*Verifica si un OR de tres entradas del integrado funciona correctamente.
*Parámetros:
*R0 <- pin de salida
*R1 <- pin de entrada
*R2 <- pin de entrada
*R3 <- pin de entrada
*Salidas:
*R0 <- 1 si se ha producido un error, 0 si es correcto*/
cicloOr3:
	mov r4,r0
	mov r5,r1
	mov r6,r2
	mov r7,r3
or000:
	mov r0,r5
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	bne failOr3
or001:
	mov r0,r5
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	beq failOr3
or010:
	mov r0,r5
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	beq failOr3
or011:
	mov r0,r5
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	beq failOr3
or100:
	mov r0,r5
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	beq failOr3
or101:
	mov r0,r5
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	beq failOr3
or110:
	mov r0,r5
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#0
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	beq failOr3
or111:
	mov r0,r5
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r6
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	pop {r4-r7,lr}
	mov r0,r7
	mov r1,#1
	push {r4-r7,lr}
	bl SetGpio
	bl delay
	pop {r4-r7,lr}
	mov r0,r4
	push {r4-r7,lr}
	bl GetGpio
	pop {r4-r7,lr}
	cmp r0,#0
	beq failOr3
	mov r0,#0
	mov pc,lr
failOr3:
	mov r0,#1
	mov pc,lr

/*Subrutina delay:
*Subrutina que se tarda en ejecutar para simular un delay.
*Parámetros: No.
*Salidas: No.*/
delay:
	push {r0,lr}
	ldr r0,=delayVal
	ldr r0,[r0]
delay1:
	subs r0,#1
	bne delay1
	pop {r0,pc}

