extends Node

# Variables
export (int) var cas_x #cantidad casilleros en X configurable 
export (int) var cas_y #idem pero en Y
export (PackedScene) var casillero #Escena de los casilleros
export (PackedScene) var tablerillo #Tablero donde se meten casilleros
export (PackedScene) var agua_lateral #Agua llenandose de costado
export (int) var modificador_waypoints_defecto = 20 #Casilleros / MWD = cantidad de waypoints


var offset_x #Medida de los casilleros para espaciarlos unos entre otros
var offset_y #idem
var path = [] #Camino de S a T
var waypoints = [] #Puntos intermedios que recorrera el path
var waypoint_actual = 0
var partida_generada = false #No empezo ninguna partida aun
var regenerar_path = false
var gameover = false #Juego terminado


func _ready():
	var casilleroProvis = casillero.instance() #Crea casillero provisorio
	add_child(casilleroProvis) #Lo mete en escena
	offset_x = casilleroProvis.get_node("spr_cas").texture.get_size().x / 5 #Obtiene medida X / 4 frames
	offset_y = casilleroProvis.get_node("spr_cas").texture.get_size().y #Obtiene medida Y
	casilleroProvis.queue_free() #Elimina el provisorio
	generar_juego() #Crea el juego (tambien sirve para restart, etc)
	

func generar_juego():
	randomize() #Genera semilla random al azar
	if(partida_generada):
		restart() #En caso de haber una partida anterior la limpia
	generar_casilleros() #Crea los casilleros
	generar_conexiones()
	generar_s_y_t() #Crea el punto Start donde va a salir el agua y donde tiene que llegar
	generar_waypoints()
	generar_path()
	

	
func restart():
	get_tree().get_nodes_in_group("tablero")[0].free() #Si habia tablero anterior lo elimino
	path.clear()
	waypoints.clear()
	waypoint_actual = 0
	get_tree().get_nodes_in_group("r_agua")[0].nodo_actual = null
	get_tree().get_nodes_in_group("r_agua")[0].nodo_anterior = null
	regenerar_path = false
	

	
func generar_casilleros(): #Crea casilleros y Tablero
	var newTablero = tablerillo.instance() #Creo un nuevo tablero para meter casilleros nuevos
	newTablero.name = "Tablero"
	add_child(newTablero)
	

	for casillero_x in cas_x: #Recorre desde 0 hasta maximo casilleros en X
		for casillero_y in cas_y: #Recorre desde 0 hasta maximo casilleros en Y
			var newCasillero = casillero.instance() #Crea nuevo casillero
			get_tree().get_nodes_in_group("tablero")[0].add_child(newCasillero) #mete en esecena
			newCasillero.global_position = Vector2(offset_x * casillero_x, offset_y * casillero_y) #Posiciona segun la medida y numero de casillero leido
			newCasillero.name = String(casillero_x) + "-" + String(casillero_y) #Le da un nombre segun numero de casillero X e Y (al estilo Batalla Naval)

