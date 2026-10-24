extends MarginContainer
## Insets are converted from display pixels into the stretched canvas coordinates.

func _ready() -> void:
	resized.connect(_update_insets)
	get_viewport().size_changed.connect(_update_insets)
	_update_insets()

func _update_insets() -> void:
	var insets := Vector4(12, 8, 12, 8)
	if OS.has_feature("android") or OS.has_feature("ios"):
		var safe := DisplayServer.get_display_safe_area()
		var window := DisplayServer.window_get_size()
		if window.x > 0 and window.y > 0 and safe.has_area():
			var scale_factor := get_viewport_rect().size / Vector2(window)
			insets.x = maxf(12, safe.position.x * scale_factor.x)
			insets.y = maxf(8, safe.position.y * scale_factor.y)
			insets.z = maxf(12, (window.x - safe.end.x) * scale_factor.x)
			insets.w = maxf(8, (window.y - safe.end.y) * scale_factor.y)
	for side in ["left", "top", "right", "bottom"]:
		var index := ["left", "top", "right", "bottom"].find(side)
		add_theme_constant_override("margin_" + side, int(insets[index]))
