StructuredBuffer<float4> Input;
float MinLength = 0;

AppendStructuredBuffer<float4> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{	
	float value = length(Input[DTid.x]);
	if(value > MinLength) Output.Append(Input[DTid.x]);
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}