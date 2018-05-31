extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var recorrido_actual = 0
var direccion = 0 #Arriba,ab,iz,der
var main
var nodo_anterior
var nodo_actual

func _ready():
	 main = get_tree().get_nodes_in_group("main")[0] #Busco el nodo main para reutilizar mil veces o mas

func _on_Timer_timeout(): #Test para ver recorrido pathfinding
	
	print(direccion)
	
	#Si la direccion es hacia arriba, y el casillero actual esta conectado el tubo hacia arriba, y el de arriba tiene conexion con el de abajo
	if(direccion == 0 && main.path[recorrido_actual].conectado[0] && main.path[recorrido_actual].a.conectado[1]):
		recorrido_actual += 1
	elif(direccion == 1 && main.path[recorrido_actual].conectado[1] && main.path[recorrido_actual].b.conectado[0]):
		recorrido_actual += 1
	elif(direccion == 2 && main.path[recorrido_actual].conectado[2] && main.path[recorrido_actual].c.conectado[3]):
		recorrido_actual += 1
	elif(direccion == 3 && main.path[recorrido_actual].conectado[3] && main.path[recorrido_actual].d.conectado[2]):
		recorrido_actual += 1
	else: #No funciono hacia la direccion que estaba dirigiendose, comprobamos puede girar o algo
		if(main.path[recorrido_actual].conectado[0] && main.path[recorrido_actual].a.conectado[1] && main.path[recorrido_actual].a != nodo_anterior):
			direccion = 0
		elif(main.path[recorrido_actual].conectado[1] && main.path[recorrido_actual].b.conectado[0] && main.path[recorrido_actual].b != nodo_anterior):
			direccion = 1
		elif(main.path[recorrido_actual].conectado[2] && main.path[recorrido_actual].c.conectado[3] && main.path[recorrido_actual].c != nodo_anterior):
			direccion = 2
		elif(main.path[recorrido_actual].conectado[3] && main.path[recorrido_actual].d.conectado[2] && main.path[recorrido_actual].d != nodo_anterior):
			direccion = 3
		
	if(main.path[recorrido_actual] != null): #Si es distinto a vacio
		global_position = main.path[recorrido_actual].global_position #Mueve el cosito

	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
