StructuredBuffer<float> X;
StructuredBuffer<float> Y;
StructuredBuffer<float> Z;
StructuredBuffer<float> W;

RWStructuredBuffer<float4> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{		
	Output[DTid.x] = float4(X[DTid.x], Y[DTid.x], Z[DTid.x], W[DTid.x]);
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}