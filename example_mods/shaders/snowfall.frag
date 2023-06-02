#pragma header

uniform int amount;
uniform float intensity;
uniform float time;

vec2 uv;

// it's broken right now, but I'll fix it later
vec2 rnd(float x) {
    return fract(sin(dot(vec2(x + 48., 38. / (x + 2.5)), vec2(13, 78))) * vec2(43758));
}

float drawCircle(vec2 center, float radius) {
    return 1.0 - smoothstep(0.0, radius, length(uv - center));
}

void main()
{
    uv = vec2(openfl_TextureCoordv.x * 2.0, openfl_TextureCoordv.y);
    // gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
    
    for(int i=0; i<amount; i++) {
        float j = float(i) * 2.0;
        float realIntensity = intensity * 1.0;
        float speed = (vec2(0.3)+rnd(cos(j))*vec2(0.7+0.5*cos(j/(float(amount)*0.25))));
        vec2 center = vec2(((0.5-uv.y)*realIntensity+rnd(j)+0.1*(cos(time+sin(j)))) * 2.0, mod(sin(j)+speed*(time*1.5*(0.1+realIntensity)), 1.0));
        gl_FragColor += vec4(0.45*drawCircle(center, 0.001+speed*(intensity/(0.2 / 1.5))*0.012));
    }
}