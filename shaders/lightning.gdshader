shader_type canvas_item;
render_mode unshaded;

uniform vec3 effect_color: source_color = vec3(0.2, 0.3, 0.8);
uniform int octave_count: hint_range(1, 20) = 10;
uniform float amp_start = 0.5;
uniform float amp_coeff = 0.5;
uniform float freq_coeff = 2.0;
uniform float speed = 0.5;
uniform float flicker_on_time: hint_range(0.05, 5.0) = 0.5;
uniform float flicker_off_time: hint_range(0.1, 20.0) = 5.0;


float hash12(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}

vec2 hash22(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1,311.7)),
              dot(uv, vec2(269.5,183.3)));
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, fuv);
    return mix(mix(dot(hash22(iuv + vec2(0.0,0.0)), fuv - vec2(0.0,0.0)),
                   dot(hash22(iuv + vec2(1.0,0.0)), fuv - vec2(1.0,0.0)), blur.x),
               mix(dot(hash22(iuv + vec2(0.0,1.0)), fuv - vec2(0.0,1.0)),
                   dot(hash22(iuv + vec2(1.0,1.0)), fuv - vec2(1.0,1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 uv, int octaves) {
    float value = 0.0;
    float amplitude = amp_start;
    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise(uv);
        uv *= freq_coeff;
        amplitude *= amp_coeff;
    }
    return value;
}

void fragment() {
    vec2 uv = 2.0 * UV - 1.0;
    uv += 2.0 * fbm(uv + TIME * speed, octave_count) - 1.0;
    float dist = max(abs(uv.x), 0.01);
    float cycle_time = flicker_on_time + flicker_off_time;
    float cycle_pos = mod(TIME, cycle_time);
    float flicker_on = 1.0 - step(flicker_on_time, cycle_pos);
    vec3 color = effect_color * mix(0.0, 0.05, hash12(vec2(TIME))) / dist * flicker_on;
    float alpha = clamp(max(max(color.r, color.g), color.b), 0.0, 1.0);
    COLOR = vec4(color, alpha);
}
