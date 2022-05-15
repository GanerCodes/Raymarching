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