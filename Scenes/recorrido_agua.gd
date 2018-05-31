extends Sprite

var direccion = 0 #Arriba,ab,iz,der
var main
var nodo_anterior #Tuberia recorrida anterior
var nodo_actual #Tuberia recorrida actual

func _ready():
	 main = get_tree().get_nodes_in_group("main")[0] #Busco el nodo main para reutilizar mil veces o mas

func _on_Timer_timeout(): #Test para ver recorrido pathfinding
	
	if(nodo_actual != null):
		nodo_actual.puede_girar = false #Ya paso el agua y no lo puedo volver a girar
		#Si la direccion es hacia arriba, y el casillero actual esta conectado el tubo hacia arriba, y el de arriba tiene conexion con el de abajo
		if(direccion == 0 && nodo_actual.conectado[0] && nodo_actual.a != null && nodo_actual.a.conectado[1] && nodo_actual.puede_pasar[0] && nodo_actual.a.puede_pasar[1]):
			nodo_anterior = nodo_actual #Guardo el nodo actual en esta variable para ver si luego no trato de volver hacia atras
			nodo_actual = nodo_actual.a #Voy hacia arriba
			nodo_anterior.puede_pasar[0] = false #Desconectamos asi no vuelve a pasar el agua nunca mas hacia esa direccion por ahi
			nodo_actual.puede_pasar[1] = false
		elif(direccion == 1 && nodo_actual.conectado[1] && nodo_actual.b != null && nodo_actual.b.conectado[0] && nodo_actual.puede_pasar[1] && nodo_actual.b.puede_pasar[0]):
			nodo_anterior = nodo_actual
			nodo_actual = nodo_actual.b #Voy hacia abajo
			nodo_anterior.puede_pasar[1] = false #Desconectamos asi no vuelve a pasar el agua nunca mas hacia esa direccion por ahi
			nodo_actual.puede_pasar[0] = false
		elif(direccion == 2 && nodo_actual.conectado[2] && nodo_actual.c != null && nodo_actual.c.conectado[3] && nodo_actual.puede_pasar[2] && nodo_actual.c.puede_pasar[3]):
			nodo_anterior = nodo_actual
			nodo_actual = nodo_actual.c #Izq
			nodo_anterior.puede_pasar[2] = false #Desconectamos asi no vuelve a pasar el agua nunca mas hacia esa direccion por ahi
			nodo_actual.puede_pasar[3] = false
		elif(direccion == 3 && nodo_actual.conectado[3] && nodo_actual.d != null && nodo_actual.d.conectado[2] && nodo_actual.puede_pasar[3] && nodo_actual.d.puede_pasar[2]):
			nodo_anterior = nodo_actual
			nodo_actual = nodo_actual.d #Der
			nodo_anterior.puede_pasar[3] = false #Desconectamos asi no vuelve a pasar el agua nunca mas hacia esa direccion por ahi
			nodo_actual.puede_pasar[2] = false
		else: #No funciono hacia la direccion que estaba dirigiendose, comprobamos puede girar o algo
			if(direccion != 0 && nodo_actual.conectado[0] && nodo_actual.a != null && nodo_actual.a.conectado[1] && nodo_actual.a != nodo_anterior && nodo_actual.puede_pasar[0] && nodo_actual.a.puede_pasar[1]):
				direccion = 0
			elif(direccion != 1 && nodo_actual.conectado[1] && nodo_actual.b != null && nodo_actual.b.conectado[0] && nodo_actual.b != nodo_anterior && nodo_actual.puede_pasar[1] && nodo_actual.b.puede_pasar[0]):
				direccion = 1
			elif(direccion != 2 && nodo_actual.conectado[2] && nodo_actual.c != null && nodo_actual.c.conectado[3] && nodo_actual.c != nodo_anterior && nodo_actual.puede_pasar[2] && nodo_actual.c.puede_pasar[3]):
				direccion = 2
			elif(direccion != 3 && nodo_actual.conectado[3] && nodo_actual.d != null && nodo_actual.d.conectado[2] && nodo_actual.d != nodo_anterior && nodo_actual.puede_pasar[3] && nodo_actual.d.puede_pasar[2]):
				direccion = 3

	
		global_position = nodo_actual.global_position #Mueve el cosito
		if(nodo_actual.is_in_group("T")): #Si llegue al nodo T
			get_tree().get_nodes_in_group("winlose")[0].text = "GANASTE" #Muestro msj ganaste
			yield(get_tree().create_timer(1.0),"timeout") #Espero 3 segundos
			get_tree().get_nodes_in_group("main")[0].generar_juego() #Creo una partida nueva
			get_tree().get_nodes_in_group("winlose")[0].text = "" #Quito el msj ganaste


	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