func generar_s_y_t(): #Crea punto Start y Finish
	var nodo_deseado_s
	var nodo_deseado_t
	
	var newCas = casillero.instance() #Crea un nuevo casillero
	var newCasT = casillero.instance() #Crea casillero para llegada
	get_tree().get_nodes_in_group("tablero")[0].add_child(newCas) #Lo agrega a la escena
	get_tree().get_nodes_in_group("tablero")[0].add_child(newCasT) #Lo agrega a la escena
	
	var resultado_1 = randi()%4 #Obtiene al azar un numero entre 0 y 1
	if(resultado_1 > 2): #Si el numero es 0
		var resultado_2 = randi()%(cas_x-1)+1 #Obtiene al azar numero entre 1 y maximo_casilleros en X-1
		resultado_1 = randi()%1 #Obtiene al azar numero entre 0 y 1
		if(resultado_1 == 1): #Si resultado es 1 #Se conecta hacia arriba
			resultado_1 = cas_y #Casillero Y se posicionara en la punta, sino en 0 (punta inicial)
			newCas.global_position = Vector2((offset_x * resultado_2), (offset_y * resultado_1) + offset_y ) #Seteo posicion en base a resultados obtenidos al azar arriba
			newCas.name = String(resultado_2) + "-" + String((resultado_1) + 1) #Nombramos casillero
			newCasT.global_position = Vector2((offset_x * resultado_2), (offset_y * 0)  ) #Genera posicion Finish en la posicion inversa u opuesta
			newCasT.name = String(resultado_2) + "-" + String((offset_y * 0))
			
			#Conectando con el nodo correspondiente
			nodo_deseado_s = String(resultado_2) + "-" + String((resultado_1)) #Nombramos casillero
			newCas.a = get_tree().get_nodes_in_group("tablero")[0].get_node(nodo_deseado_s)
			nodo_deseado_t = String(resultado_2) + "-" + String(-1)
			newCasT.b = get_tree().get_nodes_in_group("tablero")[0].get_node(nodo_deseado_t)
			
			#Conectamos nodos con S y T
			newCas.a.b = newCas
			newCasT.b.a = newCasT
			
		else: #Se conecta hacia abajo
			newCas.global_position = Vector2((offset_x * resultado_2), (offset_y * resultado_1) - offset_y ) #Seteo posicion en base a resultados obtenidos al azar arriba
			newCas.name = String(resultado_2) + "-" + String((resultado_1) - 1) #Nombramos casillero
			newCasT.global_position = Vector2((offset_x * resultado_2), (offset_y * cas_y)  ) #Seteo posicion en base a resultados obtenidos al azar arriba
			newCasT.name = String(resultado_2) + "-" + String((cas_y)) #Nombramos casillero
			
			#Conectando con el nodo correspondiente
			nodo_deseado_s = String(resultado_2) + "-" + String((resultado_1))
			newCas.b = get_tree().get_nodes_in_group("tablero")[0].get_node(nodo_deseado_s)
			nodo_deseado_t = String(resultado_2) + "-" + String((cas_y)-1)
			newCasT.a = get_tree().get_nodes_in_group("tablero")[0].get_node(nodo_deseado_t)
			
			#Conectamos con nodos S y T
			newCas.b.a = newCas
			newCasT.a.b = newCasT
		
	else: #Hago lo mismo de arriba pero para el eje Y si el primer numero obtenido al azar es 1
		var resultado_2 = randi()%(cas_y-1)+1
		resultado_1 = randi()%1
		if(resultado_1 == 1):
			resultado_1 = cas_x
			newCas.global_position = Vector2((offset_x * resultado_1) + offset_x, offset_y * resultado_2)
			newCas.name = String(resultado_1) + "-" + String((resultado_2)) #Nombramos casillero
			newCasT.global_position = Vector2((offset_x * 0) , offset_y * resultado_2)
			newCasT.name = String(0) + "-" + String((resultado_2)) #Nombramos casillero
			
			#Conectando con el nodo correspondiente
			nodo_deseado_s = String(resultado_1+1) + "-" + String((resultado_2)) #Nombramos casillero
			newCas.c = get_tree().get_nodes_in_group("tablero")[0].get_node(nodo_deseado_s)
			nodo_deseado_t = String(1) + "-" + String((resultado_2))
			newCasT.d = get_tree().get_nodes_in_group("tablero")[0].get_node(nodo_deseado_t)
			
			#Conectamos con nodos S y T
			
			newCas.c.d = newCas
			newCasT.d.c = newCasT
			
		else:
			newCas.global_position = Vector2((offset_x * resultado_1) - offset_x, offset_y * resultado_2)
			newCas.name = String(resultado_1-1) + "-" + String(resultado_2) #Nombramos casillero
			newCasT.global_position = Vector2((offset_x * cas_x) , offset_y * resultado_2)
			newCasT.name = String(cas_x) + "-" + String(resultado_2) #Nombramos casillero
			
			#Conectando con el nodo correspondiente
			nodo_deseado_s = String(resultado_1) + "-" + String(resultado_2) 
			newCas.d = get_tree().get_nodes_in_group("tablero")[0].get_node(nodo_deseado_s)
			nodo_deseado_t = String(cas_x-1) + "-" + String(resultado_2)
			newCasT.c = get_tree().get_nodes_in_group("tablero")[0].get_node(nodo_deseado_t)
			
			#Conectamos con nodos S y T
			
			newCas.d.c = newCas
			newCasT.c.d = newCasT
		
		
	newCas.get_node("spr_cas").self_modulate.b = 10
	newCasT.get_node("spr_cas").self_modulate.a = 3
	
	#Lo identifico con etiqueta
	newCas.add_to_group("S")
	newCasT.add_to_group("T")
	
	#Agrego S al Path
	path.append(newCas)
	
	#Creo las imagenes de los tubos inicial y final
	generar_tuberia_s_y_t(newCas, true)
	generar_tuberia_s_y_t(newCasT, false)
	get_tree().get_nodes_in_group("r_agua")[0].global_position = newCas.global_position #Posicionamos agua en nodo inicial
	

	
	
	
