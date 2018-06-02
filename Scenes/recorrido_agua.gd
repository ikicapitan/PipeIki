extends Sprite

var direccion = 0 #Arriba,ab,iz,der
var main
var nodo_anterior #Tuberia recorrida anterior
var nodo_actual #Tuberia recorrida actual
var nombre_animacion = "" #Nombre de la animacion del agua a reproducirse
var pudo_avanzar = true
var animacion_asignada = false

func _ready():
	main = get_tree().get_nodes_in_group("main")[0] #Busco el nodo main para reutilizar mil veces o mas
	agua_start()

func _on_Timer_timeout(): #Test para ver recorrido pathfinding
	
	if(nodo_actual != null):
		nodo_actual.puede_girar = false #Ya paso el agua y no lo puedo volver a girar
		animacion_asignada = false
		#Si la direccion es hacia arriba, y el casillero actual esta conectado el tubo hacia arriba, y el de arriba tiene conexion con el de abajo
		if(!avanzar()): #No funciono hacia la direccion que estaba dirigiendose, comprobamos puede girar o algo
			check_direction()
			
		global_position = nodo_actual.global_position #Mueve el cosito
		if(!main.gameover && nodo_actual.is_in_group("T")): #Si llegue al nodo T
			gano()
			
			
func perdio():
	get_node("Timer").stop() #Freno el agua
	get_tree().get_nodes_in_group("winlose")[0].text = "PERDISTE" #Muestro msj ganaste
	main.gameover = true #Fin del juego verdadero para que no se repita ni chequee condicion perder o ganar
	yield(get_tree().create_timer(3.0),"timeout") #Espero 3 segundos
	get_tree().get_nodes_in_group("main")[0].generar_juego() #Creo una partida nueva
	get_tree().get_nodes_in_group("winlose")[0].text = "" #Quito el msj ganaste
	main.gameover = false #reseteo
	agua_start()
	
func gano():
	get_node("Timer").stop() #Freno el agua
	get_tree().get_nodes_in_group("winlose")[0].text = "GANASTE" #Muestro msj ganaste
	main.gameover = true #Fin del juego verdadero para que no se repita ni chequee condicion perder o ganar
	yield(get_tree().create_timer(3.0),"timeout") #Espero 3 segundos
	get_tree().get_nodes_in_group("main")[0].generar_juego() #Creo una partida nueva
	get_tree().get_nodes_in_group("winlose")[0].text = "" #Quito el msj ganaste
	main.gameover = false #reseteo
	agua_start()
	
func agua_start():
	yield(get_tree().create_timer(5.0),"timeout")
	get_node("Timer").start()

func crear_animacion(): #Funcion para reproducir el agua segun animacion elegida
	if(nombre_animacion != null):
		var newAgua = main.agua.instance() #Creamos el agua
		newAgua.global_position = nodo_anterior.global_position #Ponemos el agua en posicion de nodo actual
		get_tree().get_nodes_in_group("tablero")[0].add_child(newAgua) #Metemos en la escena
		newAgua.get_node("animacion").play(nombre_animacion) #Reproducir animacion tal a tal lado el agua
	else:
		print("Nombre vaciado")

