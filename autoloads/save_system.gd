extends Node

var save_data = {
	"unlocked_levels": [],
	"completed_levels": [],
}

const SAVE_PATH = "user://savegame.json"

func save_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	save_data = JSON.parse_string(file.get_as_text())
	file.close()

func unlock_level(level_name: String):
	if level_name not in save_data["unlocked_levels"]:
		save_data["unlocked_levels"].append(level_name)
		save_game()
