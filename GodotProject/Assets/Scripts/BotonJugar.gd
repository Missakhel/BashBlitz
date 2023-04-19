extends TextureButton


func _on_BotonJugar_pressed():
	#SceneTransition.change_scene("res://Scene/RivazScene.tscn")
	get_tree().change_scene("res://Assets/Scenes/RivazScene.tscn")
