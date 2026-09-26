shader_type canvas_item;
uniform float alpha_cutoff = 0.98;
// Descarta apenas o halo semitransparente da arte. O rastro é um nó separado.
void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	if (pixel.a < alpha_cutoff) {
		discard;
	}
	COLOR = vec4(COLOR.rgb, 1.0);
}
