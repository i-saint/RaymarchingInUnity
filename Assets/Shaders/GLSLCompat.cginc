float  mod(float  a, float  b) { return a - b * floor(a/b); }
float2 mod(float2 a, float2 b) { return a - b * floor(a/b); }
float3 mod(float3 a, float3 b) { return a - b * floor(a/b); }
float4 mod(float4 a, float4 b) { return a - b * floor(a/b); }

float  fract(float  a) { return frac(a); }
float2 fract(float2 a) { return frac(a); }
float3 fract(float3 a) { return frac(a); }
float4 fract(float4 a) { return frac(a); }

float  mix(float  a, float  b, float  c) { return lerp(a,b,c); }
float2 mix(float2 a, float2 b, float2 c) { return lerp(a,b,c); }
float3 mix(float3 a, float3 b, float3 c) { return lerp(a,b,c); }
float4 mix(float4 a, float4 b, float4 c) { return lerp(a,b,c); }
