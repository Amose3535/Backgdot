extends Node
## A simple autoloads that adds an easy way to manage if an app can be run in the background or not

## The variable that decides wether the app can be run in the background or not.[br]
## When [code]backgroundable == true[/code], if the window is closed, the app will keep running in the background.
@export var backgroundable : bool = false:
	set(new_state):
		backgroundable = new_state
		toggle_app_persistenceness_to_quit()

## If the app can run in background, then make the indicator show this tooltip
@export var indicator_tooltip : String = "":
	set(new_tooltip):
		if new_tooltip != "":
			indicator_tooltip = new_tooltip
		if tray_indicator && tray_indicator.is_inside_tree():
			tray_indicator.tooltip = indicator_tooltip

@export var indicator_icon : Resource = load("res://icon.svg"):
	set(new_icon):
		if new_icon is Texture2D:
			indicator_icon = new_icon
		if tray_indicator && tray_indicator.is_inside_tree():
			tray_indicator.icon = indicator_icon

var tray_indicator : StatusIndicator = StatusIndicator.new():
	set(new_indicator):
		if tray_indicator: # An indicator already exists. Populate it with its own stuff
			tray_indicator.icon = new_indicator.icon
			tray_indicator.tooltip = new_indicator.tooltip

## The menu used to access the settings
var menu : PopupMenu = PopupMenu.new()

func toggle_app_persistenceness_to_quit() -> void:
	if backgroundable:
		# Works only if NotificationEngine addon is enabled
		if has_node("/root/NotificationEngine"):
			get_node("/root/NotificationEngine").notify({"title":"[b][color=red]Attention![/color][/b]","body":"[u]You can now safely close the app as it will stay open in the system tray.","duration":5.0,"animation_duration":2.0})
		
		tray_indicator = StatusIndicator.new()
		add_child(tray_indicator, true)
		indicator_icon = load("res://icon.svg")
		indicator_tooltip = "App running in background"
		menu = PopupMenu.new()
		add_child(menu, true)
		menu.add_item("Show app window", 1)
		menu.add_separator("_____________")
		menu.add_item("Quit",2)
		tray_indicator.menu = menu.get_path()
		menu.id_pressed.connect(_on_menu_button_pressed)
		get_tree().set_auto_accept_quit(false)
		get_window().close_requested.connect(close_window_but_not_process)

	else:
		# Make so that when closing, terminate app
		get_tree().auto_accept_quit = true # Revert change
		if get_window().close_requested.is_connected(close_window_but_not_process):
			get_window().close_requested.disconnect(close_window_but_not_process)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if backgroundable:
			pass
		else:
			get_tree().quit() # default behavior

func close_window_but_not_process():
	get_window().mode = Window.MODE_MINIMIZED
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)

func _on_menu_button_pressed(id: int) -> void:
	match id:
		1:
			# show window
			get_tree().get_root().show()
			get_window().mode = Window.MODE_WINDOWED
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, false)
			get_window().grab_focus()
		2:
			#quit_app
			get_tree().quit()
