extends Position2D

#Nodos o conexiones que tiene con los otros casilleros
var a #Arriba
var b #Abajo
var c #Izquierda
var d #Derecha
var conectado = [false,false,false,false] #0 ARRIBA, 1 ABAJO, 2 IZQUIERDA, 3 DERECHA


func _ready():
	pass
	
func generar_imagenes(): #Detectamos conexiones y le asignamos un grafico a la tuberia
#Primero detecto las tuberias de 3 conexion
	if(conectado[0] && conectado[1] && conectado[2] && conectado[3]): #Conexion de 4
		get_node("spr_cas").frame = 0 #Si conecta hacia 4 creo dibujo tuberia 4 conexionees
	elif(conectado[0] && conectado[1] && conectado[2]): #Arriba, abajo e izquierda Conexion 3
		get_node("spr_cas").frame = 4 
		get_node("spr_cas").rotation_degrees = 270
	elif(conectado[0] && conectado[1] && conectado[3]): #Ar, ab y der
		get_node("spr_cas").frame = 4 
		get_node("spr_cas").rotation_degrees = 90
	elif(conectado[0] && conectado[2] && conectado[3]): #Ar, izq y der
		get_node("spr_cas").frame = 4 
	elif(conectado[1] && conectado[2] && conectado[3]): #Ab, izq y der
		get_node("spr_cas").frame = 4 
		get_node("spr_cas").rotation_degrees = 180
	elif(conectado[0] && conectado[1]): #Si esta conectado hacia arriba #Conexion de 2
		get_node("spr_cas").frame = 1 #Tuberia hacia arriba
		get_node("spr_cas").rotation_degrees = 90
	elif(conectado[2] && conectado[3]): #Si esta conectado hacia izquierda y derecha
		get_node("spr_cas").frame = 1 #Dibujo tubo horizontal
	else: #Sino codito
		if(conectado[0] && conectado[2]): #Conexion arriba e izquierda
			get_node("spr_cas").frame = 2 #Dibujo codito
			get_node("spr_cas").rotation_degrees = 90
		elif(conectado[0] && conectado [3]): #Conexion arriba y derecha
			get_node("spr_cas").frame = 2 #Dibujo codito
			get_node("spr_cas").rotation_degrees = 180
		elif(conectado[1] && conectado[2]): #Conexion abajo e izquierda
			get_node("spr_cas").frame = 2 #Dibujo codito
		elif(conectado[1] && conectado[3]): #Conexion abajo  y derecha
			get_node("spr_cas").frame = 2
			get_node("spr_cas").rotation_degrees = 270
		elif(conectado[0] || conectado[1]): #1 sola conexion
			get_node("spr_cas").frame = 1 #Tuberia hacia arriba
			get_node("spr_cas").rotation_degrees = 90
		elif(conectado[2] || conectado[3]):
			get_node("spr_cas").frame = 1 



func _on_Area2D_mouse_entered():
	pass
		
func _on_Boton_button_down(): #Funcion de presionar mouse (FuryCode gracias)
	rotation_degrees += 90 #Rota el grafico del casillero


func rotar_tubos(): #Al rotar 90° las conexiones rotan
	conectado[0] = conectado[2] #Arriba es izquierda ahora
	conectado[3] = conectado[0] #Derecha es arriba
	conectado[1] = conectado[3] #Abajo es derecha
	conectado[2] = conectado[1] #Izquierda esabajo
	