shader_type canvas_item;
uniform float flash : hint_range(0.0, 1.0) = 0.0;
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
 vec4 sample_color = texture(TEXTURE, UV);
 COLOR = vec4(mix(sample_color.rgb, vec3(1.0), flash), sample_color.a) * tint;
}
