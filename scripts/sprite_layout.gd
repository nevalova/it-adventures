extends RefCounted

# Normalize the visible character, not the sheet's transparent padding.
static var bounds_cache: Dictionary = {}

static func configure(sprite: Sprite2D, tag: Label = null, height: float = 38.0) -> void:
	if sprite.texture == null:
		return
	sprite.hframes = 4
	sprite.vframes = 12
	var key = sprite.texture.resource_path
	var bounds: Rect2i
	if bounds_cache.has(key):
		bounds = bounds_cache[key]
	else:
		var image = sprite.texture.get_image()
		var cell = Vector2i(image.get_width() / 4, image.get_height() / 12)
		bounds = image.get_region(Rect2i(Vector2i.ZERO, cell)).get_used_rect()
		bounds_cache[key] = bounds
	if bounds.size.y <= 0:
		return
	var factor = height / float(bounds.size.y)
	var cell_size = sprite.texture.get_size() / Vector2(4, 12)
	sprite.scale = Vector2.ONE * factor
	# Every animation uses the same origin at the standing frame's feet.
	sprite.position = Vector2(0, -(float(bounds.end.y) - cell_size.y * 0.5) * factor)
	if tag != null:
		tag.position.y = -height - 15.0
