// Shader Book - Matrices
// Animate useing matrices

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359
#define TAU 6.28318530718

uniform vec2 u_resolution;
uniform float u_time;

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

mat2 scale(vec2 _scale){
    return mat2(_scale.x,0.0,
                0.0,_scale.y);
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

float cross(in vec2 _st, float _size){
    return  box(_st, vec2(_size,_size/4.)) +
            box(_st, vec2(_size/4.,_size));
}

void main(){
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    vec3 color = vec3(0.0);

    // To move the cross we move the space
    vec2 translate = vec2(cos(u_time), sin(u_time));
    translate = vec2(-sin(u_time));
    translate = vec2(floor(sin(u_time)), sin(u_time));
    translate = vec2(fract(cos(u_time)), sin(u_time));
    translate = vec2(st.x, -abs(cos(u_time)));
    //translate = vec2((cos(u_time) /2.), abs(sin(u_time)));
    vec2 t = st + translate*0.25;

    // Show the coordinates of the space on the background
    //color = vec3(st.x,st.y,0.0);

    // Add the shape on the foreground
    color += vec3(cross(t,0.05));


    // rotation
    vec2 r = st - vec2(0.5);
    r = rotate2d(sin(u_time) * PI) * t;
    r += vec2(0.5);

    color = vec3(cross(r, 0.4));


    // scale
    vec2 s = st - vec2(0.5);
    s = scale(vec2((sin(u_time) + 1.0))) * s;
    s += vec2(0.5);

    color = vec3(cross(s, 0.4));

    gl_FragColor = vec4(color,1.0);
}