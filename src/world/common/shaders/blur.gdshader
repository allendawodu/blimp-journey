shader_type canvas_item;

// Main blur control (higher = more blur)
uniform float blur_amount : hint_range(0.0, 5.0) = 1.0;
// Control for number of samples (higher = better quality but slower)
uniform int sample_count : hint_range(4, 16) = 8;
// Screen texture is required for post-processing effects
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Multi-sample Gaussian blur implementation compatible with web builds
void fragment() {
    // Base variables
    vec2 pixel_size = SCREEN_PIXEL_SIZE;
    float blur_radius = pow(2.0, blur_amount);

    // Initialize color accumulator
    vec4 color_total = vec4(0.0);
    float weight_total = 0.0;

    // Gaussian distribution for weights
    float sigma = blur_radius / 2.0;
    float two_sigma_squared = 2.0 * sigma * sigma;

    // Multi-sample circular blur with Gaussian falloff
    // Using a fixed number of samples with varying angles for better coverage
    for (int i = 0; i < sample_count; i++) {
        // Calculate angle for current sample
        float angle = float(i) * (2.0 * 3.14159265) / float(sample_count);

        // Create offset vector (using cos/sin for circular pattern)
        vec2 offset = vec2(cos(angle), sin(angle)) * blur_radius * pixel_size;

        // Apply different lengths for better distribution
        for (int d = 1; d <= 3; d++) {
            vec2 sample_offset = offset * float(d) / 3.0;

            // Calculate weight based on distance (Gaussian)
            float distance_squared = dot(sample_offset / pixel_size, sample_offset / pixel_size);
            float weight = exp(-distance_squared / two_sigma_squared);

            // Sample the texture at offset position (avoid using textureLod for compatibility)
            vec4 sample_color = texture(SCREEN_TEXTURE, SCREEN_UV + sample_offset);

            // Add weighted sample to total
            color_total += sample_color * weight;
            weight_total += weight;
        }
    }

    // Add center sample with higher weight
    float center_weight = 1.0;
    color_total += texture(SCREEN_TEXTURE, SCREEN_UV) * center_weight;
    weight_total += center_weight;

    // Normalize by total weight
    COLOR = color_total / weight_total;

    // Optional: Add a slight contrast adjustment to compensate for blur
    if (blur_amount > 0.5) {
        float contrast = 1.0 + blur_amount * 0.05;
        COLOR.rgb = (COLOR.rgb - 0.5) * contrast + 0.5;
    }
}