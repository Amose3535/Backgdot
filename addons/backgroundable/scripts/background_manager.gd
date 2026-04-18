extends Node

## A simple autoload that adds an easy way to manage if an app can be run in the background or not

@export var backgroundable : bool = false:
	set(new_state):
		backgroundable = new_state
		# Aggiorniamo lo stato solo se il nodo è già nella scena (evita errori all'avvio)
		if is_inside_tree():
			toggle_app_persistenceness_to_quit()

@export var indicator_tooltip : String = "App running in background":
	set(new_tooltip):
		indicator_tooltip = new_tooltip
		if tray_indicator:
			tray_indicator.tooltip = indicator_tooltip

@export var indicator_icon : Resource = preload("res://icon.svg"):
	set(new_icon):
		if new_icon is Texture2D:
			indicator_icon = new_icon
		if tray_indicator:
			tray_indicator.icon = indicator_icon

var tray_indicator : StatusIndicator
var menu : PopupMenu

func _ready():
	# Inizializza lo stato corretto appena l'autoload è pronto
	toggle_app_persistenceness_to_quit()

func toggle_app_persistenceness_to_quit() -> void:
	if backgroundable:
		# Disattiva la chiusura automatica
		get_tree().set_auto_accept_quit(false)
		
		# Crea il menu se non esiste
		if not menu:
			menu = PopupMenu.new()
			add_child(menu)
			menu.add_item("Show app window", 1)
			menu.add_separator("_____________")
			menu.add_item("Quit", 2)
			menu.id_pressed.connect(_on_menu_button_pressed)
		
		# Crea l'indicatore se non esiste
		if not tray_indicator:
			tray_indicator = StatusIndicator.new()
			add_child(tray_indicator)
			tray_indicator.icon = indicator_icon
			tray_indicator.tooltip = indicator_tooltip
			tray_indicator.menu = menu.get_path()

		# Notifica opzionale
		if has_node("/root/NotificationEngine"):
			get_node("/root/NotificationEngine").notify({"title":"[b][color=red]Attention![/color][/b]","body":"[u]You can now safely close the app as it will stay open in the system tray.[/u]","duration":5.0,"animation_duration":2.0})

		# Connetti la richiesta di chiusura
		if not get_window().close_requested.is_connected(close_window_but_not_process):
			get_window().close_requested.connect(close_window_but_not_process)

	else:
		# Ripristina il comportamento normale
		get_tree().set_auto_accept_quit(true) 
		
		if get_window().close_requested.is_connected(close_window_but_not_process):
			get_window().close_requested.disconnect(close_window_but_not_process)
		
		# Pulisci e cancella in sicurezza tray e menu
		if tray_indicator:
			tray_indicator.queue_free()
			tray_indicator = null
		if menu:
			menu.queue_free()
			menu = null

func close_window_but_not_process():
	# Nasconde del tutto la finestra dalla barra delle applicazioni
	get_window().hide()

func _on_menu_button_pressed(id: int) -> void:
	match id:
		1:
			# Mostra la finestra
			get_window().show()
			get_window().mode = Window.MODE_WINDOWED
			get_window().grab_focus()
		2:
			# Chiudi l'app definitivamente
			get_tree().quit()
