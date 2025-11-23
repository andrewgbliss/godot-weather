shader_type canvas_item;

uniform sampler2D gradient_texture : filter_linear_mipmap, source_color;
uniform float gradient_blend : hint_range(0, 1) = 0.5;
uniform float wind_strength : hint_range(0, 3) = 1.0;

void vertex() {
    float wind_speed = 1.25 * wind_strength;
    float wind_amplitude = 2.0 * wind_strength;
    VERTEX.x += sin(VERTEX.x + TIME * wind_speed + UV.y) * (1.0 - UV.y) * wind_amplitude;
    
    wind_speed = 0.45 * wind_strength;
    VERTEX.y += cos(VERTEX.y + TIME * wind_speed + UV.y) * (1.0 - UV.y) * wind_strength;
}

void fragment() {
    vec4 grass_sample = texture(TEXTURE, UV);
    vec3 base_color = grass_sample.rgb;
    float alpha = grass_sample.a;

    vec3 gradient_color = texture(gradient_texture, vec2(UV.y, 0.5)).rgb;

    vec3 final_color = mix(base_color, base_color * gradient_color, gradient_blend);

    COLOR = vec4(final_color, alpha);
}