func avanzar(): #avanza el agua hacia la direccion en la que se dirige
	pudo_avanzar = true
	if(direccion == 0 && nodo_actual.conectado[0] && nodo_actual.a != null && nodo_actual.a.conectado[1] && nodo_actual.puede_pasar[0] && nodo_actual.a.puede_pasar[1]):
		if(!animacion_asignada):
			nombre_animacion = "c_aarr"
		nodo_anterior = nodo_actual #Guardo el nodo actual en esta variable para ver si luego no trato de volver hacia atras
		nodo_actual = nodo_actual.a #Voy hacia arriba
		nodo_anterior.puede_pasar[0] = false #Desconectamos asi no vuelve a pasar el agua nunca mas hacia esa direccion por ahi
		nodo_actual.puede_pasar[1] = false
	elif(direccion == 1 && nodo_actual.conectado[1] && nodo_actual.b != null && nodo_actual.b.conectado[0] && nodo_actual.puede_pasar[1] && nodo_actual.b.puede_pasar[0]):
		if(!animacion_asignada):
			nombre_animacion = "c_ab"
		nodo_anterior = nodo_actual
		nodo_actual = nodo_actual.b #Voy hacia abajo
		nodo_anterior.puede_pasar[1] = false #Desconectamos asi no vuelve a pasar el agua nunca mas hacia esa direccion por ahi
		nodo_actual.puede_pasar[0] = false
	elif(direccion == 2 && nodo_actual.conectado[2] && nodo_actual.c != null && nodo_actual.c.conectado[3] && nodo_actual.puede_pasar[2] && nodo_actual.c.puede_pasar[3]):
		if(!animacion_asignada):
			nombre_animacion = "c_di"
		nodo_anterior = nodo_actual
		nodo_actual = nodo_actual.c #Izq
		nodo_anterior.puede_pasar[2] = false #Desconectamos asi no vuelve a pasar el agua nunca mas hacia esa direccion por ahi
		nodo_actual.puede_pasar[3] = false
	elif(direccion == 3 && nodo_actual.conectado[3] && nodo_actual.d != null && nodo_actual.d.conectado[2] && nodo_actual.puede_pasar[3] && nodo_actual.d.puede_pasar[2]):
		if(!animacion_asignada):
			nombre_animacion = "c_id"
		nodo_anterior = nodo_actual
		nodo_actual = nodo_actual.d #Der
		nodo_anterior.puede_pasar[3] = false #Desconectamos asi no vuelve a pasar el agua nunca mas hacia esa direccion por ahi
		nodo_actual.puede_pasar[2] = false
	else:
		pudo_avanzar = false
		
	
	if(pudo_avanzar):
		crear_animacion()
		#nombre_animacion = null #Vuelvo el nombre a ninguno para el proximo testeo
	return pudo_avanzar

func check_direction(): #Chequea si puede doblar el agua
	if(direccion != 0 && nodo_actual.conectado[0] && nodo_actual.a != null && nodo_actual.a.conectado[1] && nodo_actual.a != nodo_anterior && nodo_actual.puede_pasar[0] && nodo_actual.a.puede_pasar[1]):
		detectar_animacion_direccion(0)
		direccion = 0
		animacion_asignada = true
		avanzar()
	elif(direccion != 1 && nodo_actual.conectado[1] && nodo_actual.b != null && nodo_actual.b.conectado[0] && nodo_actual.b != nodo_anterior && nodo_actual.puede_pasar[1] && nodo_actual.b.puede_pasar[0]):
		detectar_animacion_direccion(1)
		direccion = 1
		animacion_asignada = true
		avanzar()
	elif(direccion != 2 && nodo_actual.conectado[2] && nodo_actual.c != null && nodo_actual.c.conectado[3] && nodo_actual.c != nodo_anterior && nodo_actual.puede_pasar[2] && nodo_actual.c.puede_pasar[3]):
		detectar_animacion_direccion(2)
		direccion = 2
		animacion_asignada = true
		avanzar()
	elif(direccion != 3 && nodo_actual.conectado[3] && nodo_actual.d != null && nodo_actual.d.conectado[2] && nodo_actual.d != nodo_anterior && nodo_actual.puede_pasar[3] && nodo_actual.d.puede_pasar[2]):
		detectar_animacion_direccion(3)
		direccion = 3
		animacion_asignada = true
		avanzar()
	elif(!main.gameover):
		perdio()
		
func detectar_animacion_direccion(var dir_sig):
	match direccion: #Switch, vemos el valor de direccion actual y actuamos segun eso
		0: #Si vale 0
			match dir_sig: #Vemos elvalor de la direccion hacia donde quiere ir
				2: nombre_animacion = "d_ai"
				3: nombre_animacion = "d_ad"
		1: 
			match dir_sig:
				2: nombre_animacion = "d_arri" #Arr a izq
				3: nombre_animacion = "d_arrd" #Arr a der
		2: 
			match dir_sig:
				0: nombre_animacion = "d_darr"
				1: nombre_animacion = "d_da"
		3:
			match dir_sig:
				0: nombre_animacion = "d_iarr"
				1: nombre_animacion = "d_ia"

			
		