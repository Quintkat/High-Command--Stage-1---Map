extends Node


func createImage(col : Color) -> Image:
	var img = Image.new()
	img.create(TileConstants.SIZE*3, TileConstants.SIZE, false, Image.FORMAT_RGBA8)
	img.fill(col)
	return img


func createTexture(col : Color) -> ImageTexture:
	var texture = ImageTexture.new()
	texture.create_from_image(createImage(col))
	return texture


func createIcon(col : Color) -> ImageTexture:
	var img = createImage(col)
	img.shrink_x2()
	img.shrink_x2()
	img.shrink_x2()
	var texture = ImageTexture.new()
	texture.create_from_image(img)
	return texture
