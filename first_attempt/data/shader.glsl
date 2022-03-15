#ifdef GL_ES
precision mediump float;
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
    vec3 pia = p - a, 
         bia = b - a;
    return length(pia - bia * clamp(dot(pia, bia) / dot(bia, bia), 0.0, 1.0)) - r;
}


vec4 chair(vec3 p) {
    vec3 cbs = vec3(0.85, 0.9, 0.9);
    vec3 caj = vec3(-0.1, 0.0, 0.0);
    float base = max(
        sdf_rect(
            p + caj,
            cbs
        ),
        -sdf_rect(
            p + caj + vec3(0.05, -0.15, 0.0),
            1.01 * cbs
        )
    );
    float legs = min(
        sdf_rect(
            vec3(p.x + 0.7, p.y + 1.35, abs(p.z) - 0.85),
            vec3(0.12, 0.65, 0.12)
        ),
        sdf_rect(
            vec3(p.x - 0.85, p.y + 0.45, abs(p.z) - 0.85),
            vec3(0.12, 1.55, 0.12)
        )
    );
    float sidebeamsS = sdf_rect(
        vec3(p.x - 0.05, p.y + 0.81, abs(p.z) - 0.85),
        vec3(0.84, 0.11, 0.11)
    );
    float sidebeamsB = sdf_rect(
        vec3(p.x - 0.835, p.y + 0.81, p.z - 0.0),
        vec3(0.1, 0.11, 0.9)
    );
    return vec4(
        min(base, min(legs, min(
            sidebeamsS,
            sidebeamsB
        ))) * 0.8,
        sidebeamsB,
        legs,
        sidebeamsS
    );
}
vec3 orbColor(vec3 od, float time) {
    time *= 0.3;
    od = rot_XZ_YZ(od, TWO_PI * cos(time), TWO_PI * sin(time));
    return vec3(
        0.25 * time + 0.5 + 0.3 * (sin(
            time + 3.0 * (cos(od.x) + sin(od.y) - cos(od.z))
        )),
        0.7,
        0.75
    );
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
        sdf_rect(p + vec3(0.0, -1.5, 15.0), vec3(5.0, 4.5, 10.0)),
        -sdf_rect(p + vec3(0.0, -1.5, 15.0 - rthk), vec3(5.0, 4.5, 10.0 + rthk) - rthk)
    );
    
    vec3 cd = p + vec3(0.0, 1.35, 15.0);
    float disc = sdf_cylinder(cd, 2.5, 0.05);
    vec3 ld = p + vec3(0, 2.15, 15.0);
    float legCount = 6.0;
    float a = 0.2 + mod(atan(ld.z, ld.x) + PI / legCount, PI / (0.5 * legCount)) - PI / legCount;
    float d = length(ld.xz);
    ld.xz = d * vec2(cos(a), sin(a));
    ld.x -= 2.0;
    float table_legs = mix(
        sdf_cylinder(ld, 0.15, 0.85),
        sdf_sphere(ld + vec3(0.0, 0.45, 0.0), 0.25),
        0.075
    );
    float table = min(disc, table_legs.x);
    
    vec3 od = p + vec3(0.0, 0.8, 15.0);
    float orb = sdf_sphere(od, 0.55);
    
    vec3 td = rot_XZ(cd, -PI / 2.0) + vec3(3.95, 0.35, -2.0);
    td /= 1.5;
    float handrest = sdf_cylinder(rot_YZ(td, PI / 2) + vec3(-0.5, 0.0, -0.6), 0.7, 1.7);
    float cbase = max(
        sdf_rect(td + vec3(0.0, 0.25, 0.0), vec3(0.53, 0.72, 1.5)),
        -sdf_rect(
            td + vec3(-0.2, -0.3, 0.0),
            1.085 * vec3(0.53, 0.6, 1.2)
        )
    );
    float couch = mix(
        max(cbase, -handrest),
        sdf_sphere(td, 2.0),
        0.02
    ); 
    float window = sdf_rect(
        p + vec3(-5.0, -1.5, 15.0),
        3.0 * vec3(0.1, 1.0, 1.0)
    );
    float windowLines = min(
        sdf_rect(
            p + vec3(-4.98, -1.5, 15.0),
            3.0 * vec3(0.01, 0.05, 1.2)
        ),
        sdf_rect(
            p + vec3(-4.98, -1.5, 15.0),
            3.0 * vec3(0.01, 1.2, 0.05)
        )
    );
    
    vec3 cord = vec3(
        p.x,
        p.y + 1.0,
        p.z + 15.0
    );
    cord = rot_XZ(cord, 0.7);
    cord.x = abs(cord.x) - 3.0;
    
    vec4 chair = chair(cord * vec3(1.2, 1.0, 1.2));
    
    float c = min(max(
        min(
            min(c1, c2),
            min(
                min(table, couch),
                min(orb, chair.x)
            )),
        -window
    ), windowLines);
    
    
    if(is_dist) {
        return vec3(c);
    }else{
        float I = 2.0 * MIN_DIST_THRESHOLD;
        
        if(c1 <= I)
            return vec3(0.0, 0.0, 0.2);
        if(disc <= I)
            return vec3(0.05, 0.3, 0.12 + 1.075 - pow(min(1.0, 3.4 - length(cd.xz)), 2.0));
        if(table_legs <= I)
            return vec3(0.05, 0.3, 0.15 + 0.05 * sin(cd.y));
        if(chair.w <= I)
            return vec3(0.05, 0.3, 0.25 + 0.03 * (
                sin(50.0 * (sum(cord.yz) + 0.1 * pow(0.9 * cos(2.0 * cord.x), 4.0)))
            ));
        if(chair.z <= I)
            return vec3(0.05, 0.3, 0.25 + 0.03 * (
                sin(50.0 * (sum(cord.xz) + 0.1 * pow(0.9 * cos(2.0 * cord.y), 4.0)))
            ));
        if(chair.y <= I)
            return vec3(0.05, 0.3, 0.25 + 0.03 * (
                sin(50.0 * (sum(cord.yx) + 0.1 * pow(0.9 * cos(2.0 * cord.z), 4.0)))
            ));
        if(chair.x <= I)
            return vec3(0.05, 0.3, 0.25 + 0.03 * (
                0.2 - pow(0.44 * (1.475 + sin(15.0 * (
                    sum(cord.xy) + 0.03 * sin(15.0 * cord.z + 15.0 * sin(2.0 * (cd.x * cd.x - cd.y)))
                ))), 3.5)
            ));
        if(orb <= I)
            return orbColor(od, time);
        if(couch <= I)
            return vec3(0.2, 0.35, 0.005*sin(100.0*sum(0.1*td+length(td.z+3.0*(td.xz)))) + 0.5 - clamp(0.5 * length((td - vec3(0.1,0.1,0.0)).xy), 0.02, 0.3));
        if(max(windowLines, window) <= I || (window - 0.2) <= I)
            return vec3(0.05, 0.4, 0.1 + 0.005 * sin(55.0 * (0.5 * p.y + p.z)));
        
        return vec3(0.0, 0.0, 0.25 + 0.0025 * sin(120.0 * (p.y - 0.1 * sum(p.xz))));
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
    
    vec3 clr = 0.8 * vec3(0.2, 0.8, 1.0);
    
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
        vec3 orbLoc = vec3(0.0, 0.8, 15.0);
        float orbDist = sdf_sphere(ray + orbLoc, 0.55);
        float orbPower = clamp(
            pow(
                max(
                    0.0,
                    1.2 - 0.5 * dist(
                        ray, -orbLoc
                    )
            ), 3.0),
            0.0,
            0.3
        );
        
        vec3 dat = f(
            ray + MIN_DIST_THRESHOLD * ray_step,
            false
        );
        float len = dist(ray, cast_s);
        vec3 lightSource = vec3(120.0, 30.0, -6.0);
        vec3 lightLoc = raymarch(
            lightSource,
            normalize(ray - lightSource),
            MAX_ITTERS - 100,
            vec2(
                MIN_DIST_THRESHOLD,
                MAX_DIST_THRESHOLD
            )
        );
        
        clr = hsv2rgb(dat) * max(
            0.35,
            1.0 - max(
                0.0,
                dist(ray, cast_s) / 20.0 - 0.5
            )
        );
            
        if(orbDist >= 0.001) {
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
                ) + orbPower;
            }else{
                clr *= 0.65 + orbPower;
            }
            
            clr += orbPower * hsv2rgb(orbColor(
                normalize(
                    ray - orbLoc
                ) * orbDist,
                u_time
            ));
        }
        
        
    }else{
        clr *= dist(vec3(50.0, 25.0, 0.0), vec3(cast_s)) * 0.016;
    }
    
    gl_FragColor = vec4(clr, 1.0);
}