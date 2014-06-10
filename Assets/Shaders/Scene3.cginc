
float DE3(float3 p)
{
    float h = 1.2;
    float rh = 0.5;
    float grid = 0.4;
    float grid_half = grid*0.5;
    float cube = 0.175;
    float3 orig = p;

    float3 g1 = float3(ceil((orig.x)/grid), ceil((orig.y)/grid), ceil((orig.z)/grid));
    float3 rxz =  nrand3(g1.xz);
    float3 ryz =  nrand3(g1.yz);

    p = -abs(p);
    float3 di = ceil(p/4.8);
    p.y += di.x*1.0;
    p.x += -di.z*0.6 + di.y*1.2;
    p.xy = mod(p.xy, -4.8);
	
    float2 gap = float2(rxz.x*rh, ryz.y*rh);
    float d1 = p.y + h + gap.x;
    float d2 = p.x + h + gap.y;

    float2 p1 = mod(p.xz, float2(grid,grid)) - float2(grid_half,grid_half);
    float c1 = sdBox(p1,float2(cube,cube));

    float2 p2 = mod(p.yz, float2(grid,grid)) - float2(grid_half,grid_half);
    float c2 = sdBox(p2,float2(cube,cube));

    float dz = (grid*g1.z - p.z + 0.1);
    float dz1 = -sdBox(p.xy, float2(1.9, 0.9))+0.1;
    return min( max(max(c1,d1), max(c2,d2)), max(dz, dz1));
}

float3 GenNormal3(float3 p)
{
    const float d = 0.01;
    return normalize( float3(
        DE3(p+float3(  d,0.0,0.0))-DE3(p+float3( -d,0.0,0.0)),
        DE3(p+float3(0.0,  d,0.0))-DE3(p+float3(0.0, -d,0.0)),
        DE3(p+float3(0.0,0.0,  d))-DE3(p+float3(0.0,0.0, -d)) ));
}

float4 Scene3(float2 pos)
{
    float time = _Time.x * 30.0;
    float aspect = _ScreenParams.x / _ScreenParams.y;
    float2 screen_pos = (pos+float2(1.0,1.0)) * 0.5 * _ScreenParams.xy;
    pos.x *= aspect;


    float3 camPos = float3(-0.5,0.0,3.0);
    float3 camDir = normalize(float3(0.3, 0.0, -1.0));
    camPos -=  float3(0.0,0.0,time*3.0);
    float3 camUp  = normalize(float3(0.5, 1.0, 0.0));
    float3 camSide = cross(camDir, camUp);
    float focus = 1.8;

    float3 rayDir = normalize(camSide*pos.x + camUp*pos.y + camDir*focus);	    
    float3 ray = camPos;
    int march = 0;
    float d = 0.0;

    float prev_d = 0.0;
    float total_d = 0.0;
    const int MAX_MARCH = 64;
    for(int mi=0; mi<MAX_MARCH; ++mi) {
        d = DE3(ray);
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
        float3 n1 = GenNormal3(ray);
        float3 n2 = GenNormal3(ray+float3(s, 0.0, 0.0));
        float3 n3 = GenNormal3(ray+float3(0.0, s, 0.0));
        glow = max(1.0-abs(dot(camDir, n1)-0.5), 0.0)*0.5;
        if(dot(n1, n2)<0.8 || dot(n1, n3)<0.8) {
            glow += 0.6;
        }
    }
    {
	float3 p = ray;
        float grid1 = max(0.0, max((mod((p.x+p.y+p.z*2.0)-time*3.0, 5.0)-4.0)*1.5, 0.0) );
        float grid2 = max(0.0, max((mod((p.x+p.y*2.0+p.z)-time*2.0, 7.0)-6.0)*1.2, 0.0) );
        float3 gp1 = abs(mod(p, float3(0.24,0.24,0.24)));
        float3 gp2 = abs(mod(p, float3(0.32,0.32,0.32)));
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
    float scanline = mod(screen_pos.y, 4.0) < 2.0 ? 0.7 : 1.0;
    return float4(float3(0.15+glow*0.75, 0.15+glow*0.75, 0.2+glow)*fog + fog2, 1.0) * scanline;
}
