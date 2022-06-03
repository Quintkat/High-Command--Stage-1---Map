extends Node

const REPUBLIC = "Republic"
const UNITED_REPUBLIC = "United Republic"
const KINGDOM = "Kingdom"
const TSARDOM = "Tsardom"
const PRINCIPALITY = "Principality"
const THEOCRACY = "Theocracy"
const KHANATE = "Khanate"

const GOVPOWER_DEMOCRATIC = "Democratic"
const GOVPOWER_AUTHORITARIAN = "Authoritarian"
const GOVPOWER_OTHER = "Other"

#const all = [REPUBLIC, UNITED_REPUBLIC, KINGDOM, TSARDOM, PRINCIPALITY, THEOCRACY, KHANATE]
#const POS_PRE = "pre"
#const POS_POST = "post"
#const POS_ADJPRE = "adjpre"
#const POS_ADJPOST = "adjpost"
#
#const INTER_OF = "of"

const power = {
	REPUBLIC		: GOVPOWER_DEMOCRATIC,
	UNITED_REPUBLIC	: GOVPOWER_DEMOCRATIC,
	KINGDOM			: GOVPOWER_AUTHORITARIAN,
	TSARDOM			: GOVPOWER_AUTHORITARIAN,
	PRINCIPALITY	: GOVPOWER_AUTHORITARIAN,
	THEOCRACY		: GOVPOWER_AUTHORITARIAN,
	KHANATE			: GOVPOWER_AUTHORITARIAN,
}

#const pos = {
#	REPUBLIC		: POS_PRE,
#	UNITED_REPUBLIC	: POS_PRE,
#	KINGDOM			: POS_PRE,
#	TSARDOM			: POS_PRE,
#	PRINCIPALITY	: POS_PRE,
#	THEOCRACY		: POS_ADJPRE,
#	KHANATE			: POS_ADJPOST,
#}
#
#const interject = {
#	REPUBLIC		: INTER_OF,
#	UNITED_REPUBLIC	: INTER_OF,
#	KINGDOM			: INTER_OF,
#	TSARDOM			: INTER_OF,
#	PRINCIPALITY	: INTER_OF,
#	THEOCRACY		: "Holy",
#	KHANATE			: "Khanate",
#}

#func governmentFullName(gf : String, n : String, enter = false):
#	if pos[gf] == POS_PRE:
#		var output = gf + " " + interject[gf]
#		if enter:
#			output += "\n"
#		else:
#			output += " "
#		output += n
#		return output
#	elif pos[gf] == POS_POST:
#		var output = n + " " + interject[gf]
#		if enter:
#			output += "\n"
#		else:
#			output += " "
#		output += gf
#		return output
#	elif pos[gf] == POS_ADJPRE:
#		var output = 0
#		return interject[gf] + " " + n
#	elif pos[gf] == POS_ADJPOST:
#		return n + " " + interject[gf]
#	else:
#		return "SOMETHING WENT WRONG"


func power(gf : String):
	return power[gf]


func getAll() -> Array:
	return power.keys()












