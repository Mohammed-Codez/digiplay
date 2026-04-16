shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 current_color = texture(TEXTURE, UV);
	if (current_color == vec4(0, 0, 0, 1)) {
		COLOR = vec4(0.9882352941176471, 0.9882352941176471, 0.9882352941176471, 1);
	} else if (current_color == vec4(0.27450980392156865, 0.27450980392156865, 0.27450980392156865, 1)) {
		COLOR = vec4(0.9882352941176471, 0.596078431372549, 0.2196078431372549, 1);
	} else if (current_color == vec4(0.7058823529411765, 0.7058823529411765, 0.7058823529411765, 1)) {
		COLOR = vec4(0, 0.5803921568627451, 0, 1);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
