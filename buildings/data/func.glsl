vec3 f(vec3 p, bool is_dist) {
    float time = u_time;

    float base = p.y + 2.0;
    
    float v = 5.0;
    float hv = 0.5 * v;
    
    vec2 ad = p.xz + hv;
    vec2 l_ = mod(ad, v) - hv;
    vec2 n = floor(ad / v);
    vec3 l = vec3(l_.x, p.y, l_.y);
    
    float sph = sdf_sphere(l, 0.5);
    
    float buildType = floor(2.0 * rand(n));
    
    
    float c = min(base, sph);
    
    if(is_dist) {
        return vec3(c);
    }
    
    float I = 2.0 * MIN_DIST_THRESHOLD;
    if(base <= I)
        return vec3(0.02, 0.02, cos(p.x) * sin(p.z) <= 0 ? 0.3 : 0.35);
    if(sph <= I)
        return vec3(0.5 * buildType, 0.5, 0.5);
}