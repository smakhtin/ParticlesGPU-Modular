StructuredBuffer<float> H;
StructuredBuffer<float> S;
StructuredBuffer<float> V;
StructuredBuffer<float> A;

RWStructuredBuffer<float4> Output : BACKBUFFER;

float3 Hue(float hue)
{
    float r = abs(hue * 6 - 3) - 1;
    float g = 2 - abs(hue * 6 - 2);
    float b = 2 - abs(hue * 6 - 4);
    return saturate(float3(r, g, b));
}

float3 HSVtoRGB(in float3 hsv)
{
    return ((Hue(hsv.x) - 1) * hsv.y + 1) * hsv.z;
}

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{	
	float3 rgb = HSVtoRGB(float3(H[DTid.x], S[DTid.x], V[DTid.x]));

	Output[DTid.x] = float4(rgb, A[DTid.x]);
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}