shader_type canvas_item;

uniform vec2 grid_pos;  // The piece's position in the grid
uniform vec2 grid_size; // Total number of pieces (grid size)

void fragment() {
    vec2 uv_step = 1.0 / grid_size;
    vec2 uv_offset = grid_pos * uv_step;

    vec2 masked_uv = uv_offset + uv_step * UV;
    vec4 tex_color = texture(TEXTURE, masked_uv);

    // Alpha masking
    COLOR = tex_color;
    if (tex_color.a < 0.1) {
        discard;  // Hide areas outside the mask
    }
}
