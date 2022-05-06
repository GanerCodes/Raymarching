// Uses function f
vec3 norm(vec3 p, float delta) {
    float base = f(p, true).x;
    
    return normalize(vec3(
        f(p + delta*vec3(1,0,0), true).x - base,
        f(p + delta*vec3(0,1,0), true).x - base,
        f(p + delta*vec3(0,0,1), true).x - base
    ));
}

// Uses function f
vec3 raymarch(vec3 ray, vec3 ray_step, int max_itter, vec2 thres) {
    float totalDist = 0.0;
    for(int i = 0; i < max_itter; i++) {
        float dis = f(ray, true).x;
        totalDist += dis;
        ray += dis * ray_step;
        if(dis < thres.x) {
            return ray;
        }else if(totalDist > thres.y) {
            return vec3(-1.0);
        }
    }
    return vec3(-1.0);
}