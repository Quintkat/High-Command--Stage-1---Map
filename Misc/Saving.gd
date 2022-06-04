extends Node

func saveDictToJSON(path : String, dict : Dictionary):
	var saveFile = File.new()
	saveFile.open(path, File.WRITE)
	saveFile.store_line(JSON.print(dict, "\t"))
	saveFile.close()

