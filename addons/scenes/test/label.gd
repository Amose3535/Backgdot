extends Label


func _process(delta: float) -> void:
	text = "Can be backgrounded: Yes" if BackgroundManager.backgroundable else "Can be backgrounded: No"


func _on_button_pressed() -> void:
	BackgroundManager.backgroundable = !BackgroundManager.backgroundable
