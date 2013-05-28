StructuredBuffer<float3> XYZ;

RWStructuredBuffer<float> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{		
	Output[DTid.x] = XYZ[DTid.x].z;
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}