/*------------------------------------------------------------------------
*Universidad del Valle de Guatemala
*Taller de Assembler
*Sección 21
*Josué Cifuentes #15275
*Josué Jacobs #15041
*Pablo Muñoz #15258
*Marcel Velásquez #15534
*21/11/16
*Integrated Circuit Scanner
*main.s
*size: 600x800, 16 bits per pixel
------------------------------------------------------------------------*/

/*------------------------------------------------------------------------
*Distribución de pines de GPIO:
*Pines del lado izquierdo del socket:
*GPIO 4, 17, 27, 22, 5 y 6
*Pines del lado derecho del socket:
*GPIO 18, 23, 24, 25, 12, 16
------------------------------------------------------------------------*/

/*Área de código*/

.text
.global main

main:
	@Obtiene dirección del GPIO de la Raspberry
	bl GetGpioAddress
	ldr r1,=myloc
	str r0,[r1]

	@Obtiene dirección de monitor
	bl getScreenAddr
	ldr r1,=pixelAddr
	str r0,[r1]

	@Habilita el uso de teclado sin interruptos
	bl enable_key_config
	bl handle_ctrl_c

loopMenu:
	@Corre un loop infinito para pintar menú y puntero hasta que se seleccione la opción deseada
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	mov r1,#10 @Posición inicial en x
	mov r2,#10 @Posición inicial en y
	ldr r3,=Menu @Vector con colores de imagen
	ldr r4,=width
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=height
	ldr r5,[r5] @Altura de imagen
	bl paint @Subrutina que pinta imagen

	@Pintar puntero
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	ldr r1,=pointXM @Posición inicial en x
	ldr r1,[r1]
	ldr r2,=pointYM @Posición inicial en y
	ldr r2,[r2]
	ldr r3,=Pointer @Vector con colores de imagen
	ldr r4,=pWidth
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=pHeight
	ldr r5,[r5] @Altura de imagen
	mov r6,#255 @Color que no se pintará.
	bl figure @Subrutina que pinta imagen sin su fondo

	@Verificar teclas
	bl getKey
	bl delay
	ldr r1,=pointYM
	ldr r2,[r1]
	ldr r3,=op1Menu
	ldr r3,[r3]
	ldr r4,=op2Menu
	ldr r4,[r4]
	@Verifica flecha hacia arriba (w)
	cmp r0,#119
	moveq r5,#1
	movne r5,#0
	@Verifica flecha hacia abajo (s)
	cmp r0,#115
	moveq r6,#1
	movne r6,#0
	orr r5,r6 @El OR verifica si se presionó alguna de las dos.
	cmp r5,#1 @Si se presionó cualquiera de los dos, debe ser uno.
	bne revisaEnt @Si no se presionó, se revisa si se ha presionado enter.
	cmp r2,r3 @Si se presionó, se cambia la posición Y del puntero para señalar otra opción.
	streq r4,[r1]
	strne r3,[r1]
revisaEnt:	
	cmp r0,#10 @Se verifica si se ha presionado enter.
	bne loopMenu @Si no se presionó, se sigue en el loop del menú.

enterMenu: @Compara la posición del puntero para analizar cuál opción se escogió.
	ldr r0,=pointYM
	ldr r0,[r0]
	ldr r1,=op1Menu
	ldr r1,[r1]
	cmp r0,r1
	bne fin @Si es igual a la posición de la opción 1, se continua hacia el catálogo. Si no, se finaliza el programa.

loopCatalogo:
	@Corre un loop infinito para pintar menú y puntero hasta que se seleccione la opción deseada
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	mov r1,#10 @Posición inicial en x
	mov r2,#10 @Posición inicial en y
	ldr r3,=Catalogo @Vector con colores de imagen
	ldr r4,=width
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=height
	ldr r5,[r5] @Altura de imagen
	bl paint @Subrutina que pinta imagen

	@Pintar puntero
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	ldr r1,=pointXC @Posición inicial en x
	ldr r1,[r1]
	ldr r2,=pointYC @Posición inicial en y
	ldr r2,[r2]
	ldr r3,=Pointer @Vector con colores de imagen
	ldr r4,=pWidth
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=pHeight
	ldr r5,[r5] @Altura de imagen
	mov r6,#255 @Color que no se pintará.
	bl figure @Subrutina que pinta imagen sin su fondo

	@Verifican teclas
	bl getKey
	bl delay
	@Compara flecha hacia arriba (w)
	cmp r0,#119
	beq up
	@Compara flecha hacia abajo (s)
	cmp r0,#115
	beq down
	@Compara flecha hacia la izquierda (a)
	cmp r0,#97
	beq light
	@Compara flecha hacia la derecha (d)
	cmp r0,#100
	beq light
	@Compara si se presionó enter.
	cmp r0,#10
	bne loopCatalogo
	b enterCatalogo

