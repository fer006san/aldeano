extends Node2D

# =========================
# NODOS
# =========================

@onready var capa_1: Sprite2D = $ParallaxBackground/ParallaxLayer/Sprite2D
@onready var capa_2: Sprite2D = $ParallaxBackground/ParallaxLayer2/Sprite2D
@onready var capa_3: Sprite2D = $ParallaxBackground/ParallaxLayer3/Sprite2D

@onready var aldeano_sprite: Sprite2D = $aldeano/Sprite2D
@onready var texto_dialogo: Label = $CanvasLayer/"Texto Dialogo"

@onready var btn_aceptar: TextureButton = $CanvasLayer/BtnAceptar
@onready var btn_rechazar: TextureButton = $CanvasLayer/BtnRechazar
@onready var btn_preguntar: TextureButton = $CanvasLayer/BtnPreguntar


# =========================
# BACKGROUND CON VIDA
# =========================

var tiempo := 0.0

var pos_capa_1: Vector2
var pos_capa_2: Vector2
var pos_capa_3: Vector2


# =========================
# TEXTURAS DEL ALDEANO
# =========================

var tex_happy = preload("res://ui/aldeano/happy.png")
var tex_pointing = preload("res://ui/aldeano/pointing.png")
var tex_presenting = preload("res://ui/aldeano/presenting.png")
var tex_thinking = preload("res://ui/aldeano/thinking.png")


# =========================
# ESTADO DE MISIÓN / MATERIALES
# =========================

# Esto después lo vas a conectar con cofres o inventario.
# Para probar, podés cambiar true / false manualmente.
var mision_aceptada := false

var tiene_cristal_bosque := false
var tiene_piedra_antigua := false
var tiene_fragmento_arcano := false

# Cambiá esto a true para probar directamente el diálogo de regreso.
var modo_revision_materiales := false


# =========================
# CONTROL DEL DIÁLOGO
# =========================

var indice_dialogo := 0
var dialogo_terminado := false
var esperando_volver_a_pregunta := false
var esperando_salir := false

var dialogo_actual = []


# =========================
# DIÁLOGO INICIAL
# =========================

var dialogos_mision_inicial = [
	{
		"texto": "Ah... justo la persona que necesitaba ver.",
		"reaccion": "thinking"
	},
	{
		"texto": "He estado trabajando en un proyecto muy importante para la aldea, pero me falta algo esencial para poder terminarlo.",
		"reaccion": "presenting"
	},
	{
		"texto": "No son materiales comunes. Necesito piezas especiales que solo se encuentran en lugares antiguos, escondidas dentro de cofres olvidados.",
		"reaccion": "pointing"
	},
	{
		"texto": "Según mis apuntes, esos cofres están repartidos más allá de la aldea, en distintos caminos y zonas que pocos se atreven a explorar.",
		"reaccion": "presenting"
	},
	{
		"texto": "No puedo abandonar mi taller ahora. Si lo hago, todo lo que he avanzado podría arruinarse.",
		"reaccion": "thinking"
	},
	{
		"texto": "Por eso necesito pedirte un favor.",
		"reaccion": "happy"
	},
	{
		"texto": "Viaja por los diferentes mapas, busca los cofres y reúne los materiales que encuentres en ellos.",
		"reaccion": "pointing"
	},
	{
		"texto": "Cuando los tengas todos, vuelve conmigo. Con tu ayuda, podré terminar este invento.",
		"reaccion": "happy"
	},
	{
		"texto": "¿Aceptarás ayudarme?",
		"reaccion": "presenting"
	}
]


# =========================
# DIÁLOGO: FALTAN MATERIALES
# =========================

var dialogos_materiales_incompletos = [
	{
		"texto": "Has vuelto. Déjame ver...",
		"reaccion": "thinking"
	},
	{
		"texto": "Aún faltan algunos materiales.",
		"reaccion": "thinking"
	},
	{
		"texto": "Vas por buen camino, pero todavía no es suficiente para terminar el proyecto.",
		"reaccion": "presenting"
	},
	{
		"texto": "Sigue explorando los mapas y revisa los cofres que encuentres.",
		"reaccion": "pointing"
	},
	{
		"texto": "Estoy seguro de que los materiales restantes están ahí fuera.",
		"reaccion": "happy"
	}
]


# =========================
# DIÁLOGO: MATERIALES COMPLETOS
# =========================

var dialogos_materiales_completos = [
	{
		"texto": "¡Volviste! Y... espera un momento...",
		"reaccion": "thinking"
	},
	{
		"texto": "Sí... sí, estos son exactamente los materiales que necesitaba.",
		"reaccion": "happy"
	},
	{
		"texto": "El Cristal del Bosque, la Piedra Antigua y el Fragmento Arcano... no puedo creer que hayas logrado encontrarlos todos.",
		"reaccion": "presenting"
	},
	{
		"texto": "Gracias a ti, ahora podré terminar mi invento.",
		"reaccion": "happy"
	},
	{
		"texto": "No solo me ayudaste a mí, también ayudaste a toda la aldea.",
		"reaccion": "happy"
	},
	{
		"texto": "Este proyecto llevaba mucho tiempo detenido, y pensé que jamás conseguiría las piezas que faltaban.",
		"reaccion": "thinking"
	},
	{
		"texto": "Has demostrado valentía, paciencia y un gran corazón.",
		"reaccion": "presenting"
	},
	{
		"texto": "Acepta mi agradecimiento... y también esta recompensa. Te la has ganado.",
		"reaccion": "happy"
	}
]


