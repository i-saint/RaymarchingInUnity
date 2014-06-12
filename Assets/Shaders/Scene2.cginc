// sin(radians(45.0));
#define sr 0.7071067811865475
// cos(radians(45.0));
#define cr 0.7071067811865475

float3x3 rotz = float3x3(
    cr, sr, 0,
    sr,-cr, 0,
     0,  0, 1 );
float3x3 roty = float3x3(
    cr, 0, sr,
     0, 1,  0,
   -sr, 0, cr );

#undef sr
#undef cr

float DE2(float3 p)
{
    float h = 1.4;
    float rh = 0.5;
    float grid = 0.4;
    float grid_half = grid*0.5;
    float cube = 0.175;
    float3 orig = p;

    float3 g = float3(ceil((orig.x)/grid), ceil((orig.y)/grid), ceil((orig.z)/grid));
    float3 rxz =  nrand3(g.xz);
    float3 ryz =  nrand3(g.yz);
    float3 rxz2 =  nrand3(g.xz+float2(0.0,1.0));
    float3 ryz2 =  nrand3(g.yz+float2(0.0,1.0));

    float d3 = p.y + h + rxz.x*rh;
    float d4 = p.y - h + rxz.y*rh;
    float d5 = p.x + h + ryz.x*rh;
    float d6 = p.x - h + ryz.y*rh;

    float2 p2 = modc(p.xz, float2(grid,grid)) - float2(grid_half,grid_half);
    float c1 = sdBox(p2,float2(cube,cube));
	//a
    float2 p3 = modc(p.yz, float2(grid,grid)) - float2(grid_half,grid_half);
    float c2 = sdBox(p3,float2(cube,cube));
	
	float dz = (grid*g.z - p.z + 0.1);
	
    return min(min(max(c1, min(d3,-d4)), max(c2, min(d5,-d6))), dz);
}

float3 GenNormal2(float3 p)
{
    const float d = 0.01;
    return normalize( float3(
        DE2(p+float3(  d,0.0,0.0))-DE2(p+float3( -d,0.0,0.0)),
        DE2(p+float3(0.0,  d,0.0))-DE2(p+float3(0.0, -d,0.0)),
        DE2(p+float3(0.0,0.0,  d))-DE2(p+float3(0.0,0.0, -d)) ));
}

float4 Scene2(float2 pos)
{
    float time = _Time.x * 30.0;
    float aspect = _ScreenParams.x / _ScreenParams.y;
    float2 screen_pos = (pos+float2(1.0,1.0)) * 0.5 * _ScreenParams.xy;
    pos.x *= aspect;


    float3 camPos = float3(-0.5,0.0,3.0);
    float3 camDir = normalize(float3(0.3, 0.0, -1.0));
    camPos -=  float3(0.0,0.0,time);
    float3 camUp  = normalize(float3(0.05, 1.0, 0.0));
    float3 camSide = cross(camDir, camUp);
    float focus = 1.0;

    float3 rayDir = normalize(camSide*pos.x + camUp*pos.y + camDir*focus);	    
    float3 ray = camPos;
    int march = 0;
    float d = 0.0;

    float prev_d = 0.0;
    float total_d = 0.0;
    const int MAX_MARCH = 64;
    for(int mi=0; mi<MAX_MARCH; ++mi) {
        d = DE2(ray);
        march=mi;
        total_d += d;
        ray += rayDir * d;
        if(d<0.001) {break; }
        prev_d = d;
    }

    float glow = 0.0;
    {
        const float s = 0.0075;
        float3 p = ray;
        float3 n1 = GenNormal2(ray);
        float3 n2 = GenNormal2(ray+float3(s, 0.0, 0.0));
        float3 n3 = GenNormal2(ray+float3(0.0, s, 0.0));
        glow = max(1.0-abs(dot(camDir, n1)-0.5), 0.0)*0.5;
        if(dot(n1, n2)<0.8 || dot(n1, n3)<0.8) {
            glow += 0.6;
        }
    }
    {
	float3 p = ray;
        float grid1 = max(0.0, max((modc((p.x+p.y+p.z*2.0)-time*3.0, 5.0)-4.0)*1.5, 0.0) );
        float grid2 = max(0.0, max((modc((p.x+p.y*2.0+p.z)-time*2.0, 7.0)-6.0)*1.2, 0.0) );
        float3 gp1 = abs(modc(p, float3(0.24,0.24,0.24)));
        float3 gp2 = abs(modc(p, float3(0.32,0.32,0.32)));
        if(gp1.x<0.23 && gp1.z<0.23) {
            grid1 = 0.0;
        }
        if(gp2.y<0.31 && gp2.z<0.31) {
            grid2 = 0.0;
        }
        glow += grid1+grid2;
    }

    float fog = min(1.0, (1.0 / float(MAX_MARCH)) * float(march))*1.0;
    float3  fog2 = 0.01 * float3(1, 1, 1.5) * total_d;
    glow *= min(1.0, 4.0-(4.0 / float(MAX_MARCH-1)) * float(march));
    float scanline = modc(screen_pos.y, 4.0) < 2.0 ? 0.7 : 1.0;
    return float4(float3(0.15+glow*0.75, 0.15+glow*0.75, 0.2+glow)*fog + fog2, 1.0) * scanline;
}