up: @Compara la posición Y actual del puntero para ver si puede moverse hacia arriba.
	ldr r0,=pointYC
	ldr r1,[r0]
	ldr r2,=pointY12
	ldr r2,[r2]
	ldr r3,=pointY34
	ldr r3,[r3]
	ldr r4,=pointY56
	ldr r4,[r4]
	ldr r5,=pointY7
	ldr r5,[r5]
	ldr r6,=pointX7
	ldr r6,[r6]
	ldr r7,=pointXi
	ldr r7,[r7]
	ldr r8,=pointXC
	cmp r1,r2
	streq r5,[r0]
	streq r6,[r8]
	cmp r1,r3
	streq r2,[r0]
	cmp r1,r4
	streq r3,[r0]
	cmp r1,r5
	streq r4,[r0]
	streq r7,[r8]
	b loopCatalogo

down: @Compara la posición Y actual del puntero para ver si puede moverse hacia abajo.
	ldr r0,=pointYC
	ldr r1,[r0]
	ldr r2,=pointY12
	ldr r2,[r2]
	ldr r3,=pointY34
	ldr r3,[r3]
	ldr r4,=pointY56
	ldr r4,[r4]
	ldr r5,=pointY7
	ldr r5,[r5]
	ldr r6,=pointX7
	ldr r6,[r6]
	ldr r7,=pointXi
	ldr r7,[r7]
	ldr r8,=pointXC
	cmp r1,r2
	streq r3,[r0]
	cmp r1,r3
	streq r4,[r0]
	cmp r1,r4
	streq r5,[r0]
	streq r6,[r8]
	cmp r1,r5
	streq r2,[r0]
	streq r7,[r8]
	b loopCatalogo

light: @Compara la posición X actual del puntero para poderla mover hacia los lados. (En la opción 7 no permite que se mueva hacia los lados).
	ldr r0,=pointXC
	ldr r1,[r0]
	ldr r2,=pointXi
	ldr r2,[r2]
	ldr r3,=pointXp
	ldr r3,[r3]
	ldr r4,=pointY7
	ldr r4,[r4]
	ldr r5,=pointYC
	ldr r5,[r5]
	cmp r4,r5
	beq loopCatalogo
	cmp r1,r2
	streq r3,[r0]
	strne r2,[r0]
	b loopCatalogo

