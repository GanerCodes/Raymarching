#ifdef GL_ES
precision lowp float;
#endif

float MIN_DIST_THRESHOLD = 0.001;
float MAX_DIST_THRESHOLD = 175.0;
int   MAX_ITTERS         = 333;

varying vec4 vertTexCoord;
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform vec3 vp_loc;
uniform vec2 vp_ang;

float PI = 3.14159265359;
float TWO_PI = 6.28318530718;
float INVERSE_PI = 0.3183098861837697;

float sq(float x){return x*x;}
float angle(vec2 p){return atan(p.y,p.x);}
float pml(float x,float a,float b){float t=abs(b-a);return mod(-x*sign(mod(floor(x/t),2.0)-0.5),t)+a;}
vec2 ptc(float d,float a){return vec2(d*cos(a),d*sin(a));}
vec2 spl(float a){return vec2(cos(a),sin(a));}
vec3 rgb2hsv(vec3 c){vec4 K=vec4(0.0,-1.0/3.0,2.0/3.0,-1.0),p=mix(vec4(c.bg,K.ab),vec4(c.gb,K.rg),step(c.b,c.g)),q=mix(vec4(p.rga,c.r),vec4(c.r,p.gbr),step(p.r,c.r));float d=q.r-min(q.a,q.g),e=1e-10;return vec3(abs(q.b+(q.a-q.g)/(6.0*d+e)),d/(q.r+e),q.r);}
vec3 hsv2rgb(vec3 c){vec4 K=vec4(1.0,0.66666,0.33333,3.0);vec3 p=abs(fract(c.rrr+K.rgb)*6.0-K.aaa);return c.b*mix(K.rrr,p-K.rrr,c.g);}
bool fastDistCompare(vec3 l,float lSquared){return sq(l.x)+sq(l.y)+sq(l.z)>lSquared;}

