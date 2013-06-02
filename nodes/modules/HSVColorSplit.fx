StructuredBuffer<float4> RGBA;

RWStructuredBuffer<float4> Output : BACKBUFFER;

float RGBCVtoHUE(in float3 rgb, in float c, in float v)
{
  float3 delta = (v - rgb) / c;
  delta.rgb -= delta.brg;
  delta.rgb += float3(2,4,6);
  delta.brg = step(v, rgb) * delta.brg;
  float h;
  h = max(delta.r, max(delta.g, delta.b));
  return frac(h / 6);
}

float3 RGBtoHSV(in float3 rgb)
{
    float3 hsv = 0;
    hsv.z = max(rgb.r, max(rgb.g, rgb.b));
    float m = min(rgb.r, min(rgb.g, rgb.b));
    float c = hsv.z - m;

    if (c != 0)
    {
        hsv.x = RGBCVtoHUE(rgb, c, hsv.z);
        hsv.y = c / hsv.z;
    }
    return hsv;
}

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{   
    float3 hsv = RGBtoHSV(float3(RGBA[DTid.x].r, RGBA[DTid.x].g, RGBA[DTid.x].b));

    Output[DTid.x] = float4(hsv, RGBA[DTid.x].a);
}

technique11 Main
{
    pass P0
    {
        SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
    }
}