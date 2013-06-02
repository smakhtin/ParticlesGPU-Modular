StructuredBuffer<float4> Input;

RWStructuredBuffer<float4> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{	
	uint count,dummy;	
	Input.GetDimensions(count,dummy);
	
	Output[DTid.x] = Input[DTid.x % count];
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}