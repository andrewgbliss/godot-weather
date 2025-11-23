shader_type canvas_item;

// This shader simulates a breaking effect for a sprite offsetting parts of the texture using cellular noise
// Uses a mask texture to determine which tiles on screen should be affected

uniform float break_intensity : hint_range(0.0, 1.0, 0.01) = 0.04;
uniform float color_shift_intensity : hint_range(0.0, 1.0, 0.01) = 0.32;

// This sample texture should be a cellular noise texture with 'Return Type: Cell Value'
uniform sampler2D break_texture;

// Mask texture that controls which screen areas are affected
// R channel: break progress (0.0 = no break, 1.0 = fully broken)
uniform sampler2D break_mask : filter_nearest;

void fragment() {
    // Sample the mask at the current screen position
    vec4 mask_sample = texture(break_mask, SCREEN_UV);
    float break_progress = mask_sample.r;
    
    if(break_progress > 0.0) {
        // We sample using break_progress to make the break differ on every change.
        // This only looks good if the increases are sudden (like pickaxes hitting a rock), instead of gradual
        vec4 noise = texture(break_texture, UV * break_progress); 
        COLOR = texture(TEXTURE, UV + ((vec2(noise.r / 2.  )) - 0.25) * break_intensity * break_progress , 0.0);
        COLOR.rgb -=  noise.r * break_progress * color_shift_intensity;
    }
}