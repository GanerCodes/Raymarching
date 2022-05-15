// This is an AUTOGENERATED file, do not edit!



////////// ./data/head.glsl //////////

#ifdef GL_ES
precision lowp float;
#endif

varying vec4 vertTexCoord;
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform vec3 vp_loc;
uniform vec2 vp_ang;

float MIN_DIST_THRESHOLD = 0.001;
float MAX_DIST_THRESHOLD = 1000.0;
float DENSITY_THRESHOLD  = 0.99;
int   MAX_ITTERS         = 256;
int   MAX_BOUNCE_COUNT   = 12;
float MCR = 2.0 * MIN_DIST_THRESHOLD;
float TMCR = 2.0 * MCR;

////////// ./data/helpers.glsl //////////

float PI = 3.14159265359;
float TWO_PI = 6.28318530718;
float HALF_PI = 1.570796326795;
float QUARTER_PI = 0.7853981633975;
float INVERSE_PI = 0.3183098861837697;

float sq(float x){return x*x;}
float pml(float x,float a,float b){float t=abs(b-a);return mod(-x*sign(mod(floor(x/t),2.0)-0.5),t)+a;}
vec2 ptc(float d,float a){return vec2(d*cos(a),d*sin(a));}
vec2 spl(float a){return vec2(cos(a),sin(a));}
vec3 rgb2hsv(vec3 c){vec4 K=vec4(0.0,-1.0/3.0,2.0/3.0,-1.0),p=mix(vec4(c.bg,K.ab),vec4(c.gb,K.rg),step(c.b,c.g)),q=mix(vec4(p.rga,c.r),vec4(c.r,p.gbr),step(p.r,c.r));float d=q.r-min(q.a,q.g),e=1e-10;return vec3(abs(q.b+(q.a-q.g)/(6.0*d+e)),d/(q.r+e),q.r);}
vec3 hsv2rgb(vec3 c){vec4 K=vec4(1.0,0.66666,0.33333,3.0);vec3 p=abs(fract(c.rrr+K.rgb)*6.0-K.aaa);return c.b*mix(K.rrr,p-K.rrr,c.g);}
bool fastDistCompare(vec3 l,float lSquared){return sq(l.x)+sq(l.y)+sq(l.z)>lSquared;}

float modloop(float a, float b) {
    float t = 0.5 * b;
    return mod(a + t, b) - t;
}
vec2 modloop(vec2 a, float b) {
    return vec2(modloop(a.x, b), modloop(a.y, b));
}
vec3 modloop(vec3 a, float b) {
    return vec3(modloop(a.x, b), modloop(a.y, b), modloop(a.z, b));
}
vec4 modloop(vec4 a, float b) {
    return vec4(modloop(a.x, b), modloop(a.y, b), modloop(a.z, b), modloop(a.w, b));
}

float vmin(vec2 p){return min(p.x,p.y);}
float vmax(vec2 p){return max(p.x,p.y);}
float vmin(vec3 p){return min(p.x,vmin(p.yz));}
float vmax(vec3 p){return max(p.x,vmax(p.yz));}
float vmin(vec4 p){return min(p.x,vmin(p.yzw));}
float vmax(vec4 p){return max(p.x,vmax(p.yzw));}

float sum(vec2 p){return p.x+p.y;}
float sum(vec3 p){return p.x+p.y+p.z;}
float sum(vec4 p){return p.x+p.y+p.z+p.w;}

float dist(vec2 p1,vec2 p2){return length(p2-p1);}
float dist(vec3 p1,vec3 p2){return length(p2-p1);}
float dist(vec4 p1,vec4 p2){return length(p2-p1);}

float smoothMin(float a, float b, float d) {
    vec2 e = vec2(min(a, b), max(a, b));
    return mix(e.x, e.y, smoothstep(-d, d, e.x - e.y));
}
float smoothMax(float a, float b, float d) {
    vec2 e = vec2(min(a, b), max(a, b));
    return mix(e.y, e.x, smoothstep(-d, d, e.x - e.y));
}
float smoothFloor(float a, float b) {
    return floor(a) + pow(mod(a, 1.0), b);
}
float stickyMix(float a, float b, float x, float q) {
    return mix(a, b, clamp(x + q / abs(b - a), 0.0, 1.0));
}

////////// ./data/vectors.glsl //////////

