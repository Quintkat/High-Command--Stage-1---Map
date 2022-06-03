extends Node


func vectInt(v : Vector2) -> Vector2:
	return Vector2(int(v[0]), int(v[1]))


func mod(v: Vector2, m : int) -> Vector2:
	return Vector2(int(v[0])%m, int(v[1])%m)


func vec3(v : Vector2) -> Vector3:
	return Vector3(v[0], v[1], 0)


func vec2(v : Vector3) -> Vector2:
	return Vector2(v[0], v[1])