func generar_tuberia_s_y_t(var newCas, var inicial): #Generamos la primer y ultima tuberia con su respectiva conexion
	if(newCas.a != null): #Si tiene un vecino hacia arriba
		newCas.conectado[0] = true #Conecta una tuberia
		newCas.get_node("spr_cas").frame = 1 #Imagen conectado arriba
		newCas.get_node("spr_cas").rotation_degrees = 90
		if(inicial):
			path.append(newCas.a) #Nodo inicial por donde empieza el agua luego de S
			path[-1].conectado[1] = true #Fix (lo reagregamos porque sino no lo toma al primero conexiones)
			get_tree().get_nodes_in_group("r_agua")[0].direccion = 0
			get_tree().get_nodes_in_group("r_agua")[0].nodo_actual = path[0]
			get_tree().get_nodes_in_group("r_agua")[0].nodo_anterior = path[0]
	elif(newCas.b != null): #Hace lo mismo con el resto de direcciones
		newCas.conectado[1] = true 
		newCas.get_node("spr_cas").frame = 1 #Img conectado abajo
		newCas.get_node("spr_cas").rotation_degrees = 90
		if(inicial):
			path.append(newCas.b) #Nodo inicial idem anterior
			path[-1].conectado[0] = true
			get_tree().get_nodes_in_group("r_agua")[0].direccion = 1
			get_tree().get_nodes_in_group("r_agua")[0].nodo_actual = path[0]
			get_tree().get_nodes_in_group("r_agua")[0].nodo_anterior = path[0]
	elif(newCas.c != null):
		newCas.conectado[2] = true
		newCas.get_node("spr_cas").frame = 1 #Img conectado izq
		if(inicial):
			path.append(newCas.c) #Nodo inicial
			path[-1].conectado[3] = true
			get_tree().get_nodes_in_group("r_agua")[0].direccion = 2
			get_tree().get_nodes_in_group("r_agua")[0].nodo_actual = path[0]
			get_tree().get_nodes_in_group("r_agua")[0].nodo_anterior = path[0]
	elif(newCas.d != null):
		newCas.conectado[3] = true
		newCas.get_node("spr_cas").frame = 1 #Img conectado der
		if(inicial):
			path.append(newCas.d) #Nodo inicial
			path[-1].conectado[2] = true
			get_tree().get_nodes_in_group("r_agua")[0].direccion = 3
			get_tree().get_nodes_in_group("r_agua")[0].nodo_actual = path[0] #Primer nodo donde comenzara el agua
			get_tree().get_nodes_in_group("r_agua")[0].nodo_anterior = path[0]
			



func generar_conexiones(): #Establece casilleros vecinos
	for casillero_x in cas_x: #Recorre desde 0 hasta maximo casilleros en X
		for casillero_y in cas_y: #Recorre desde 0 hasta maximo casilleros en Y
			var nodo_actual = get_tree().get_nodes_in_group("tablero")[0].get_node(String(casillero_x)+"-"+String(casillero_y)) #Obtengo el nodo actual
			if(casillero_x != 0): #Si no es el casillero X 0 conectamos el anterior izq
				nodo_actual.c = get_tree().get_nodes_in_group("tablero")[0].get_node(String(casillero_x-1)+"-"+String(casillero_y))
			if(casillero_x != cas_x-1): #Si no es el ultimo casillero X agregamos el proximo der
				nodo_actual.d = get_tree().get_nodes_in_group("tablero")[0].get_node(String(casillero_x+1)+"-"+String(casillero_y))
			if(casillero_y != 0): #Si no es casillero Y 0 agregamos el de arriba
				nodo_actual.a = get_tree().get_nodes_in_group("tablero")[0].get_node(String(casillero_x)+"-"+String(casillero_y-1))
			if(casillero_y != cas_y-1): #Si no es casillero ultimo abajo
				nodo_actual.b = get_tree().get_nodes_in_group("tablero")[0].get_node(String(casillero_x)+"-"+String(casillero_y+1))
			
func generar_all_imagenes():
	
	for nodo_actual in path:
		if(!nodo_actual.is_in_group("S") && !nodo_actual.is_in_group("T")):
			nodo_actual.generar_imagenes() #Genera el grafico del tubito que le corresponda
			
			
func generar_waypoints():
	var cantidad_waypoints = round((cas_x * cas_y) / modificador_waypoints_defecto) 
	for i in cantidad_waypoints:
		generar_waypoint()
	waypoints.append(get_tree().get_nodes_in_group("T")[0]) #Agregamos el nodo final como punto final
	
	
func generar_waypoint():
	var waypoint_x = randi()%cas_x #Genero un casillero al azar entre X e Y
	var waypoint_y = randi()%cas_y
	var nodo_actual = get_tree().get_nodes_in_group("tablero")[0].get_node(String(waypoint_x)+"-"+String(waypoint_y)) #Obtengo el nodo actual	
	if(nodo_actual == path[-1]): #Si es igual al primer casillero del path
		generar_waypoint() #Vuelvo a crear waypoint
		return #Termino la funcion
	else:
		waypoints.append(nodo_actual)
				