float angle(vec2 p) { return atan(p.y,p.x); }
vec2 reflect_norm(vec2 p, vec2 n) { return p - 2.0 * n * dot(p, n); }
vec3 reflect_norm(vec3 p, vec3 n) { return p - 2.0 * n * dot(p, n); }
vec4 reflect_norm(vec4 p, vec4 n) { return p - 2.0 * n * dot(p, n); }

vec2 rotCentered(vec2 p, vec2 a, float r) {
    vec2 adj = p - a;
    vec2 sc = vec2(sin(r), cos(r));
    return vec2(
        adj.x*sc.y - adj.y*sc.x,
        adj.x*sc.x + adj.y*sc.y
    ) + a;
}
mat2 rotMatrix(vec2 p, float r) {
    vec2 s = spl(r);
    return mat2(s.x, -s.y,
                s.y,  s.x);
}
vec3 rot_XY(vec3 p, float r){
    vec2 m = p.xy * rotMatrix(p.xy, r);
    return vec3(m, p.z);
}
vec3 rot_XZ(vec3 p, float r){
    vec2 m = p.xz * rotMatrix(p.xz, r);
    return vec3(m.x, p.y, m.y);
}
vec3 rot_YZ(vec3 p, float r){
    vec2 m = p.yz * rotMatrix(p.yz, r);
    return vec3(p.x, m);
}
vec3 rot_XZ_YZ(vec3 p, float r1, float r2) {
    return rot_XZ(rot_YZ(p, r1), r2);
}

vec3 angsToDir(float rot1, float rot2) {
    return rot_XZ(rot_XY(vec3(1.0, 0.0, 0.0), rot2  ), rot1  );
}
vec3 angsToDir(vec2 rots) {
    return rot_XZ(rot_XY(vec3(1.0, 0.0, 0.0), rots.y), rots.x);
}
vec2 dirToAng(vec3 p) {
    return vec2(atan(p.z, p.x), atan(p.y, length(p.xz)));
}

vec3 nearest_point_line(vec3 p, vec3 dir, vec3 orig) {
    return orig + dir * dot(p - orig, normalize(dir));
}
vec3 nearest_point_line(vec3 p, vec3 dir) {
    return dir * dot(p, normalize(dir));
}

vec3 rotate3(vec3 p, vec3 rot) {
    p = rot_XZ(p, -rot.x);
    p = rot_XY(p, -rot.y);
    p = rot_YZ(p, rot.z);
    p = rot_XY(p, rot.y);
    p = rot_XZ(p, rot.x);
    return p;
}
vec3 rotateAxis(vec3 p, vec3 V, float a) {
    return rotate3(p, vec3(dirToAng(V), a));
}

////////// ./data/quaternions.glsl //////////

vec4 quat_mul(vec4 q1, vec4 q2) {
    return vec4(q1.w*q2.x+q1.x*q2.w+q1.y*q2.z-q1.z*q2.y,
                q1.w*q2.y-q1.x*q2.z+q1.y*q2.w+q1.z*q2.x,
                q1.w*q2.z+q1.x*q2.y-q1.y*q2.x+q1.z*q2.w,
                q1.w*q2.w-q1.x*q2.x-q1.y*q2.y-q1.z*q2.z);
}
vec4 quat_conj(vec4 q) {
    return vec4(-q.xyz, q.w);
}
vec4 quat_rot(vec4 p, vec4 vhat, float angle) {
    angle *= 0.5;
    vec4 q = quat_mul(vec4(vec3(0.0), sin(angle)), vhat);
    q.w = cos(angle);
    return quat_mul(quat_mul(q, p), quat_conj(q));
}

////////// ./data/random.glsl //////////

// https://stackoverflow.com/a/17479300/14501641

uint hash( uint x ) {
    x += ( x << 10u );
    x ^= ( x >>  6u );
    x += ( x <<  3u );
    x ^= ( x >> 11u );
    x += ( x << 15u );
    return x;
}

uint hash( uvec2 v ) { return hash( v.x ^ hash(v.y)                         ); }
uint hash( uvec3 v ) { return hash( v.x ^ hash(v.y) ^ hash(v.z)             ); }
uint hash( uvec4 v ) { return hash( v.x ^ hash(v.y) ^ hash(v.z) ^ hash(v.w) ); }

