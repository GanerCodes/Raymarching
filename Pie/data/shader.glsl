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
    return length(p-a-(b-a)*clamp(dot(p-a,b-a)/dot(b-a,b-a),0.0,1.0))-r;
}

float rand(float x) {
    return mod(tan(pow(abs(2 + x), abs(2 + x))), 1.0);
}
float b1(vec2 p, vec2 q) {
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
float b2(vec2 p, vec2 reg) {
    return b1(
        p,
        2.0 * vec2(
            rand(sin(reg.x) + cos(reg.y)),
            rand(cos(reg.x) + sin(reg.y))
        )
    );
}
float bu(vec2 p) {
    return b2(p,
        vec2(
            floor(0.5 * (p.x + 1)),
            floor(0.5 * (p.y + 1))
        )
    );
}

vec3 f(vec3 p, bool is_dist) {
    float time = u_time;
    
    p += vec3(
        2.0 * sin(0.5 * time),
        8.0 * pow(cos(time), 2.0) - 3.0,
        0.5 * cos(0.5 * time)
    );
    p = rot_XY(
        rot_XZ_YZ(p,
            0.7 * (sin(time) - 0.2),
            3.0 * time
        ),
        0.3 * sin(2.0 * time)
    );
    
    vec3 cl = p;
    cl.xz *= 1.0 / (1.0 + 0.2 * p.y);
    float b = sdf_cylinder(cl, 1.0, 2.0);
    float r = sdf_rect(
        p + vec3(0.0, 0.5, 0.0),
        vec3(1.0, 0.2, 1.0)
    );
    
    vec3 pt = p + vec3(0.0, 0.3, 0.0);
    vec3 ptrans = vec3(1.0, 0.4, 1.0);
    pt /= ptrans;
    float topang = atan(p.z, p.x);
    float adjQ = 0.05 * cos(10.0 * atan(2.0 * p.z, p.x));
    float pie = max(
        sdf_sphere(
            pt, 0.98
        ) * vmin(ptrans),
        -pt.y - (0.3 + adjQ)
    ) * 0.25;
    
    float c = min(
        max(b, r),
        pie
    );
    
    if(is_dist) {
        return vec3(c);
    }else{
        float I = 2.0 * MIN_DIST_THRESHOLD;
        if(pie <= I) {
            float q = 0.05 * pow(abs(cos(5.0 * topang)), 10.0) * (0.5 - 2.0 * p.y);
            return vec3(
                0.1,
                0.3 + q,
                mix(
                    0.4 - q + 0.15 * (
                        5.0 * (
                            p.y + 0.25
                        ) - adjQ
                    ) - (
                        max(
                            0.0,
                            0.08 * (
                                pow(
                                    abs(
                                        cos(5.0 * topang)
                                    ),
                                    100.0
                                )
                            )
                        )
                    ),
                    0.6,
                    clamp(
                        10.0 * (p.y + 0.03),
                        0.0,
                        1.0
                    )
                )
            );
        }
        if(r <= I)
            return vec3(0.0, 0.0, 0.5 + (cos(20*topang) <= -0.85 ? 0.1 : 0));
        return vec3(0.5);
    }
}

vec3 raymarch(vec3 ray, vec3 ray_step, int max_itter, vec2 thres) {
    for(int i = 0; i < max_itter; i++) {
        float dis = f(ray, true).x;
        ray += dis * ray_step;
        if(dis < thres.x) {
            return vec3(ray);
        }else if(dis > thres.y) {
            return vec3(-1.0);
        }
    }
    return vec3(-1.0);
}

void main() {
    vec2 normPoint = vec2((vertTexCoord.xy - 0.5) * (u_resolution / u_resolution.x));
    vec3 p = vec3(100.0 * normPoint, -60.0);
    
    vec3 clr = vec3(0.0);
    float starLoc = bu(500.0 * (normPoint - vec2(
        50.0 + 0.001 * cos(0.25 * u_time),
        40.0 + 0.0008 * sin(0.23 * u_time)
    )));
    if(starLoc.x < 0) {
        clr += 1.0;
    }
    
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
    vec3 ray_close = raymarch(
        cast_s,
        ray_step,
        MAX_ITTERS,
        vec2(
            1.0,
            MAX_DIST_THRESHOLD
        )
    );
    
    if(ray != vec3(-1.0)) {
        vec3 dat = f(
            ray + MIN_DIST_THRESHOLD * ray_step,
            false
        );
        float len = dist(ray, cast_s);
        
        clr = hsv2rgb(dat) * max(
            0.35,
            1.0 - (
                dist(ray, cast_s) / 20.0
            )
        );
        clr -= 0.002 * pow(dist(ray, ray_close), 2.0);
        
        vec3 lightSource = vec3(40.0, 40.0, 20.0);
        vec3 lightLoc = raymarch(
            lightSource,
            normalize(ray - lightSource),
            MAX_ITTERS,
            vec2(
                MIN_DIST_THRESHOLD,
                512
            )
        );
        
        if(lightLoc != vec3(-1.0)) {
            float d1 = dist(lightLoc, ray);
            float d2 = dist(lightLoc, lightSource);
            clr *= clamp(
                0.9 * (1 / 1.25) * max(0.0, 1.0 - 0.3 * d1),
                0.0, 1.0
            );
        }else{
            clr *= 0.4;
        }
    }else{
        clr *= dist(vec3(50.0, 25.0, 0.0), vec3(cast_s)) * 0.016;
    }
    
    gl_FragColor = vec4(clr, 1.0);
}