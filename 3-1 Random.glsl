// Shader Book - Random
// Repeat single shape

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359
#define TAU 6.28318530718

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

// 伪随机算法：参数不变时，生成的随机结果是固定的
float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

vec2 truchetPattern(in vec2 _st, in float _index){
    _index = fract(((_index-0.5)*2.0));
    if (_index > 0.75) {
        _st = vec2(1.0) - _st;
    } else if (_index > 0.5) {
        _st = vec2(1.0-_st.x,_st.y);
    } else if (_index > 0.25) {
        _st = 1.0-vec2(1.0-_st.x,_st.y);
    }
    return _st;
}

void main() {
	vec2 st = gl_FragCoord.xy / u_resolution;

	//
	/// Random

	// float rnd = random(st);


	//
	/// Chaos
	vec2 st_chao = st * 10.0;

	// animate
	// st_chao = (st_chao-vec2(5.0))*(abs(sin(u_time*0.2))*5.);
    // st_chao.x += u_time*3.0;

	// get the integer coords
	vec2 ipos = floor(st_chao);
	// get the fractional coords
	vec2 fpos = fract(st_chao);

	// Assign a random value based on the integer coord
	vec3 color = vec3(random(ipos));

	// Assign a random value based on the fractional coord
	// vec3 color = vec3(random(ipos));

	vec2 tile = truchetPattern(fpos, random(ipos));
	float color_01 = 0.0;

	// Maze
    color_01 = smoothstep(tile.x-0.1,tile.x,tile.y)-
            	smoothstep(tile.x,tile.x+0.1,tile.y);

    // Circles
    color_01 = (step(length(tile),0.6) -
            	step(length(tile),0.4) ) +
            	(step(length(tile-vec2(1.)),0.6) -
            	step(length(tile-vec2(1.)),0.4) );

    // Truchet (2 triangles)
    color_01 = step(tile.x,tile.y);

	gl_FragColor = vec4(vec3(color_01), 1.0);
}