float floatConstruct( uint m ) {
    const uint ieeeMantissa = 0x007FFFFFu; // binary32 mantissa bitmask
    const uint ieeeOne      = 0x3F800000u; // 1.0 in IEEE binary32

    m &= ieeeMantissa;                     // Keep only mantissa bits (fractional part)
    m |= ieeeOne;                          // Add fractional part to 1.0

    float  f = uintBitsToFloat( m );       // Range [1:2]
    return f - 1.0;                        // Range [0:1]
}

float rand( float x ) { return floatConstruct(hash(floatBitsToUint(x))); }
float rand( vec2  v ) { return floatConstruct(hash(floatBitsToUint(v))); }
float rand( vec3  v ) { return floatConstruct(hash(floatBitsToUint(v))); }
float rand( vec4  v ) { return floatConstruct(hash(floatBitsToUint(v))); }

////////// ./data/SDFs.glsl //////////

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

////////// ./data/objects/keyboard.glsl //////////

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

////////// ./data/objects/monitor.glsl //////////

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

////////// ./data/func.glsl //////////

/* uniform vec3 play_loc;
uniform vec4 play_quat;

// struct cheese {
//     float x;
// };
// cheese transcheese(cheese xd) {
//     xd.x += 2;
//     return xd;
// }

vec3 base_color = vec3(0.0, 0.0, 0.0);
vec4 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    float ground_offset = 0.5;
    float ground = p.y + ground_offset;
    
    vec3 t = p - play_loc;
    t = quat_mul(
        quat_mul(
            play_quat,
            vec4(t, 0.0)),
        quat_conj(play_quat)
    ).xyz;
    
    vec3 noseloc = t - vec3(0, 0.8, 0);
    float body = sdf_rect(t, vec3(0.5, 1.0, 0.5));
    
    float skybox = -sdf_sphere(p, 500.0);
    
    float player = max(
        min(body,
            sdf_sphere(noseloc, 0.9)),
        sdf_rect(t, vec3(0.5, 2.0, 0.5)));
    player *= 0.5;
    
    vec3 monitor_loc = p + vec3(0.0, 0.0, 6.0);
    float[] objects = {
        ground,
        player,
        object_keyboard(p, true).x,
        object_monitor(monitor_loc, true).x,
        skybox
    };
    
    float c = min(objects[0], objects[1]);
    for(int i = 2; i < objects.length(); i++) {
        c = min(c, objects[i]);
    }
    
    if(is_dist) return vec4(c);
    
    if(c <= MCR) {
        // if(objects[4] <= MCR) {
            // return vec4(mix(-0.2, 0.1, 0.5 + 0.5 * sin(mod(0.5 * time + tan(0.001 * sum(p)), TWO_PI))), 0.75, 0.8, 0.0);
        // }
        if(player <= MCR) {
            float q = 0.1 * smoothstep(1.0, 1.5, t.y);
            float w = max(
                0.2 * smoothstep(0.63, 0.69, length(t.xz)),
                0.2 * smoothstep(1.25, 1.28, length(vec2(t.y - 0.25, vmax(abs(t.xz)))))
            );
            
            return vec4(mix(0.1 * t.y + w, 0.5, q), 0.5, 0.75, 0.5 - 0.5 * q);
        }
        if(objects[2] <= MCR) {
            return object_keyboard(p, false);
        }
        if(objects[3] <= MCR) {
            return object_monitor(monitor_loc, false);
        }
    }
    if(ground <= MCR) {
        return vec4(0.0,0.0,0.02 + 0.1 * smoothstep(-0.05, 0.05,(sin(p.y+ground_offset)+cos(p.x)*sin(p.z))), 0.05);
    }
    return vec4(0.0);
} */

////////// ./data/marching.glsl //////////

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

////////// ./data/main.glsl //////////

void main() {
    float FOV = 125;
    float cam_dist = 100.0;
    
    float hFOV = FOV / 2.0 * tan(PI * FOV / 360.0) * 2.0;
    vec3 p_e = vec3(
        hFOV * (vertTexCoord.xy - 0.5) * (u_resolution / u_resolution.x),
        -cam_dist
    );
    
    vec3 cast_s = vp_loc;
    vec3 cast_e = vp_loc + rot_XZ_YZ(p_e, -vp_ang.y, vp_ang.x);
    vec3 ray_step = normalize(cast_e - cast_s);
    Tracer tracer = trace(cast_s, ray_step);
    tracer = raymarch(tracer);
    vec3 clr = tracer.tot_material.color;
    
    gl_FragColor = vec4(clr, 1.0);
}

