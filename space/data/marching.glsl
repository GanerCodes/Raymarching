struct Material {
    vec3 color;
    float dense;
    bool reflective;
};
Material Solid(vec3 color, float dense) { return Material(color, dense, false); } 

Material aether = Solid(vec3(0.05), 0.01);

struct Tracer {
    vec3 cur_pos;
    vec3 pre_pos;
    vec3 dir;
    float dist;
    bool flag;
    Material tot_material;
    Material cur_material;
};

Tracer trace(vec3 cur_pos, vec3 dir) {
    return Tracer(cur_pos, cur_pos,
                  dir, 0.0, false,
                  aether, aether);
}

Tracer f(Tracer tracer, bool dist) {
    vec3 p = tracer.cur_pos;
    
    float ball_1 = sdf_sphere(p * vec3(1.0, 0.5, 1.0), 1.0);
    float ball_2 = sdf_sphere(p + vec3(3.0, 0.0, 0.0), 1.0);
    float ball_3 = sdf_sphere(p + vec3(1.0, 5.0, 0.0), 1.0);
    
    tracer.dist = min(ball_1, min(ball_2, ball_3));
    if(dist) return tracer;
    
    if(tracer.dist <= MCR) { // TODO two materials at once
        if(ball_1 <= MCR) {
            tracer.cur_material = Solid(
                vec3(1.0, 0.0, 0.0),
                0.3);
        }
        if(ball_2 <= MCR) {
            tracer.cur_material = Solid(
                vec3(0.0, 1.0, 0.0),
                10.0);
        }
        if(ball_3 <= MCR) {
            tracer.cur_material = Material(
                vec3(0.6, 0.9, 1.0),
                0.5,
                true);
        }
        return tracer;
    }
    
    tracer.cur_material = aether;
    return tracer;
}

vec3 norm(Tracer tracer, float delta) {
    float base = f(tracer, true).dist;
    vec3 pos = tracer.cur_pos;
    
    tracer.cur_pos = pos + vec3(delta,0,0);
    float a = f(tracer, true).dist;
    tracer.cur_pos = pos + vec3(0,delta,0);
    float b = f(tracer, true).dist;
    tracer.cur_pos = pos + vec3(0,0,delta);
    float c = f(tracer, true).dist;
    
    return normalize(vec3(a, b, c) - base);
}

Tracer raymarch(Tracer tracer) {
    int bounce_count = 0;
    tracer.cur_material = f(tracer, false).cur_material;
    for(int itter = 0; itter < MAX_ITTERS; itter++) {
        tracer = f(tracer, true);
        
        float last_material_dist = dist(tracer.pre_pos, tracer.cur_pos);
        float mat_dense = min(1.0, tracer.cur_material.dense * last_material_dist);
        float dense = (1 - tracer.tot_material.dense) * mat_dense;
        float tot_dense = tracer.tot_material.dense + dense;
        
        if(tracer.dist > MIN_DIST_THRESHOLD) tracer.cur_material = aether;
        float d = abs(tracer.dist);
        bool check = d > MAX_DIST_THRESHOLD || tot_dense > DENSITY_THRESHOLD || itter == MAX_ITTERS - 1;
        if(d < MIN_DIST_THRESHOLD || check) {
            if(tracer.flag && !check) {
                tracer.cur_pos += TMCR * tracer.dir;
                continue;
            } tracer.flag = true;
            
            tracer.pre_pos = tracer.cur_pos;
            tracer.tot_material = Material(
                mix(tracer.tot_material.color,
                    tracer.cur_material.color,
                    dense),
                tot_dense,
                false);
            
            tracer.cur_material = f(tracer, false).cur_material;
            if(tracer.cur_material.reflective) {
                float newt = (1 - tracer.tot_material.dense) * tracer.cur_material.dense;
                tracer.tot_material.color = mix(tracer.tot_material.color,
                                                tracer.cur_material.color,
                                                newt);
                tracer.tot_material.dense += newt;
                tracer.dir = norm(tracer, 0.001);
                tracer.pre_pos = tracer.cur_pos;
                bounce_count++;
                if(bounce_count == MAX_BOUNCE_COUNT) {
                    return tracer;
                }
            }
            if(check) return tracer;
        }else{
            tracer.flag = false;
        }
        
        tracer.cur_pos += abs(tracer.dist) * tracer.dir;
    }
    return tracer;
}