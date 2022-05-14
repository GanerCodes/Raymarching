vec4 object_monitor(vec3 p, bool dist) {
    vec3 t = p - vec3(0, 2.5, 0);
    
    float invr = sdf_rect(t - vec3(0, 0, 3.7), vec3(2.0));
    float base = max(0.5 * mix(
            sdf_rect(t, vec3(3.0)),
            sdf_sphere(t - vec3(0, 0, -3), 5),
            0.1),
          -invr);
    float plane = max(sdf_rect(t, vec3(2.0, 2.0, 3.5)), max(p.z - 2.8, 2.0 - p.z));
    
    float c = min(base, plane);
    if(dist) return vec4(c);
    
    if(c <= MCR) {
        if(base <= MCR) {
            return vec4(0.0, 0.0, 0.6, 0.0);
        }
        if(invr <= MCR && p.z >= 0) {
            return vec4(0.0, 0.0, 0.0, 1.0 + 0.5 * sin(u_time));
        }
    }
    
    return vec4(0.0);
}