StructuredBuffer<float> X;
StructuredBuffer<float> Y;
StructuredBuffer<float> Z;

RWStructuredBuffer<float3> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{	
	uint countX, dummyX;
	X.GetDimensions(countX, dummyX);

	uint countY, dummyY;
	Y.GetDimensions(countY, dummyY);

	uint countZ, dummyZ;	
	Z.GetDimensions(countZ, dummyZ);

	Output[DTid.x] = float3(X[DTid.x % countX], Y[DTid.x % countY], Z[DTid.x % countZ]);
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}