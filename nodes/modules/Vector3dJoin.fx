StructuredBuffer<float> X;
StructuredBuffer<float> Y;
StructuredBuffer<float> Z;

RWStructuredBuffer<float3> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{		
	Output[DTid.x] = float3(X[DTid.x], Y[DTid.x], Z[DTid.x]);
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}