extends Node

##################################
# This class is not used anymore #
##################################

func getDirectories(path : String) -> Array:
	var dir = Directory.new()
	if !dir.dir_exists(path):
		dir.make_dir_recursive(path)
		return []

	var dirs = []
	dir.open(path)
	dir.list_dir_begin(true)
	var next = dir.get_next()
	while next != "":
		dirs.append(next)
		next = dir.get_next()

	return dirs
