#define MAX_STEPS 24

uniform lowp vec4 fColor;
uniform lowp sampler2D fTexture;
varying highp vec2 fTexCoord;

uniform vec2 fResolution;

uniform vec2 rectPos;
uniform vec2 rectSize;

vec2 lightPosition;

varying vec2 v_texcoord;

float distCube(vec2 p, vec2 size)
{
    return length(max(abs(p)-size,0.0));
}


float distCircle(vec2 p, float r)
{
    return max(0.0,length(p)-r);
}

float distLight(vec2 p)
{
    return distCircle(p-lightPosition,0.01);
}

float distW(vec2 pos, vec2 size){
    float v = 10000.0;
	// rect distance:
    v = min(v,distCube(pos,size));
	// circle distance:
    //v = min(v, distCircle(pos, size.x));
    return v;
}

float getDistance(vec2 pt)
{
    vec2 dir = normalize(lightPosition-pt);
    vec2 pos = pt;
    float depth = 0.5;
    vec2 size = rectSize / 2.0 / fResolution;
    for (int i = 0; i < MAX_STEPS; i++){
        float dw = distW(pos - rectPos / fResolution - size, size);
        float dl = distLight(pos);
        float d = min(dw,dl);
        if (dw < 0.001)
            return 1.0;
        else if (dl < 0.001)
            return 0.0;        
        depth += d;
        pos += dir*d;
    }
    
    return 1.0;
}

void main(void)
{
	lightPosition = vec2(0.5);
    
    float d = getDistance(fTexCoord) * 2.0;
	gl_FragColor = vec4(vec3(0.0)*d,d);
}