func generar_path(): #Creamos camino de S a T
	while(!regenerar_path && path[-1] != null && !path[-1].is_in_group("T")): #Mientras el nodo ultimo no este en el grupo T
		generar_nodo_path() #Agrega un nuevo nodo al camino
	partida_generada = true
	if(regenerar_path): #Reinicio la generacion del path y tablero
		generar_juego()
	else:
		generar_all_imagenes()
		desordenar_puzzle()
		
		


func generar_nodo_path():
	var nodo_menor_distancia
	var d = path.size()
	if(path[-1].a != null && path[-1].a != path[-2] && !path[-1].conectado[0]):
		nodo_menor_distancia = path[-1].a #Provisoriamente ponemos como menor distancia este
	
	if(path[-1].b != null && path[-1].b != path[-2] && !path[-1].conectado[1]):
		if(nodo_menor_distancia != null): #Si ya hay un nodo en menor distancia comparo si me conviene este
			var dist_b = abs(path[-1].b.global_position.x - waypoints[waypoint_actual].global_position.x) + abs(path[-1].b.global_position.y - waypoints[waypoint_actual].global_position.y)
			var dist_menor_provis = abs(nodo_menor_distancia.global_position.x - waypoints[waypoint_actual].global_position.x) + abs(nodo_menor_distancia.global_position.y - waypoints[waypoint_actual].global_position.y)
			if(dist_menor_provis > dist_b): #Si el nodo actual es mas conveniente que el que tenia
				nodo_menor_distancia = path[-1].b #Seteo el nodo actual como conveniente
		else:
			nodo_menor_distancia = path[-1].b
				
	if(path[-1].c != null && path[-1].c != path[-2] && !path[-1].conectado[2]): #Comparamos igual que arriba pero con nodo c
		if(nodo_menor_distancia != null):
			var dist_c = abs(path[-1].c.global_position.x - waypoints[waypoint_actual].global_position.x) + abs(path[-1].c.global_position.y - waypoints[waypoint_actual].global_position.y)
			var dist_menor_provis = abs(nodo_menor_distancia.global_position.x - waypoints[waypoint_actual].global_position.x) + abs(nodo_menor_distancia.global_position.y - waypoints[waypoint_actual].global_position.y)
			if(dist_menor_provis > dist_c):
				nodo_menor_distancia = path[-1].c
		else:
			nodo_menor_distancia = path[-1].c
				
	if(path[-1].d != null && path[-1].d != path[-2] && !path[-1].conectado[3]): #Comparamos igual que arriba pero con nodo d
		if(nodo_menor_distancia != null):
			var dist_d = abs(path[-1].d.global_position.x - waypoints[waypoint_actual].global_position.x) + abs(path[-1].d.global_position.y - waypoints[waypoint_actual].global_position.y)
			var dist_menor_provis = abs(nodo_menor_distancia.global_position.x - waypoints[waypoint_actual].global_position.x) + abs(nodo_menor_distancia.global_position.y - waypoints[waypoint_actual].global_position.y)
			if(dist_menor_provis > dist_d):
				nodo_menor_distancia = path[-1].d
		else:
			nodo_menor_distancia = path[-1].d
	
	if(nodo_menor_distancia == null):
		regenerar_path = true
		return
	
	
	path.append(nodo_menor_distancia) #Agregamos habiendo comparado todos, el de menor distancia
	
	
	
	if(nodo_menor_distancia == waypoints[waypoint_actual] && waypoints[waypoint_actual] != waypoints[-1]):
		waypoint_actual += 1 #Si alcanzo el waypoint y no llego al final, pasamos al siguiente waypoint
	
	generar_conexion_tubo()
	

func generar_conexion_tubo():
	if(path[-2].a != null && path[-2].a == path[-1]): #Si la conexion hacia arriba del nodo actual, es igual al nodo a agregar, significa que es el nodo de arriba
		path[-2].conectado[0] = true #Asigno tuberia arriba
		path[-1].conectado[1] = true #Al nodo a conectar le asigno esta tuberia abajo (conexion reciproca)
	if(path[-2].b != null && path[-2].b == path[-1]): #Lo mismo con el resto de direcciones
		path[-2].conectado[1] = true
		path[-1].conectado[0] = true
	if(path[-2].c != null && path[-2].c == path[-1]):
		path[-2].conectado[2] = true
		path[-1].conectado[3] = true
	if(path[-2].d != null && path[-2].d == path[-1]):
		path[-2].conectado[3] = true
		path[-1].conectado[2] = true

func desordenar_puzzle(): #Desordenamos el pathfinding ordenado para generar el puzzle
	for i in path:
		if(!i.is_in_group("S") && !i.is_in_group("T")):
			i.puede_girar = true
			i.desordenar()