# =========================
# READY
# =========================

func _ready():
	# Guardamos posiciones originales del fondo
	pos_capa_1 = capa_1.position
	pos_capa_2 = capa_2.position
	pos_capa_3 = capa_3.position

	# Texto negro
	texto_dialogo.add_theme_color_override("font_color", Color.BLACK)

	# Botones ocultos al inicio
	ocultar_botones()

	# Conectamos botones
	btn_aceptar.pressed.connect(_on_btn_aceptar_pressed)
	btn_rechazar.pressed.connect(_on_btn_rechazar_pressed)
	btn_preguntar.pressed.connect(_on_btn_preguntar_pressed)

	# Elegimos qué diálogo mostrar al entrar a la escena
	if modo_revision_materiales:
		iniciar_revision_materiales()
	else:
		iniciar_mision_inicial()


# =========================
# PROCESS
# =========================

func _process(delta):
	tiempo += delta

	capa_1.position = pos_capa_1 + Vector2(
		sin(tiempo * 0.18) * 3.0,
		sin(tiempo * 0.12) * 0.8
	)

	capa_2.position = pos_capa_2 + Vector2(
		sin(tiempo * 0.25) * 6.0,
		sin(tiempo * 0.20) * 1.2
	)

	capa_3.position = pos_capa_3 + Vector2(
		sin(tiempo * 0.35) * 9.0,
		sin(tiempo * 0.28) * 1.8
	)


# =========================
# INPUT
# =========================

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		
		if esperando_salir:
			salir_de_dialogo()
		
		elif esperando_volver_a_pregunta:
			volver_a_pregunta_principal()
		
		elif dialogo_terminado == false:
			avanzar_dialogo()


# =========================
# INICIAR DIÁLOGOS
# =========================

func iniciar_mision_inicial():
	indice_dialogo = 0
	dialogo_terminado = false
	esperando_volver_a_pregunta = false
	esperando_salir = false
	modo_revision_materiales = false

	dialogo_actual = dialogos_mision_inicial
	mostrar_linea()


func iniciar_revision_materiales():
	indice_dialogo = 0
	dialogo_terminado = false
	esperando_volver_a_pregunta = false
	esperando_salir = false
	modo_revision_materiales = true

	if tiene_todos_los_materiales():
		dialogo_actual = dialogos_materiales_completos
	else:
		dialogo_actual = dialogos_materiales_incompletos

	mostrar_linea()


# =========================
# FUNCIONES DEL DIÁLOGO
# =========================

func mostrar_linea():
	var linea_actual = dialogo_actual[indice_dialogo]

	texto_dialogo.text = linea_actual["texto"]
	cambiar_reaccion(linea_actual["reaccion"])

	if indice_dialogo == dialogo_actual.size() - 1:
		dialogo_terminado = true

		if modo_revision_materiales:
			esperando_salir = true
		else:
			mostrar_botones()


func avanzar_dialogo():
	if indice_dialogo < dialogo_actual.size() - 1:
		indice_dialogo += 1
		mostrar_linea()


func volver_a_pregunta_principal():
	esperando_volver_a_pregunta = false
	dialogo_terminado = true
	indice_dialogo = dialogos_mision_inicial.size() - 1

	dialogo_actual = dialogos_mision_inicial
	mostrar_linea()
	mostrar_botones()


func cambiar_reaccion(reaccion: String):
	match reaccion:
		"happy":
			aldeano_sprite.texture = tex_happy
		"pointing":
			aldeano_sprite.texture = tex_pointing
		"presenting":
			aldeano_sprite.texture = tex_presenting
		"thinking":
			aldeano_sprite.texture = tex_thinking


func mostrar_botones():
	btn_aceptar.visible = true
	btn_rechazar.visible = true
	btn_preguntar.visible = true


func ocultar_botones():
	btn_aceptar.visible = false
	btn_rechazar.visible = false
	btn_preguntar.visible = false


# =========================
# BOTONES
# =========================

func _on_btn_aceptar_pressed():
	ocultar_botones()

	mision_aceptada = true

	texto_dialogo.text = "Gracias, sabía que podía contar contigo. Explora bien cada zona, revisa todos los cofres y vuelve cuando tengas los materiales."
	cambiar_reaccion("happy")

	# Después de leer este mensaje, con Enter o click sale de la escena
	esperando_salir = true


func _on_btn_rechazar_pressed():
	ocultar_botones()

	texto_dialogo.text = "Lo entiendo. No todos están preparados para salir más allá de la aldea. Si cambias de opinión, vuelve a hablar conmigo."
	cambiar_reaccion("thinking")

	# Después de leer este mensaje, con Enter o click sale de la escena
	esperando_salir = true


func _on_btn_preguntar_pressed():
	ocultar_botones()

	texto_dialogo.text = "Necesito materiales poco comunes: el Cristal del Bosque, la Piedra Antigua y el Fragmento Arcano. Están ocultos en cofres repartidos por distintos mapas."
	cambiar_reaccion("pointing")

	# Después de leer este mensaje, con Enter o click vuelve a preguntar si acepta la misión
	esperando_volver_a_pregunta = true


# =========================
# MATERIALES
# =========================

func tiene_todos_los_materiales() -> bool:
	return tiene_cristal_bosque and tiene_piedra_antigua and tiene_fragmento_arcano


# =========================
# SALIR DE LA ESCENA
# =========================

func salir_de_dialogo():
	get_tree().change_scene_to_file("res://Aldeano/aldea.tscn")
