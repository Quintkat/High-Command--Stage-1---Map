extends Node


var importDict = {}


func loadDictFromJSON(path : String) -> Dictionary:
	var file = File.new()
	if !exists(path):
		return {}
	file.open(path, File.READ)
	var dict = JSON.parse(file.get_as_text()).result
	file.close()
	return dict


# Loads an image both from within resources and outside folders like user://
func loadImage(path : String) -> Texture:
	# If it's a resource, because apparently doing img.load(path) when it's a resource already won't work in export
	if path.substr(0, 6) == "res://":
		# The .import file acts as a config file widepeepoHappy
		# And the .stex path is included within it, meaning that we can easily find the export path of the image
		if !exists(path + ".import"):
			return null
		var importFile = ConfigFile.new()
		importFile.load(path + ".import")
		var destPath = importFile.get_value("remap", "path")
		if !exists(destPath):
			return null
		
		var resource = load(destPath)
		return resource
	
	# If it's an image in the user:// folder
	if !exists(path):
		return null
	
	var img = Image.new()
	img.load(path)
	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)
	return texture


# Returns whether a file at a certain path exists
func exists(path : String) -> bool:
	var file = File.new()
	return file.file_exists(path)