enterCatalogo:
	@Primero se pintan las instrucciones
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	mov r1,#10 @Posición inicial en x
	mov r2,#10 @Posición inicial en y
	ldr r3,=Instr @Vector con colores de imagen
	ldr r4,=width
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=height
	ldr r5,[r5] @Altura de imagen
	bl paint @Subrutina que pinta imagen

	@Se verifica si se ha seleccionado enter para continuar.
	bl getKey
	bl delay
	cmp r0,#10
	bne enterCatalogo @Si no se presionó enter, se siguen mostrando las instrucciones.
	@Al presionar enter, se analiza la pieza seleccionada previamente.

	@Se verifica si es opcion1
	ldr r0,=pointXC
	ldr r0,[r0]
	ldr r1,=pointYC
	ldr r1,[r1]
	ldr r2,=pointXi
	ldr r2,[r2]
	ldr r3,=pointY12
	ldr r3,[r3]
	cmp r0,r2
	moveq r4,#1
	movne r4,#0
	cmp r1,r3
	moveq r5,#1
	movne r5,#0
	and r4,r5 @AND comprueba si la posición actual del puntero coincide tanto en x como en y del and2.
	cmp r4,#1
	beq pruebaAnd2

	@Se verifica si es opcion2
	ldr r0,=pointXC
	ldr r0,[r0]
	ldr r1,=pointYC
	ldr r1,[r1]
	ldr r2,=pointXp
	ldr r2,[r2]
	ldr r3,=pointY12
	ldr r3,[r3]
	cmp r0,r2
	moveq r4,#1
	movne r4,#0
	cmp r1,r3
	moveq r5,#1
	movne r5,#0
	and r4,r5
	cmp r4,#1
	beq pruebaOr2

	@Se verifica si es opcion3
	ldr r0,=pointXC
	ldr r0,[r0]
	ldr r1,=pointYC
	ldr r1,[r1]
	ldr r2,=pointXi
	ldr r2,[r2]
	ldr r3,=pointY34
	ldr r3,[r3]
	cmp r0,r2
	moveq r4,#1
	movne r4,#0
	cmp r1,r3
	moveq r5,#1
	movne r5,#0
	and r4,r5
	cmp r4,#1
	beq pruebaAnd3

	@Se verifica si es opcion4
	ldr r0,=pointXC
	ldr r0,[r0]
	ldr r1,=pointYC
	ldr r1,[r1]
	ldr r2,=pointXp
	ldr r2,[r2]
	ldr r3,=pointY34
	ldr r3,[r3]
	cmp r0,r2
	moveq r4,#1
	movne r4,#0
	cmp r1,r3
	moveq r5,#1
	movne r5,#0
	and r4,r5
	cmp r4,#1
	beq pruebaOr3

	@Se verifica si es opcion5
	ldr r0,=pointXC
	ldr r0,[r0]
	ldr r1,=pointYC
	ldr r1,[r1]
	ldr r2,=pointXi
	ldr r2,[r2]
	ldr r3,=pointY56
	ldr r3,[r3]
	cmp r0,r2
	moveq r4,#1
	movne r4,#0
	cmp r1,r3
	moveq r5,#1
	movne r5,#0
	and r4,r5
	cmp r4,#1
	beq pruebaNot

	@Se verifica si es opcion6
	ldr r0,=pointXC
	ldr r0,[r0]
	ldr r1,=pointYC
	ldr r1,[r1]
	ldr r2,=pointXp
	ldr r2,[r2]
	ldr r3,=pointY56
	ldr r3,[r3]
	cmp r0,r2
	moveq r4,#1
	movne r4,#0
	cmp r1,r3
	moveq r5,#1
	movne r5,#0
	and r4,r5
	cmp r4,#1
	beq pruebaXor

	@Se verifica si es opcion7
	ldr r0,=pointXC
	ldr r0,[r0]
	ldr r1,=pointYC
	ldr r1,[r1]
	ldr r2,=pointX7
	ldr r2,[r2]
	ldr r3,=pointY7
	ldr r3,[r3]
	cmp r0,r2
	moveq r4,#1
	movne r4,#0
	cmp r1,r3
	moveq r5,#1
	movne r5,#0
	and r4,r5
	cmp r4,#1
	beq loopMenu @Regresa al menú principal si es la opción 7.

pruebaAnd2:
	bl setBinary
	@Probar AND1
	mov r0,#27
	mov r1,#4
	mov r2,#17
	bl cicloAnd2
	cmp r0,#1
	beq falloAnd2

	@Probar AND2
	mov r0,#6
	mov r1,#22
	mov r2,#5
	bl cicloAnd2
	cmp r0,#1
	beq falloAnd2

	@Probar AND3
	mov r0,#24
	mov r1,#18
	mov r2,#23
	bl cicloAnd2
	cmp r0,#1
	beq falloAnd2

	@Probar AND4
	mov r0,#16
	mov r1,#25
	mov r2,#12
	bl cicloAnd2
	cmp r0,#1
	beq falloAnd2

	@Si llega aquí, funciona. Carga mensaje de funcionalidad
	ldr r3,=And2
	ldr r4,=And2p
	str r3,[r4]
	b mAnd2

falloAnd2:
	ldr r3,=And2D
	ldr r4,=And2p
	str r3,[r4]

mAnd2:
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	mov r1,#10 @Posición inicial en x
	mov r2,#10 @Posición inicial en y
	ldr r3,=And2p
	ldr r3,[r3]
	ldr r4,=width
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=height
	ldr r5,[r5] @Altura de imagen
	bl paint @Subrutina que pinta imagen

	bl getKey
	bl delay
	cmp r0,#10
	beq loopMenu
	b mAnd2

pruebaOr2:
	bl setBinary
	@Probar OR1
	mov r0,#27
	mov r1,#4
	mov r2,#17
	bl cicloOr2
	cmp r0,#1
	beq falloOr2

	@Probar OR2
	mov r0,#6
	mov r1,#22
	mov r2,#5
	bl cicloOr2
	cmp r0,#1
	beq falloOr2

	@Probar OR3
	mov r0,#24
	mov r1,#18
	mov r2,#23
	bl cicloOr2
	cmp r0,#1
	beq falloOr2

	@Probar OR4
	mov r0,#16
	mov r1,#25
	mov r2,#12
	bl cicloOr2
	cmp r0,#1
	beq falloOr2

	@Si llega aquí, funciona. Carga mensaje de funcionalidad
	ldr r3,=Or2
	ldr r4,=Or2p
	str r3,[r4]
	b mOr2

