# Codigo Base para Laboratorio MIPS

	# Constants
	.eqv FB_LENGTH 524288 # 256*512*4

	# Data Segment
	.data
FB:	.space FB_LENGTH	# Reserve FB_LENGTH Sapce in Data Segment in FB label
file:	.asciiz "arsat.rgba" 	# File name
	.word	0
	# Text Segment
	.text
	.globl main
main:
	# Open File
	li $v0, 13 		# $v0 specifies the syscall type, where 13=open file
	la $a0, file 		# $a2 = address of the name of file to read
	add $a1, $0, $0 	# $a1=flags, 0 is O_RDONLY
	add $a2, $0, $0		# $a2=mode, 0 is ignore
	syscall			# Open File, $v0 stores file descriptor (fd)
	move $s0, $v0		# store fd in $s0
	
	

	# Read FB_LENGTH bytes from file, storing in framebuffer
	li $v0, 14	 	# $v0 specifies the syscall type, where 14=read from  file
	move $a0, $s0 		# $a0=file_descriptor 
	la $a1, FB		# $a1=address of input buffer (frame buffer)
	li $a2, FB_LENGTH 	# $a2=maximum numbers of characters to read
	syscall			# Read From File, $v0 contains number of characters read or 0 if EOF
	
	# Workaround Bitmap Display Bug
	move $t3, $a1 		# $t3 apunta a base
	li $s1, 0               # i = 0 fila
	li $s7, 0 		# j = 0 columna
	li $t8, 256
#se hace un reflejo horizontal, se recorre cada fila intercambiando el ij pixel con el i(511-j) pixel. Recordemos que va del (0,0)pixel al (255,511)pixel
		
loop2: 	bge $s1, $t8, done	#para la guarda del while ( i < 256) por que la ultima fila es 255.
	addiu $t4, $t3, 2044	#$t4 apunta al pixel de la  i fila en la ultima columna (2044 = 4*511)
loop3:  bge $s7, $t8, label	#para la guarda del while (j < 256) por que se deben hacer los intercambios hasta la mitad de la fila (columna 255)
	lw $s3, 0($t3)		
	lw $s4, 0($t4)
	sw $s3, 0($t4)
	sw $s4, 0($t3)		#con estas ultimas cuatro lineas hago el intercambio entre el ij-pixel y el i(511-j)pixel
	addiu $t3, $t3, 4	#apunto al pixel contiguo de la derecha al que apuntaba $t3
	addiu $t4, $t4, -4	#apunto al pixel contiguo de la izquierda al que apuntaba $t4
	addiu $s7, $s7, 1	#aumento el contador de las columnas ( j = j + 1)
	j loop3 
label:  addiu $t3, $t3, 1024	#apunto $t3 al primer pixel de la fila (i+1) ("to terminó en el pixel 256, y quiero ir al pixel 0 de la sig fila osea al pixel 512, luego 4*(512-256)
	addiu $s1, $s1, 1	#sumo el contador (paso a la siguiente fila) ( i = i + 1) 
    addiu $s7, $zero, 0		#pongo en cero el contador (para empezar en la columna cero) ( j = 0)
	j loop2
	
done:

	# Close File
	li $v0, 16 		# $v0 specifies the syscall type, where 16=close file
	move $a0, $s0 		# $a0=file_descriptor 
	syscall 		# Close File

	# Exit Gracefully
	li $v0, 10		# $v0 specifies the syscall type, where 10=exit
	syscall			# Exit
