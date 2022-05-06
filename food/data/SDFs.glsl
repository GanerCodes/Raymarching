float sdf_sphere(vec3 p, float r) {
    return length(p) - r;
}
float sdf_cylinder(vec3 p, float r, float h) {
    return max(length(p.zx) - r, abs(p.y) - h);
}
float sdf_rect(vec3 p, vec3 s) {
    vec3 adj = abs(p) - s;
    return vmin(adj) <= 0 ? vmax(adj) : length(adj);
}
float sdf_line(vec3 p, vec3 a, vec3 b, float r) {
    vec3 pia = p - a, 
         bia = b - a;
    return length(pia - bia * clamp(dot(pia, bia) / dot(bia, bia), 0.0, 1.0)) - r;
}
float sdf_regular_poly(vec3 p, float n, float r, bool inner) {
    vec2 fl = p.xz;
    
    float g = floor(0.5 * n * (INVERSE_PI * angle(fl) + 1.0));
    float temp = TWO_PI / n;
    vec2 a1 = spl(temp * g + PI);
    vec2 ah = spl(temp * (g + 1.0) + PI);
    
    vec2 l1 = fl - a1,
         l2 = ah - a1;
    vec2 np = a1 + clamp(dot(l1, l2) / dot(l2, l2), 0.0, 1.0) * l2;
    
    return (inner ? sign(length(fl) - length(np)) : 1.0) * dist(np, fl) - r;
}
float sdf_cone(vec3 p, float r) { // TODO the actual math
    return 0.5 * sdf_cylinder(p, 0.3 - 0.3 * p.y, 1.0);
}