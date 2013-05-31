#include "Pixel.fxh"

Texture2D texture2d <string uiname="Texture";>;
float2 Size;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

RWStructuredBuffer<pixel> Output : BACKBUFFER;

[numthreads(1, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{	
	float x = DTid.x % Size.x;
	float y = DTid.x / Size.x;
	y = y - frac(y);
	
	x /= (Size.x - 1);
	y /= (Size.y - 1);
	
	Output[DTid.x].color = texture2d.SampleLevel(g_samLinear, float2(x, y), 0, 0);
	Output[DTid.x].pos = float2(x, y);
	Output[DTid.x].index = DTid.x;
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}