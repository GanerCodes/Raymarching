vec4 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    ivec2 grid = ivec2(floor(p.xz));
    float c = p.y + 0.1;
    if(is_dist) return vec4(c);
    
    vec2 loc = vec2(grid) / count + 0.51; // Super janky
    if(abs(loc.x-0.5)>0.5||abs(loc.y-0.5)>0.5) return vec4(0.0);
    loc.x *= -1;
    
    float g = 255.0 * texture2D(image, mod(loc, 1)).x;
    if(g < 2) return vec4(0.0);
    
    bool U = mod(g+0.02,2)<=0.04;
    bool R = mod(g+0.02,3)<=0.04;
    bool D = mod(g+0.02,5)<=0.04;
    bool L = mod(g+0.02,7)<=0.04;
    
    vec2 n = mod(p.xz, 1.0);
    
    float s = 0.1;
    float cl = 0.0;
    if(
        (U && n.x >= 0.5 - s && abs(n.y - 0.5) <= 0.1) ||
        (D && n.x <= 0.5 + s && abs(n.y - 0.5) <= 0.1) ||
        (L && n.y <= 0.5 + s && abs(n.x - 0.5) <= 0.1) ||
        (R && n.y >= 0.5 - s && abs(n.x - 0.5) <= 0.1)
    ) cl = 1.0;
    
    return vec4(0.0, 0.0, cl, 0.0);
}