#define SDF_PX 8.0
#define EDGE_GAMMA 0.105/DEVICE_PIXEL_RATIO

uniform bool u_has_halo;
#pragma mapbox: define highp vec4 fill_color
#pragma mapbox: define highp vec4 halo_color
#pragma mapbox: define lowp float opacity
#pragma mapbox: define lowp float halo_width
#pragma mapbox: define lowp float halo_blur

uniform sampler2D u_texture;
uniform highp float u_gamma_scale;
uniform bool u_is_text;

varying vec2 v_data0;
varying vec3 v_data1;

void main() {
    #pragma mapbox: initialize highp vec4 fill_color
    #pragma mapbox: initialize highp vec4 halo_color
    #pragma mapbox: initialize lowp float opacity
    #pragma mapbox: initialize lowp float halo_width
    #pragma mapbox: initialize lowp float halo_blur

    vec2 tex = v_data0.xy;
    float gamma_scale = v_data1.x;
    float size = v_data1.y;

    lowp float dist = texture2D(u_texture, tex).a;
    float fontScale = u_is_text ? size / 24.0 : size;

    lowp vec4 color = fill_color;
    highp float gamma = EDGE_GAMMA / (fontScale * u_gamma_scale);
    lowp float buff = (256.0 - 64.0) / 256.0;

    highp float gamma_scaled = gamma * u_gamma_scale;
    highp float alpha = smoothstep(buff - gamma_scaled, buff + gamma_scaled, dist);
    if (u_has_halo) {
        gamma = (halo_blur * 1.19 / SDF_PX + EDGE_GAMMA) / (fontScale * u_gamma_scale);
        highp float gamma_scaled_halo = gamma * u_gamma_scale;
        lowp float buff_halo = (6.0 - halo_width / fontScale) / SDF_PX;
        highp float alpha_halo = smoothstep(buff_halo - gamma_scaled, buff_halo + gamma_scaled, dist);
        color = mix(halo_color, color, alpha);
        alpha = alpha_halo;
    }
    gl_FragColor = color * (alpha * opacity);

#ifdef OVERDRAW_INSPECTOR
    gl_FragColor = vec4(1.0);
#endif
}
