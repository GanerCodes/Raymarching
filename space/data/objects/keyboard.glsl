vec4 object_keyboard(vec3 p, bool dist) {
    float s = 0.2;
    vec2 g = mod(p.xz + s, 2.0 * s) - s;
    vec3 t = vec3(g.x, p.y, g.y);
    
    float keys = max(
        0.5 * mix(sdf_rect(t, vec3(0.65 * s)),
            sdf_rect(t + vec3(0,0.1,0), vec3(0.4 * s)),
            0.2),
        sdf_rect(p + 0.67 * s * vec3(1.0, 0.0, 1.0), vec3(2.4, 1.0, 1.2)));
    
    float board = 0.5 * mix(
        sdf_rect(p + vec3(s,0.25,s), vec3(2.45, 0.2, 1.25)),
        sdf_rect(p + vec3(s,0.0,s), vec3(2.4, 0.2, 1.2)),
        0.1);
    
    float c = min(keys, board);
    if(dist) return vec4(c);
    
    if(keys <= MCR && p.y >= 0.0 && t.x > -0.05 && t.x < 0.05) {
        float q = t.z - 0.02 * cos(53.0 * t.x + sum(p.xz));
        if(q <= 0 && q >= -0.03) {
            return vec4(0.0, 0.0, 0.4, 0.0);
        }
    }
    if(board <= MCR) {
        return vec4(0.0, 0.0, 0.23, 0.01);
    }
    return vec4(0.0, 0.0, 0.5, 0.01);
}