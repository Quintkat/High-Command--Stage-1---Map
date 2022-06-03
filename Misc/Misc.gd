extends Node


#func _init():
#	print(commaSep(1000000))
#	print(commaSep(1234.5678))
#	print(commaSep(1234.0))
#	print(commaSep(123.0))
#	print(commaSep(13456789))


func commaSep(n : int) -> String:
	var intPartString = str(int(n))
	var floatPartString = str(n - int(n)).right(1)
	var mod = intPartString.length() % 3
	var res = ""

	for i in range(0, intPartString.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += intPartString[i]
	
	if typeof(n) == TYPE_REAL:
		res += floatPartString

	return res


func commaSepToInt(s : String) -> int:
	s.replace(",", "")
	return int(s)


func arrayCompare(a : Array, b : Array) -> bool:
	if len(a) != len(b):
		return false
	
	for x in a:
		if !(x in b):
			return false
	
	return true


func repeatString(s : String, n : int) -> String:
	var result = ""
	for i in range(n):
		result += s
	
	return result
	









