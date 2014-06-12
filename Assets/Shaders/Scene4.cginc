
float DE4(float3 p)
{

    float h = 1.0;
    float rh = 0.5;
    float2 grid = float2(1.2, 0.8);
    float2 grid_half = grid*0.5;
    float radius = 0.35;
    float3 orig = p;

    p.y = -abs(p.y);

    float2 g1 = float2(ceil(orig.xz/grid));
    float2 g2 = float2(ceil((orig.xz+grid_half)/grid));
    float3 rxz =  nrand3(g1);
    float3 ryz =  nrand3(g2);

    float d1 = p.y + h + rxz.x*rh;
    float d2 = p.y + h + ryz.y*rh;

    float2 p1 = modc(p.xz, grid) - grid_half;
    float c1 = sdHexPrism(float2(p1.x,p1.y), float2(radius,radius));

    float2 p2 = modc(p.xz+grid_half, grid) - float2(grid_half);
    float c2 = sdHexPrism(float2(p2.x,p2.y), float2(radius,radius));

    float dz = (grid.y*g1.y - p.z + 0.1)*0.5;
    float dz1 = -(abs(p.y)-h)+0.1;

    return min(min(max(c1,d1), max(c2,d2)), max(dz,dz1));
}

float3 GenNormal4(float3 p)
{
    const float d = 0.01;
    return normalize( float3(
        DE4(p+float3(  d,0.0,0.0))-DE4(p+float3( -d,0.0,0.0)),
        DE4(p+float3(0.0,  d,0.0))-DE4(p+float3(0.0, -d,0.0)),
        DE4(p+float3(0.0,0.0,  d))-DE4(p+float3(0.0,0.0, -d)) ));
}

float4 Scene4(float2 pos)
{
    float time = _Time.x * 30.0;
    float aspect = _ScreenParams.x / _ScreenParams.y;
    float2 screen_pos = (pos+float2(1.0,1.0)) * 0.5 * _ScreenParams.xy;
    pos.x *= aspect;


    float3 camPos = float3(-0.5,0.0,3.0);
    float3 camDir = normalize(float3(0.8, 0.0, -1.0));
    camPos -=  float3(time*0.2,0.0,time*1.0);
    float3 camUp  = normalize(float3(0.00, 1.0, 0.0));
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
        d = DE4(ray);
        march=mi;
        total_d += d;
        ray += rayDir * d;
        if(d<0.001) {break; }
	prev_d = d;
    }

    float glow = 0.0;
    
    float sn = 0.0;
    {
        const float s = 0.001;
        float3 p = ray;
        float3 n1 = GenNormal4(ray);
        float3 n2 = GenNormal4(ray+float3(s, 0.0, s));
        float3 n3 = GenNormal4(ray+float3(0.0, s, 0.0));
        glow = max(1.0-abs(dot(camDir, n1)-0.5), 0.0)*0.5;
        if(dot(n1, n2)<0.999 || dot(n1, n3)<0.999) {
            sn += 1.0;
        }
    }
    {
        float3 p = ray;
        float grid1 = max(0.0, max((modc((p.x+p.y+p.z*2.0)-time*3.0, 5.0)-4.0)*1.5, 0.0) );
        float grid2 = max(0.0, max((modc((p.x+p.y*2.0+p.z)-time*2.0, 7.0)-6.0)*1.2, 0.0) );
        sn = sn*0.2 + sn*(grid1+grid2)*1.0;
    }
    glow += sn;

    float fog = min(1.0, (1.0 / float(MAX_MARCH)) * float(march))*1.0;
    float3  fog2 = 0.005 * float3(1, 1, 1.5) * total_d;
    glow *= min(1.0, 4.0-(4.0 / float(MAX_MARCH-1)) * float(march));
    float scanline = modc(screen_pos.y, 4.0) < 2.0 ? 0.7 : 1.0;
    return float4(float3(0.15+glow*0.75, 0.15+glow*0.75, 0.2+glow)*fog + fog2, 1.0) * scanline;
}
