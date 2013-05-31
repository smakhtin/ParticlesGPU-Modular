Texture2D texture2d <string uiname="Texture";>;
float2 Size;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

RWStructuredBuffer<float4> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{	
	float x = DTid.x % Size.x;
	float y = DTid.x / Size.x;
	y = y - frac(y);
	
	x /= (Size.x - 1);
	y /= (Size.y - 1);
	
	Output[DTid.x] = texture2d.SampleLevel(g_samLinear, float2(x, y), 0, 0);
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}