// Source: https://www.shadertoy.com/view/4dfXDn

#define MAX_STEPS 32

uniform vec2 fResolution;

uniform float LightRadius;
uniform float LightSmooth;

uniform int ShapeType;

uniform vec2 ObjectPos;
uniform vec2 RectSize;
uniform float RectRotation;
uniform float CircleRadius;

varying highp vec2 fTexCoord;

//////////////////////////////
// Rotation and translation //
//////////////////////////////

vec2 rotateCCW(vec2 p, float a)
{
	mat2 m = mat2(cos(a), sin(a), -sin(a), cos(a));
	return p * m;   
}


vec2 rotateCW(vec2 p, float a)
{
	mat2 m = mat2(cos(a), -sin(a), sin(a), cos(a));
	return p * m;
}


vec2 translate(vec2 p, vec2 t)
{
	return p - t;
}


//////////////////////////////
// Distance field functions //
//////////////////////////////

float pie(vec2 p, float angle)
{
	angle = radians(angle) / 2.0;
	vec2 n = vec2(cos(angle), sin(angle));
	return abs(p).x * n.x + p.y*n.y;
}


float circleDist(vec2 p, float radius)
{
	return length(p) - radius;
}


float triangleDist(vec2 p, float radius)
{
	return max( abs(p).x * 0.866025 + 
				p.y * 0.5, -p.y) 
				-radius * 0.5;
}


float triangleDist(vec2 p, float width, float height)
{
	vec2 n = normalize(vec2(height, width / 2.0));
	return max( abs(p).x*n.x + p.y*n.y - (height*n.y), -p.y);
}

float boxDist(vec2 p, vec2 size, float radius)
{
	size -= vec2(radius);
	vec2 d = abs(p) - size;
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - radius;
}

float lineDist(vec2 p, vec2 start, vec2 end, float width)
{
	vec2 dir = start - end;
	float lngth = length(dir);
	dir /= lngth;
	vec2 proj = max(0.0, min(lngth, dot((start - p), dir))) * dir;
	return length( (start - p) - proj ) - (width / 2.0);
}

////////////////////

float sceneDist(vec2 p)
{
	// rectangle
	if (ShapeType == 1) 
	{
		vec2 rsz = RectSize / 2.0;
		return boxDist(rotateCCW(translate(p, ObjectPos + rsz), RectRotation), rsz, 0.0);
	// circle
	} else
		return circleDist(translate(p, ObjectPos), CircleRadius);
}

float shadow(vec2 p, vec2 pos, float radius)
{
	vec2 dir = normalize(pos - p);
	float dl = length(p - pos);
	
	// fraction of light visible, starts at one radius (second half added in the end);
	float lf = radius * dl;
	
	// distance traveled
	float dt = 0.01;

	for (int i = 0; i < MAX_STEPS; ++i)
	{			   
		// distance to scene at current position
		float sd = sceneDist(p + dir * dt);
		
		// early out when this ray is guaranteed to be full shadow
		if (sd < -radius) return 0.0;
		
		// width of cone-overlap at light
		// 0 in center, so 50% overlap: add one radius outside of loop to get total coverage
		// should be '(sd / dt) * dl', but '*dl' outside of loop
		lf = min(lf, sd / dt);
		
		// move ahead
		dt += max(1.0, abs(sd));
		if (dt > dl) break;
	}

	// multiply by dl to get the real projected overlap (moved out of loop)
	// add one radius, before between -radius and + radius
	// normalize to 1 ( / 2*radius)
	lf = clamp((lf*dl + radius) / (2.0 * radius), 0.0, 1.0);
	lf = smoothstep(0.0, 1.0, lf);
	return lf;
}

vec4 drawLight(vec2 p, vec2 pos, float dist, float range, float radius)
{
	// distance to light
	float ld = length(p - pos);
	
	// out of range
	if (ld > range) return vec4(0.0);
	
	// shadow
	float shad = shadow(p, pos, radius);
	float source = clamp(-circleDist(p - pos, radius), 0.0, 1.0);
	return vec4(shad + source);
}

void main(void)
{
	vec2 p = fTexCoord * fResolution;
	float dist = sceneDist(p);	
	vec2 lightPos = fResolution / 2.0;	
	vec4 col = clamp(1.0-drawLight(p, lightPos, dist, LightRadius, LightSmooth), 0.0, 1.0);
	gl_FragColor = vec4(0.0, 0.0, 0.0, col.a);
}
