

float sdBox( float3 p, float3 b )
{
  float3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdBox( float2 p, float2 b )
{
  float2 d = abs(p) - b;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdCross( in float3 p )
{
    float da = sdBox(p.xy,float2(1.0,1.0));
    float db = sdBox(p.yz,float2(1.0,1.0));
    float dc = sdBox(p.zx,float2(1.0,1.0));
    return min(da,min(db,dc));
}

float sdHexPrism( float2 p, float2 h )
{
    float2 q = abs(p);
    return max(q.x-h.y,max(q.x+q.y*0.57735,q.y*1.1547)-h.x);
}

float3 nrand3( float2 co )
{
	float3 a = fract( cos( co.x*8.3e-3 + co.y )*float3(1.3e5, 4.7e5, 2.9e5) );
	float3 b = fract( sin( co.x*0.3e-3 + co.y )*float3(8.1e5, 1.0e5, 0.1e5) );
	float3 c = mix(a, b, 0.5);
	return c;
}
