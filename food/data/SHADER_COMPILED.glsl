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
int   MAX_ITTERS         = 356;

////////// ./data/helpers.glsl //////////

float PI = 3.14159265359;
float TWO_PI = 6.28318530718;
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
    return mat2(
        s.x, -s.y,
        s.y,  s.x
    );
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

////////// ./data/stars.glsl //////////

float stars_b1(vec2 p, vec2 q) {
    return pow(
        mod(p.x + 1, 2.0) - 1.0 + q.x,
        2.0
    ) + pow(
        mod(p.y + 1.0, 2.0) - 1.0 + q.y,
        2.0
    ) + 0.04 * sign(
        max(
            2.0 * abs(q.x - 0.5) - 0.6,
            2.0 * abs(q.y - 0.5) - 0.6
        )
    );
}
float stars_b2(vec2 p, vec2 reg) {
    return stars_b1(
        p,
        2.0 * vec2(
            rand(sin(reg.x) + cos(reg.y)),
            rand(cos(reg.x) + sin(reg.y))
        )
    );
}
float stars_bu(vec2 p) {
    return stars_b2(p,
        vec2(
            floor(0.5 * (p.x + 1)),
            floor(0.5 * (p.y + 1))
        )
    );
}

////////// ./data/func.glsl //////////

vec4 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    float ground = p.y + 0.2;
    
    vec3 ploc = p - vec3(0, 1.5, 0);
    
    ploc = rot_YZ(ploc, 0.05 * cos(time));
    ploc = rot_XZ(ploc, 0.05 * sin(time));
    
    ploc = rot_XZ(ploc, time);
    ploc.y += 0.1 * sin(time);
    
    float base = sdf_cylinder(ploc, 1.0, 0.03);
    float ring = min(max(
          sdf_cylinder(ploc - vec3(0,0.03,0), 1.02, 0.04) - 0.015,
        -(sdf_cylinder(ploc - vec3(0,0.03,0), 0.97, 0.04) - 0.02)
    ), sdf_cylinder(ploc + vec3(0,0.02,0), 1.01, 0.02));
    
    float ttop = sdf_rect(p - vec3(0, 1.2, 0), vec3(1.0, 0.1, 1.0));
    float ttopout = 0.5 * (max(
        sdf_rect(p - vec3(0, 1.2, 0), vec3(1.1, 0.05, 1.1)),
        -ttop
    ) - 0.03);
    float legs = sdf_line(vec3(abs(p.x), p.y, abs(p.z)),
        vec3(1.05, 1.2, 1.05),
        vec3(1.3, -0.2, 1.3),
        0.1);
    
    float table = min(ttop, min(ttopout, legs));
    
    float c = min(min(ground, table), min(
        base, ring
    ));
    
    
    if(is_dist) {
        return vec4(c);
    }
    
    float I = MIN_DIST_THRESHOLD * 2.0;
    if(c <= I) {
        if(ground <= I) {
            return vec4(0.0, 0.0, 0.1 + 0.4 * float(cos(2.5 * p.x) * sin(2.5 * p.z) <= 0.0), 0.0);
        }
        if(table <= I) {
            if(ttop <= I) {
                return vec4(0.65, 0.3, 0.8, 0.5);
            }
            return vec4(0.1, 0.3, 0.3, 0.0);
        }
        if(base <= I) {
            float v = 0;
            float q = 8.5;
            vec2 r = vec2(rand(q), rand(-q));
            int i = 0;
            while(i < 25) {
                r = 1.2 * (vec2(rand(r.x), rand(r.y)) - 0.5);
                vec2 l = ptc(1.2 * sqrt(abs(r.y)), TWO_PI * r.x + 0.2);
                v = min(v, length(ploc.xz - l) - 0.1);
                if(v < 0) break;
                i++;
            }
            
            return vec4(v < 0.0 ? 0.0 : 0.09, 0.7, mod(8.0 * atan(p.z, p.x) / TWO_PI, 1.0) <= 0.03 ? 0.0 : 0.5, 0.01);
        }
        if(ring <= I) {
            return vec4(0.13, 0.5, 0.5, 0.01);
        }
    }
    return vec4(0.0);
}

////////// ./data/marching.glsl //////////

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

////////// ./data/main.glsl //////////

void main() {
    float FOV = 130;
    float cam_dist = 100.0;
    
    float hFOV = FOV / 2.0 * tan(PI * FOV / 360.0) * 2.0;
    vec3 p_e = vec3(
        hFOV * (vertTexCoord.xy - 0.5) * (u_resolution / u_resolution.x),
        -cam_dist
    );
    
    float alpha = 1.0;
    float missing_alpha = 1.0;
    
    vec3 cast_s = vp_loc;
    vec3 cast_e = vp_loc + rot_XZ_YZ(p_e, -vp_ang.y, vp_ang.x);
    vec3 ray_step = normalize(cast_e - cast_s);
    vec3 ray = raymarch(
        cast_s,
        ray_step,
        MAX_ITTERS,
        vec2(MIN_DIST_THRESHOLD, MAX_DIST_THRESHOLD)
    );
    
    vec3 clr = vec3(0.0);
    if(ray != vec3(-1.0)) {
        vec3 lightRay = ray;
        
        vec4 dat = f(
            ray + MIN_DIST_THRESHOLD * ray_step,
            false
        );
        
        float car = dat.w;
        int i = 0;
        while(dat.w > 0.01 && i < 5) {
            i++;
            vec3 n = norm(ray, 0.00001);
            n = reflect_norm(ray_step, n);
            ray = raymarch(
                ray.xyz + 2.0 * MIN_DIST_THRESHOLD * n,
                n,
                MAX_ITTERS,
                vec2(MIN_DIST_THRESHOLD, MAX_DIST_THRESHOLD)
            );
            if(ray != vec3(-1.0)) {
                vec4 new = f(ray + MIN_DIST_THRESHOLD * ray_step, false);
                
                // this is not optimal
                car *= new.w;
                dat = vec4(
                    rgb2hsv(
                        mix(
                            hsv2rgb(dat.xyz),
                            hsv2rgb(new.xyz),
                            dat.w
                        )
                    ),
                    car
                );
                ray_step = normalize(n);
            }else{
                break;
            }
        }
        
        float len = dist(lightRay, cast_s);
        vec3 lightSource = vec3(15.0, 20.0, -10.0);
        vec3 lightStep = normalize(lightRay - lightSource);
        vec3 lightLoc = raymarch(
            lightSource,
            lightStep,
            MAX_ITTERS,
            vec2(MIN_DIST_THRESHOLD, 1.25 * MAX_DIST_THRESHOLD)
        );
        
        clr = hsv2rgb(dat.xyz) * max(0.35, 1.0 - max(0.0, dist(lightRay, cast_s) / 20.0 - 0.5));
            
        float d1 = dist(lightLoc, lightRay);
        if(lightLoc != vec3(-1.0) && d1 <= 1.0) {
            clr *= max(0.65, clamp(0.9 * (1 / 1.25) * max(0.0, 1.25 - 3.0 * d1), 0.0, 1.0));
        }else{
            clr *= 0.65;
        }
    }else{
        clr *= dist(vec3(50.0, 25.0, 0.0), vec3(cast_s)) * 0.016;
        alpha = missing_alpha;
    }
    
    gl_FragColor = vec4(clr, alpha);
}

