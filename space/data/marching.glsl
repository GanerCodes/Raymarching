const uint BIT_SOLID = 1;
const uint BIT_REFLECTIVE = 2;

struct Material {
    vec3 color;
    float dense;
    uint state;
} aether = {vec3(0.0), 0.0, 0};

Material Solid(vec3 color, float dense) { return Material(color, dense, 0); }
Material Solid(vec3 color) { return Material(color, 1.0, BIT_SOLID); }
Material Solid(vec4 color) { return Material(color.rgb, color.a, 0); }
Material Solid(float r, float g, float b, float d) { return Material(vec3(r,g,b), d, 0); }
Material Solid(float r, float g, float b) { return Material(vec3(r,g,b), 0, BIT_SOLID); }

struct Tracer_materials {
    Material tot; // Total
    Material cur; // Current
    Material def; // Default
};
struct Tracer {
    vec3 cur_pos;
    vec3 pre_pos;
    vec3 dir;
    float dist;
    bool flag;
    int bounce_count;
    Tracer_materials mat;
};

Tracer make_tracer(vec3 cur_pos, vec3 dir, Material default_material) {
    return Tracer(cur_pos, cur_pos, dir, 0.0, false, 0, Tracer_materials(aether, aether, default_material));
}

Tracer f(Tracer tracer, bool dist) {
    vec3 p = tracer.cur_pos;
    
    // float obj_1 = sdf_rect(p + vec3(1.0, -2.0, 0.0), vec3(1.0, 2.0, 1.0));
    float ground_offset = 4.0;
    float ground = p.y + ground_offset;
    float obj_1 = sdf_sphere(p, 1.0);
    float obj_2 = sdf_sphere(p - vec3(7.0, 0.0, 0.0), 1.0);
    float obj_3 = 0.8 * mix(
        sdf_sphere(p - vec3(1.0, 5.0, 0.0), 1.0),
        sdf_rect(p - vec3(1.0, 5.0, 0.0), vec3(1.0)),
        0.5
    );
    float obj_4 = sdf_rect(p - vec3(2.0, 1.0, 2.0), vec3(1.0));
    
    tracer.dist = min(min(min(obj_1, ground), obj_4), min(obj_2, obj_3));
    if(dist) return tracer;
    
    if(tracer.dist <= MCR) { // TODO two materials at once
        if(ground <= MCR) {
            tracer.mat.cur = Solid(
                vec3(0.02 + 0.1 * smoothstep(-0.05, 0.05,(sin(p.y+ground_offset)+cos(p.x)*sin(p.z)))),
                0.05
            );
        }
        if(obj_2 <= MCR) {
            tracer.mat.cur = Solid(0.0, 1.0, 0.0);
        }
        if(obj_4 <= MCR) {
            tracer.mat.cur = Solid(0.0, 0.0, 1.0);
        }
        if(obj_3 <= MCR) {
            tracer.mat.cur = Material(
                vec3(0.6, 0.9, 1.0), 0.3, BIT_REFLECTIVE);
        }
        if(obj_1 <= MCR) {
            tracer.mat.cur = Solid(1.0, 0.0, 0.0, 0.4);
        }
        return tracer;
    }
    
    tracer.mat.cur = tracer.mat.def;
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
    tracer.mat.cur = f(tracer, false).mat.cur;
    for(int itter = 0; itter < MAX_ITTERS; itter++) {
        tracer = f(tracer, true);
        if(tracer.dist > MCR) {
            // Outside any shape, use default material
            tracer.mat.cur = tracer.mat.def;
        }
        
        float last_material_dist = dist(tracer.pre_pos, tracer.cur_pos);
        float mat_dense = min(1.0, tracer.mat.cur.dense * last_material_dist);
        float prop = 1.0 - tracer.mat.tot.dense;
        float dense = prop * mat_dense;
        float tot_dense = tracer.mat.tot.dense + dense;
        
        float d = abs(tracer.dist);
        bool check = d > MAX_DIST_THRESHOLD || tot_dense > DENSITY_THRESHOLD;
        if(d < MIN_DIST_THRESHOLD || check) {
            // Check if flag, aka hasn't yet left edge of surface
            if(tracer.flag && !check) {
                // Move a minimum amount
                tracer.cur_pos += TMCR * tracer.dir;
                continue;
            }
            tracer.flag = true;
            
            // Merge materials
            tracer.mat.tot.color = mix(tracer.mat.tot.color, tracer.mat.cur.color, dense);
            tracer.mat.tot.dense = tot_dense;
            
            // Get net material
            tracer.mat.cur = f(tracer, false).mat.cur;
            
            if(tracer.mat.cur.state == BIT_SOLID) {
                // Solid, set remaining light color to the color
                tracer.mat.tot.color = mix(tracer.mat.tot.color, tracer.mat.cur.color, prop);
                tracer.mat.tot.dense = 1.0;
                return tracer;
            }
            
            if(tracer.mat.cur.state == BIT_REFLECTIVE) {
                // Reflective, merge color according density property, then bounce light
                float newt = prop * tracer.mat.cur.dense;
                tracer.mat.tot.color = mix(tracer.mat.tot.color, tracer.mat.cur.color, newt);
                tracer.mat.tot.dense += newt;
                tracer.dir = norm(tracer, 0.001);
                tracer.bounce_count++;
                if(tracer.bounce_count == MAX_BOUNCE_COUNT) return tracer;
            }
            
            if(check) {
                // Some exit condition reached
                return tracer;
            }
            
            tracer.pre_pos = tracer.cur_pos;
        }else{
            tracer.flag = false;
        }
        
        tracer.cur_pos += abs(tracer.dist) * tracer.dir;
    }
    return tracer;
}