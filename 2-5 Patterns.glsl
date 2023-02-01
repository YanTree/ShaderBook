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
    vec2 row = _st;
    vec2 colum = _st;

    // Here is where the offset is happening
    // _st.x += step(1., mod(_st.y,2.0)) * 0.5;

    // Odd rows move to right, even rows move to left
    //row.x += step(1., mod(_st.y,2.0)) * -u_time; // odd row
    //row.x += (1.0 - step(1., mod(_st.y,2.0))) * u_time; // odd row

    // Odd colum move to up, even colum move to down
    //colum.y += step(1.0, mod(_st.x, 2.0)) * -u_time; // odd colmn
    //colum.y += (1.0 - step(1.0, mod(_st.x, 2.0))) * u_time; // odd colmn

    // mix row animation and colum animation
    //_st = mix(row, colum, step(0.0, sin(u_time)));
    //vec2 st = vec2(1.0 - _st.x, _st.y) * -u_time;
    // float st = mix(-u_time, u_time, _st.x);
    // _st.x = mix(_st.x, u_time, st);
    //    _st.x += mix(_st.x, -u_time, st);

    return fract(_st);
}

float circleDraw(in vec2 _st, in float _radius){
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

float boxDraw(in vec2 _st, in vec2 _size){
    _size = vec2(0.5) - _size*0.5;
    vec2 uv = smoothstep(_size,
                        _size+vec2(0.0001),
                        _st);
    uv *= smoothstep(_size,
                    _size+vec2(0.0001),
                    vec2(1.0)-_st);
    return uv.x*uv.y;
}

float boxDraw(vec2 _st, vec2 _size, float _smoothEdges){
    _size = vec2(0.5)-_size*0.5;
    vec2 aa = vec2(_smoothEdges*0.5);
    vec2 uv = smoothstep(_size,_size+aa,_st);
    uv *= smoothstep(_size,_size+aa,vec2(1.0)-_st);
    return uv.x*uv.y;
}

float crossDraw(in vec2 _st, float _size){
    return  boxDraw(_st, vec2(_size,_size/4.)) +
            boxDraw(_st, vec2(_size/4.,_size));
}

vec2 inverselerp(vec2 a, vec2 b, vec2 t){
     return clamp(t-a / (b - a), 0.0, 1.0);
}

vec2 tilingUV(in vec2 st, in vec2 size){
    vec2 tmp = st * size;
    return fract(tmp);
}

float pickTile(in vec2 st, in vec2 size, in vec2 pos)
{
    vec2 tmp = st * size;
    vec2 point = step(tmp, pos) - step(tmp, pos - vec2(1.0));
    return point.x * point.y;
}

float singletile(in vec2 cr, in vec2 st, in vec2 divide){
    vec2 pos = step((cr + vec2(1.0)) / divide, st);
    pos -= step(cr / divide, st);
    return pos.x * pos.y;
}

vec2 rotate_tile_pattern(vec2 _st)
{
    _st *= 2.0;

    float index = 0.0;
    index += step(1.0, mod(_st.x, 2.0));
    index += step(1.0, mod(_st.y, 2.0)) * 2.0;

    _st = fract(_st);

        // Rotate each cell according to the index
    if(index == 1.0){
        //  Rotate cell 1 by 90 degrees
        _st = rotate2d_center(_st,PI*0.5);
    } else if(index == 2.0){
        //  Rotate cell 2 by -90 degrees
        _st = rotate2d_center(_st,PI*-0.5);
    } else if(index == 3.0){
        //  Rotate cell 3 by 180 degrees
        _st = rotate2d_center(_st,PI);
    }
    return _st;
}

void main() {
	vec2 st = gl_FragCoord.xy/u_resolution;
    vec3 color = vec3(0.0);
    vec2 size = vec2(3.0);

    // st *= size;      // Scale up the space by 3
    // st = fract(st); // Wrap around 1.0

    // Circle Shape
    vec2 circleUV = tilingUV(st, size);
    float circle = circleDraw(circleUV, 0.5);

    // X Shape
    vec2 crossUV = tilingUV(st, size);
    crossUV = rotate2d_center(crossUV, PI / 4.0);
    float cross = crossDraw(crossUV, 4.0);

    // mask
    float mask = pickTile(st, size, vec2(1, 1));
    mask += pickTile(st, size, vec2(2, 2));
    mask += pickTile(st, size, vec2(3, 3));

    color = vec3(mix(cross, circle, mask));

    //gl_FragColor = vec4(color, 1.0);


    //
    /// Apply matrices inside patterns

    vec2 ip = st;
    ip = tilingUV(st, vec2(9.0));

    ip = rotate2d_center(ip, PI * 0.25);
    color = vec3(boxDraw(ip, vec2(.3), 0.01));

    //vec2 st1 = tiling(st, vec2(10));
    //st1 -= vec2(0.5);
    //st1 *= 2.0; // map [0, 0.5] -> [0, 1]
    //st1 = abs(st1) - 0.02;
    //float value = min(st1.x, st1.y);

    //color = vec3(st1, 0.0);
    //color = vec3(step(.01, value));

    gl_FragColor = vec4(color, 1.0);

    // animation color
    // gl_FragColor = vec4(color.rg, sin(u_time), 1.0);

    // gl_FragColor = vec4(color.rg, sin(u_time), 1.0);


    //
    /// Offset patterns
    
    // Modern metric brick of 215mm x 102.5mm x 65mm
    // http://www.jaharrison.me.uk/Brickwork/Sizes.html
    // ip = st / vec2(2.15,0.65)/1.5;

    ip = brickTile(st, 5.0);              // tilling happen
    color = vec3(boxDraw(ip, vec2(0.9))); // offset happen
    // color = vec3(ip, 0.0);             // coordiantes


    //
    /// Truchet Tiles

    ip = brickTile(st, 6.0);
    ip = rotate_tile_pattern(ip);
    ip = rotate2d_center(ip, -PI * u_time * 0.25);
    color = mix(vec3(0, 0, 0), vec3(1, 1, 1), step(1.0, ip.y / ip.x));

	gl_FragColor = vec4(color, 1.0);
    //gl_FragColor = vec4(circle_mask, circle_mask, circle_mask, 1.0);
}