falloOr2:
	ldr r3,=Or2D
	ldr r4,=Or2p
	str r3,[r4]

mOr2:
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	mov r1,#10 @Posición inicial en x
	mov r2,#10 @Posición inicial en y
	ldr r3,=Or2p
	ldr r3,[r3]
	ldr r4,=width
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=height
	ldr r5,[r5] @Altura de imagen
	bl paint @Subrutina que pinta imagen

	bl getKey
	bl delay
	cmp r0,#10
	beq loopMenu
	b mOr2

pruebaAnd3:
	bl setAnd3
	@Probar AND1
	mov r0,#23
	mov r1,#4
	mov r2,#17
	mov r3,#18
	bl cicloAnd3
	cmp r0,#1
	beq falloAnd3

	@Probar AND2
	mov r0,#6
	mov r1,#27
	mov r2,#22
	mov r3,#5
	bl cicloAnd3
	cmp r0,#1
	beq falloAnd3

	@Probar AND3
	mov r0,#16
	mov r1,#24
	mov r2,#25
	mov r3,#12
	bl cicloAnd3
	cmp r0,#1
	beq falloAnd3


	@Si llega aquí, funciona. Carga mensaje de funcionalidad
	ldr r3,=And3
	ldr r4,=And3p
	str r3,[r4]
	b mAnd3

falloAnd3:
	ldr r3,=And3D
	ldr r4,=And3p
	str r3,[r4]

mAnd3:
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	mov r1,#10 @Posición inicial en x
	mov r2,#10 @Posición inicial en y
	ldr r3,=And3p
	ldr r3,[r3]
	ldr r4,=width
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=height
	ldr r5,[r5] @Altura de imagen
	bl paint @Subrutina que pinta imagen

	bl getKey
	bl delay
	cmp r0,#10
	beq loopMenu
	b mAnd3

pruebaOr3:
	bl setOr3
	@Probar OR1
	mov r0,#12
	mov r1,#4
	mov r2,#17
	mov r3,#16
	bl cicloOr3
	cmp r0,#1
	beq falloOr3

	@Probar OR2
	mov r0,#6
	mov r1,#27
	mov r2,#22
	mov r3,#5
	bl cicloOr3
	cmp r0,#1
	beq falloOr3

	@Probar OR3
	mov r0,#25
	mov r1,#18
	mov r2,#23
	mov r3,#24
	bl cicloOr3
	cmp r0,#1
	beq falloOr3


	@Si llega aquí, funciona. Carga mensaje de funcionalidad
	ldr r3,=Or3
	ldr r4,=Or3p
	str r3,[r4]
	b mOr3

falloOr3:
	ldr r3,=Or3D
	ldr r4,=Or3p
	str r3,[r4]

mOr3:
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	mov r1,#10 @Posición inicial en x
	mov r2,#10 @Posición inicial en y
	ldr r3,=Or3p
	ldr r3,[r3]
	ldr r4,=width
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=height
	ldr r5,[r5] @Altura de imagen
	bl paint @Subrutina que pinta imagen

	bl getKey
	bl delay
	cmp r0,#10
	beq loopMenu
	b mOr3

pruebaNot:
	bl setUnary
	@Probar NOT1
	mov r0,#17
	mov r1,#4
	bl cicloNot
	cmp r0,#1
	beq falloNot

	@Probar NOT2
	mov r0,#22
	mov r1,#27
	bl cicloNot
	cmp r0,#1
	beq falloNot

	@Probar NOT3
	mov r0,#6
	mov r1,#5
	bl cicloNot
	cmp r0,#1
	beq falloNot

	@Probar NOT4
	mov r0,#23
	mov r1,#18
	bl cicloNot
	cmp r0,#1
	beq falloNot

	@Probar NOT5
	mov r0,#25
	mov r1,#24
	bl cicloNot
	cmp r0,#1
	beq falloNot

	@Probar NOT6
	mov r0,#16
	mov r1,#12
	bl cicloNot
	cmp r0,#1
	beq falloNot

	@Si llega aquí, funciona. Carga mensaje de funcionalidad
	ldr r3,=Not
	ldr r4,=Notp
	str r3,[r4]
	b mNot

falloNot:
	ldr r3,=NotD
	ldr r4,=Notp
	str r3,[r4]

mNot:
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	mov r1,#10 @Posición inicial en x
	mov r2,#10 @Posición inicial en y
	ldr r3,=Notp
	ldr r3,[r3]
	ldr r4,=width
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=height
	ldr r5,[r5] @Altura de imagen
	bl paint @Subrutina que pinta imagen

	bl getKey
	bl delay
	cmp r0,#10
	beq loopMenu
	b mNot