float smoothMin(float a, float b, float d) {
    vec2 e = vec2(min(a, b), max(a, b));
    return mix(e.x, e.y, smoothstep(-d, d, e.x - e.y));
}
float smoothMax(float a, float b, float d) {
    vec2 e = vec2(min(a, b), max(a, b));
    return mix(e.y, e.x, smoothstep(-d, d, e.x - e.y));
}
float stickyMix(float a, float b, float x, float q) {
    return mix(a, b, clamp(x + q / abs(b - a), 0.0, 1.0));
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

vec2 rotCentered(vec2 p, vec2 a, float r) {
    vec2 adj = p - a;
    vec2 sc = vec2(sin(r), cos(r));
    return vec2(
        adj.x*sc.y - adj.y*sc.x,
        adj.x*sc.x + adj.y*sc.y
    ) + a;
}
vec3 rot_XY(vec3 p,float r){return vec3(p.x*cos(r)-p.y*sin(r),p.x*sin(r)+p.y*cos(r),p.z);}
vec3 rot_XZ(vec3 p,float r){return vec3(p.x*cos(r)-p.z*sin(r),p.y,p.x*sin(r)+p.z*cos(r));}
vec3 rot_YZ(vec3 p,float r){return vec3(p.x,p.y*cos(r)-p.z*sin(r),p.y*sin(r)+p.z*cos(r));}
vec3 rot_XZ_YZ(vec3 p, float r1, float r2) {
    return rot_XZ(rot_YZ(p, r1), r2);
}

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

vec3 f(vec3 p, bool is_dist) {
    float time = u_time;

    float base = p.y + 2.0;
    
    float n = 3.0;
    float a = 0.0;
    
    vec3 rot = vec3(PI / 4, 0.0, PI / 2 - PI / 6);
    vec3 pc = rot_XY(p, -0.5) + vec3(0.4, -0.1, 0.0);
    vec3 bas = vec3(abs(pc.x) + 0.1, pc.y, -0.1 - abs(pc.z));
    vec3 r = rot_XY(
        rot_YZ(
            rot_XZ(
                bas, rot.x
            ), rot.y
        ), rot.z
    ) + vec3(0.0, -0.64, 0.0);
    
    
    float pyr = min(
        max(
            sdf_regular_poly(pc, 4, 0.0, true),
            abs(pc.y + 0.14) - 0.05
        ),
        max(
            sdf_regular_poly(r, 3, a, true),
            abs(r.y) - 0.05
        )
    );
    float cne = sdf_cone(p + vec3(3.0, 1.0, 2.0), 0.5);
    float sph = sdf_sphere(p + vec3(0, 1.0, 0), 1.0);
    float cyl = sdf_cylinder(p + vec3(1.0, 1.0, 4.0), 0.5, 1.0);
    float cbe = sdf_rect(p + vec3(5, 1.25, -0.5), vec3(0.75));
    
    float c = min(min(base, cyl), min(min(sph, cbe), min(pyr, cne)));
    
    if(is_dist) {
        return vec3(c);
    }else{
        float I = 2.0 * MIN_DIST_THRESHOLD;
        if(base <= I)
            return vec3(0.02, 0.02, cos(p.x) * sin(p.z) <= 0 ? 0.3 : 0.35);
        if(cne <= I)
            return vec3(0.5);
        if(sph <= I)
            return vec3(0.0, 0.5, 0.4);
        if(pyr <= I)
            return vec3(0.3, 0.5, 0.4);
        if(cbe <= I)
            return vec3(0.7, 0.5, 0.4);
        if(cyl <= I)
            return vec3(0.8, 0.5, 0.4);
        if(c <= I)
            return vec3(0.5 + 0.2 * sum(p.xyz), 0.5, 0.5);
        return vec3(0.2);
    }
}

vec3 raymarch(vec3 ray, vec3 ray_step, int max_itter, vec2 thres) {
    for(int i = 0; i < max_itter; i++) {
        float dis = f(ray, true).x;
        ray += dis * ray_step;
        if(dis < thres.x) {
            return ray;
        }else if(dis > thres.y) {
            return vec3(-1.0);
        }
    }
    return vec3(-1.0);
}

void main() {
    vec3 p = vec3(80.0 * (vertTexCoord.xy - 0.5) * (u_resolution / u_resolution.x), -60.0);
    
    vec3 clr = vec3(0.0);
    
    vec3 cast_s = vp_loc;
    vec3 cast_e = vp_loc + rot_XZ_YZ(p, -vp_ang.y, vp_ang.x);
    vec3 ray_step = normalize(cast_e - cast_s);
    vec3 ray = raymarch(
        cast_s,
        ray_step,
        MAX_ITTERS,
        vec2(MIN_DIST_THRESHOLD, MAX_DIST_THRESHOLD)
    );
    
    if(ray != vec3(-1.0)) {
        vec3 dat = f(
            ray + MIN_DIST_THRESHOLD * ray_step,
            false
        );
        float len = dist(ray, cast_s);
        vec3 lightSource = vec3(-120.0, 30.0, -6.0);
        vec3 lightLoc = raymarch(
            lightSource,
            normalize(ray - lightSource),
            MAX_ITTERS / 2,
            vec2(MIN_DIST_THRESHOLD, MAX_DIST_THRESHOLD)
        );
        
        clr = hsv2rgb(dat) * max(0.35, 1.0 - max(0.0, dist(ray, cast_s) / 20.0 - 0.5));
            
        float d1 = dist(lightLoc, ray);
        if(lightLoc != vec3(-1.0) && d1 <= 1.0) {
            clr *= max(
                0.65,
                clamp(
                    0.9 * (1 / 1.25) * max(
                        0.0,
                        1.25 - 3.0 * d1
                    ),
                    0.0, 1.0
                )
            );
        }else{
            clr *= 0.65;
        }
    }else{
        clr *= dist(vec3(50.0, 25.0, 0.0), vec3(cast_s)) * 0.016;
    }
    
    gl_FragColor = vec4(clr, 1.0);
}