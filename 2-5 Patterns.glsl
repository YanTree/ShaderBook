// Shader Book - Patterns
// Repeat single shape

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359
#define TAU 6.28318530718

uniform vec2 u_resolution;
uniform float u_time;

vec2 brickTile(vec2 _st, float _zoom){
    _st *= _zoom;

    // Here is where the offset is happening
    _st.x += step(1., mod(_st.y,2.0)) * 0.5;

    return fract(_st);
}

float circle(in vec2 _st, in float _radius){
    vec2 l = _st-vec2(0.5);
    return 1.-smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*0.01),
                         dot(l,l)*4.0);
}

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

vec2 rotate2d_center(vec2 st, float _angle){
    st -= vec2(0.5);
    st = mat2(cos(_angle),-sin(_angle),
            sin(_angle),cos(_angle)) * st;
    st += vec2(0.5);
    return st;
}

float box(in vec2 _st, in vec2 _size){
    _size = vec2(0.5) - _size*0.1;
    vec2 uv = smoothstep(_size,
                        _size+vec2(0.001),
                        _st);
    uv *= smoothstep(_size,
                    _size+vec2(0.001),
                    vec2(1.0)-_st);
    return uv.x*uv.y;
}

float box(vec2 _st, vec2 _size, float _smoothEdges){
    _size = vec2(0.5)-_size*0.5;
    vec2 aa = vec2(_smoothEdges*0.5);
    vec2 uv = smoothstep(_size,_size+aa,_st);
    uv *= smoothstep(_size,_size+aa,vec2(1.0)-_st);
    return uv.x*uv.y;
}

float cross(in vec2 _st, float _size){
    return  box(_st, vec2(_size,_size/4.)) +
            box(_st, vec2(_size/4.,_size));
}

vec2 inverselerp(vec2 a, vec2 b, vec2 t){
     return clamp(t-a / (b - a), 0.0, 1.0);
}

vec2 tiling(in vec2 st, in vec2 size){
    vec2 tmp = st * size;
    return fract(tmp);
}

float singletile(in vec2 cr, in vec2 st, in vec2 divide){
    vec2 pos = step((cr + vec2(1.0)) / divide, st);
    pos -= step(cr / divide, st);
    return pos.x * pos.y;
}

void main() {
	vec2 st = gl_FragCoord.xy/u_resolution;
    vec3 color = vec3(0.0);
    vec2 divide = vec2(3);
    vec2 cr = vec2(0.0, 0.0);

    //st *= vec2(5);      // Scale up the space by 3
    //st = fract(st); // Wrap around 1.0

    vec2 tile = tiling(st, divide);

    // Now we have 9 spaces that go from 0-1
    float cross_mask = singletile(cr, st, divide);
    cross_mask += singletile(cr + vec2(0.0, 2.0), st, divide);
    cross_mask += singletile(cr + vec2(1.0, 2.0), st, divide);
    cross_mask += singletile(cr + vec2(2.0, 0.0), st, divide);
    float circle_mask = 1.0 - cross_mask;

    color = vec3(tile,0.0);
    color = vec3(cross_mask, cross_mask, cross_mask);
    
    color = vec3(circle(tile,0.5)) * circle_mask;
    color += vec3(cross(rotate2d_center(tile, PI / 4.0), 3.0)) * cross_mask;


    //
    /// Apply matrices inside patterns

    vec2 ip = st;
    ip = tiling(st, vec2(4.0));

    ip = rotate2d_center(ip, PI * 0.25);
    color = vec3(box(ip, vec2(.7), 0.01));

    vec2 st1 = tiling(st, vec2(10));
    st1 -= vec2(0.5);
    st1 *= 2.0; // map [0, 0.5] -> [0, 1]
    st1 = abs(st1) - 0.02;
    float value = min(st1.x, st1.y);

    //color = vec3(st1, 0.0);
    color = vec3(step(.01, value));


    //
    /// Offset patterns

    vec2 st2 = brickTile(st, 5.0); // offset happen
    color = vec3(box(st2, vec2(1)));

	gl_FragColor = vec4(color,1.0);
}