pruebaXor:
	bl setBinary
	@Probar XOR1
	mov r0,#27
	mov r1,#4
	mov r2,#17
	bl cicloXor
	cmp r0,#1
	beq falloXor

	@Probar XOR2
	mov r0,#6
	mov r1,#22
	mov r2,#5
	bl cicloXor
	cmp r0,#1
	beq falloXor

	@Probar XOR3
	mov r0,#24
	mov r1,#18
	mov r2,#23
	bl cicloXor
	cmp r0,#1
	beq falloXor

	@Probar XOR4
	mov r0,#16
	mov r1,#25
	mov r2,#12
	bl cicloXor
	cmp r0,#1
	beq falloXor

	@Si llega aquí, funciona. Carga mensaje de funcionalidad
	ldr r3,=Xor
	ldr r4,=Xorp
	str r3,[r4]
	b mXor

falloXor:
	ldr r3,=XorD
	ldr r4,=Xorp
	str r3,[r4]

mXor:
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	mov r1,#10 @Posición inicial en x
	mov r2,#10 @Posición inicial en y
	ldr r3,=Xorp
	ldr r3,[r3]
	ldr r4,=width
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=height
	ldr r5,[r5] @Altura de imagen
	bl paint @Subrutina que pinta imagen

	bl getKey
	bl delay
	cmp r0,#10
	beq loopMenu
	b mXor


fin:
	@Pinta bloque de salida
	ldr r0,=pixelAddr
	ldr r0,[r0] @Puntero del buffer frame
	mov r1,#10 @Posición inicial en x
	mov r2,#10 @Posición inicial en y
	mov r3,#255
	ldr r4,=width
	ldr r4,[r4] @Ancho de imagen
	ldr r5,=height
	ldr r5,[r5] @Altura de imagen
	bl block @Subrutina que pinta bloque de color lentamente

	@Salida segura del teclado
	bl disable_key_config

	@Salida al SO
	mov r7,#1
	swi 0

/*Área de datos*/
.data
.global myloc, delayVal
myloc: @GPIO virtual address Raspberry 2|3
	.word 0x3F200000
pixelAddr: @Dirección de monitor
	.word 0
width: @Ancho de imágenes
	.word 800
height: @Alto de imágenes
	.word 600
ent: @Código ascii de tecla 'enter'
	.word 10
w: @Código ascii de tecla 'w'
	.word 119
a: @Código ascii de tecla 'a'
	.word 97
s: @Código ascii de tecla 's'
	.word 115
d: @Código ascii de tecla 'd'
	.word 100
pWidth: @Ancho de puntero
	.word 20
pHeight: @Alto de puntero
	.word 20
delayVal: @Valor de la resta del delay
	.word 10000000
pointXM: @Posición x del puntero en menú principal.
	.word 210
pointYM: @Posición y del puntero en menú principal.
	.word 310
op1Menu: @Posición y del puntero en menú principal para estar en opción 1
	.word 310
op2Menu: @Posición y del puntero en menú principal para estar en opción 2
	.word 370
pointXC: @Posición x del puntero en menú catálogo.
	.word 50
pointYC: @Posición y del puntero en menú catálogo.
	.word 230
pointXi: @Posición x del puntero en menú catálogo para estar en opciones 1, 3 y 5.
	.word 50
pointXp: @Posición x del puntero en menú catálogo para estar en opciones 2, 4, y 6.
	.word 425
pointY12: @Posición y del puntero en menú catálogo para estar en opciones 1 y 2.
	.word 230
pointY34: @Posición y del puntero en menú catálogo para estar en opciones 3 y 4.
	.word 312
pointY56: @Posición y del puntero en menú catálogo para estar en opciones 5 y 6.
	.word 388
pointX7: @Posición x del puntero en menú catálogo para estar en opción 7.
	.word 170
pointY7: @Posición y del puntero en menú catálogo para estar en opción 7.
	.word 455
And2p: @Dirección de vector de colores para logro o fallo de and2.
	.word 0
Or2p: @Dirección de vector de colores para logro o fallo de or2.
	.word 0
And3p: @Dirección de vector de colores para logro o fallo de and3.
	.word 0
Or3p: @Dirección de vector de colores para logro o fallo de or3.
	.word 0
Notp: @Dirección de vector de colores para logro o fallo de not.
	.word 0
Xorp: @Dirección de vector de colores para logro o fallo de xor.
	.word 0

