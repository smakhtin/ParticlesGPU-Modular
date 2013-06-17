StructuredBuffer<float> Input1;
StructuredBuffer<float> Input2;

RWStructuredBuffer<float> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{		
	uint count1,dummy1;	
	Input1.GetDimensions(count1, dummy1);

	uint count2,dummy2;	
	Input2.GetDimensions(count2, dummy2);

	Output[DTid.x] = Input1[DTid.x % count1] + Input2[DTid.x % count2];
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}