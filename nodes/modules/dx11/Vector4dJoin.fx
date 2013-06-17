StructuredBuffer<float> X;
StructuredBuffer<float> Y;
StructuredBuffer<float> Z;
StructuredBuffer<float> W;

RWStructuredBuffer<float4> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{	
	uint countX, dummyX;
	X.GetDimensions(countX, dummyX);

	uint countY, dummyY;
	Y.GetDimensions(countY, dummyY);

	uint countZ, dummyZ;	
	Z.GetDimensions(countZ, dummyZ);

	uint countW, dummyW;	
	W.GetDimensions(countW, dummyW);

	Output[DTid.x] = float4(X[DTid.x % countX], Y[DTid.x % countY], Z[DTid.x % countZ], W[DTid.x % countW]);
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}