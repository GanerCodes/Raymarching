#ifdef GL_ES
precision mediump float;
#endif

float MIN_DIST_THRESHOLD = 0.001;
float MAX_DIST_THRESHOLD = 500.0;
int   MAX_ITTERS         = 333;

varying vec4 vertTexCoord;
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform vec3 vp_loc;
uniform vec2 vp_ang;

float PI=3.14159265359;
float TWO_PI=6.28318530718;
float sq(float x){return x*x;}
float angle(vec2 p){return atan(p.g,p.r);}
float angle_between(vec2 p1,vec2 p2){return atan(p2.g-p1.g,p2.r-p1.r);}
float pml(float x,float a,float b){float t=abs(b-a);return mod(-x*sign(mod(floor(x/t),2.0)-0.5),t)+a;}
vec2 ptc(float d,float a){return vec2(d*cos(a),d*sin(a));}
vec3 rgb2hsv(vec3 c){vec4 K=vec4(0.0,-1.0/3.0,2.0/3.0,-1.0),p=mix(vec4(c.bg,K.ab),vec4(c.gb,K.rg),step(c.b,c.g)),q=mix(vec4(p.rga,c.r),vec4(c.r,p.gbr),step(p.r,c.r));float d=q.r-min(q.a,q.g),e=1e-10;return vec3(abs(q.b+(q.a-q.g)/(6.0*d+e)),d/(q.r+e),q.r);}
vec3 hsv2rgb(vec3 c){vec4 K=vec4(1.0,0.66666,0.33333,3.0);vec3 p=abs(fract(c.rrr+K.rgb)*6.0-K.aaa);return c.b*mix(K.rrr,p-K.rrr,c.g);}
bool fastDistCompare(vec3 l,float lSquared){return sq(l.x)+sq(l.y)+sq(l.z)>lSquared;}

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
float sdf_line(vec3 p, vec3 a, vec3 b, float r) { //Credit to Inigo Quilez for optimized version
    return length(p-a-(b-a)*clamp(dot(p-a,b-a)/dot(b-a,b-a),0.0,1.0))-r;
    // vec3 ap = p - a;
    // vec3 ab = b - a;
    // float c = dot(ap, ab) / dot(ab, ab);
    // if(c >= 0.0 && c <= 1.0) {
    //     return dist(a + c * ab, p) - r;
    // }else{
    //     return min(dist(a, p), dist(b, p)) - r;
    // }
}

vec3 f(vec3 p, bool is_dist) {
    vec3 o = p;
    
    float time = u_time;
    
    float thk = 0.1;
    float rthk = 0.5 * thk;
    
    float l1 = sdf_line(p, vec3(-5.0, -3.0, -20.0), vec3( 5.0, -3.0, -20.0), thk);
    
    float l5 = sdf_line(p, vec3(-5.0, -3.0, -20.0), vec3( -5.0, -3.0, -10.0), thk);
    float l6 = sdf_line(p, vec3( 5.0, -3.0, -20.0), vec3(  5.0, -3.0, -10.0), thk);
    float l7 = sdf_line(p, vec3(-5.0, 6.0, -20.0), vec3( -5.0, 6.0, -10.0), thk);
    float l8 = sdf_line(p, vec3( 5.0, 6.0, -20.0), vec3(  5.0, 6.0, -10.0), thk);
    
    float l2 = sdf_line(p, vec3(-5.0, -3.0, -20.0), vec3(-5.0,  6.0, -20.0), thk);
    float l3 = sdf_line(p, vec3( 5.0, -3.0, -20.0), vec3( 5.0,  6.0, -20.0), thk);
    float l4 = sdf_line(p, vec3(-5.0,  6.0, -20.0), vec3( 5.0,  6.0, -20.0), thk);
    
    float c1 = min(min(min(l1,l2),min(l7,l8)),min(min(l3,l6),min(l4,l5)));
    float c2 = max(
        sdf_rect(p + vec3(0.0, -1.5, 15.0), vec3(5.0, 4.5, 5.0)),
        -sdf_rect(p + vec3(0.0, -1.5, 15.0 - rthk), vec3(5.0, 4.5, 5.0 + rthk) - rthk)
    );
    
    vec3 cd = p + vec3(0.0, 1.35, 15.0);
    float disc = sdf_cylinder(cd, 2.5, 0.05);
    vec3 ld = p + vec3(0, 2.15, 15.0);
    float legCount = 6.0;
    float a = mod(atan(ld.z, ld.x) + PI / legCount, PI / (0.5 * legCount)) - PI / legCount;
    float d = length(ld.xz);
    ld.xz = d * vec2(cos(a), sin(a));
    ld.x -= 2.0;
    float table_legs = mix(
        sdf_cylinder(ld, 0.15, 0.85),
        sdf_sphere(ld + vec3(0.0, 0.45, 0.0), 0.25),
        0.075
    );
    float table = min(disc, table_legs);
    
    vec3 od = cd + vec3(0.0, -0.55, 0.0);
    float orb = sdf_sphere(od, 0.55);
    
    float c = min(min(c1, c2), min(table, orb));
    
    if(is_dist) {
        return vec3(c);
    }else{
        float I = 2.0 * MIN_DIST_THRESHOLD;
        
        if(c1 <= I)
            return vec3(0.0, 0.0, 0.5);
        if(disc <= I)
            return vec3(0.05, 0.3, 0.12 + 1.075 - pow(min(1.0, 3.4 - length(cd.xz)), 2.0));
        if(table_legs <= I)
            return vec3(0.05, 0.3, 0.15 + 0.05 * sin(cd.y));
        if(orb <= I)
            return vec3(sin(
                time + sum(od.xy * 2.0)*sin(2.0 * time) + (1.0 * od.z)*cos(3.0 * time)
            ) * 0.1, 0.5, 1.0 - length(p) * 0.03);
        return vec3(0.0, 0.0, 0.25 + 0.005 * sin(sum(3.0 * p)));
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
    vec3 p = vec3(100.0 * (vertTexCoord.xy - 0.5) * (u_resolution / u_resolution.x), -50.0);
    
    vec3 clr = vec3(0.0);
    
    vec3 cast_s = vp_loc;
    vec3 cast_e = vp_loc + rot_XZ_YZ(p, -vp_ang.y, vp_ang.x);
    vec3 ray_step = normalize(cast_e - cast_s);
    vec3 ray = raymarch(
        cast_s,
        ray_step,
        MAX_ITTERS,
        vec2(
            MIN_DIST_THRESHOLD,
            MAX_DIST_THRESHOLD
        )
    );
    
    if(ray != vec3(-1.0)) {
        vec3 dat = f(
            ray + MIN_DIST_THRESHOLD * ray_step,
            false
        );
        float len = dist(ray, cast_s);
        
        vec3 lightSource = vec3(7.0, 13.0, 0.0);
        vec3 lightLoc = raymarch(
            lightSource,
            normalize(ray - lightSource),
            MAX_ITTERS / 2,
            vec2(
                MIN_DIST_THRESHOLD * 5,
                200
            )
        );
        
        clr = hsv2rgb(dat) * max(
            0.2,
            1.0 - (
                dist(ray, cast_s) / 150.0
            )
        ) + (
            lightLoc != vec3(-1.0) ? (
                max(
                    0.0,
                    0.1 - (
                        dist(lightLoc, ray)
                    )
                )
            ) : 0.0
        );
    }
    
    gl_FragColor = vec4(clr, 1.0);
}