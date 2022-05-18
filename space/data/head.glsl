#ifdef GL_ES
precision mediump float;
#endif

varying vec4 vertTexCoord;
uniform vec2 u_resolution;
uniform float u_time;
uniform vec3 vp_loc;
uniform vec2 vp_ang;

float MIN_DIST_THRESHOLD = 0.001;
float MAX_DIST_THRESHOLD = 2500.0;
float DENSITY_THRESHOLD  = 0.99;
int   MAX_ITTERS         = 256;
int   MAX_BOUNCE_COUNT   = 12;
float MCR = 2.0 * MIN_DIST_THRESHOLD;
float TMCR = 2.0 * MCR;