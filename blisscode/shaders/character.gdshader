shader_type canvas_item;

uniform float teleport_progress : hint_range(0.0, 1.0);
uniform float teleport_noise_density = 60;
uniform float teleport_beam_size : hint_range(0.01, 0.15);
uniform vec4 teleport_color : source_color = vec4(1.0);

uniform vec4 pulse_shine_color : source_color = vec4(1.0); //Shine color
uniform float pulse_alpha_limit : hint_range(0.0, 1.0, 0.1) = 0.0; //Alpha color limit to apply the shine, for example, if you won't to apply the shine to semi-transparent pixels
uniform float pulse_cycle_speed : hint_range(0.0, 10.0, 0.1) = 1.0; //Pulse cycle speed
uniform bool pulse_cycle = false; //[False = Do the effect and make a pause] [True = Do the effect continuosly]
uniform int pulse_mode : hint_range(0, 2, 1) = 0; //[0 = Always off] [1 = Pulse mode] [2 = Always on]

// We are generating our own noise here. You could experiment with the 
// built in SimplexNoise or your own noise texture for other effects.
vec2 random(vec2 uv){
  uv = vec2( dot(uv, vec2(127.1,311.7) ),
              dot(uv, vec2(269.5,183.3) ) );
  return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
  vec2 uv_index = floor(uv);
  vec2 uv_fract = fract(uv);

  vec2 blur = smoothstep(0.0, 1.0, uv_fract);

  return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                    dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
              mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                    dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) * 0.5 + 0.5;
  return 0.0;
}

void fragment()
{
    vec4 tex = texture(TEXTURE, UV);
    
    float noise = noise(UV * teleport_noise_density) * UV.y;
    
    float d1 = step(teleport_progress, noise);
    float d2 = step(teleport_progress - teleport_beam_size, noise);
    
    vec3 beam = vec3(d2 - d1) * teleport_color.rgb;
    
    tex.rgb += beam;
    tex.a *= d2;
    
    COLOR = tex;

    //Check if the effect is enabled
    if (pulse_mode > 0)
    {
      //Check the pixel alpha value
      if (COLOR.a >= pulse_alpha_limit)
      {
        //Check the mode
        switch (pulse_mode)
        {
          case 1: //Pulse mode
          {
            float cycle = sin(TIME * pulse_cycle_speed);
            COLOR.rgb = mix(COLOR.rgb, pulse_shine_color.rgb, (((cycle >= 0.0) || (pulse_cycle)) ? abs(cycle) : 0.0) * pulse_shine_color.a);
            break;
          }
          case 2: //Always on
          {
            COLOR.rgb = mix(COLOR.rgb, pulse_shine_color.rgb, pulse_shine_color.a);
            break;
          }
        }
      }
    }

}
