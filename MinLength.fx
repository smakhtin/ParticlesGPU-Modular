StructuredBuffer<float4> Input;
float MinLength = 0;

struct filterOutput
{
	float4 value;
	uint index;
};

AppendStructuredBuffer<filterOutput> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{	
	filterOutput outStruct = (filterOutput)0;
	outStruct.value = Input[DTid.x];
	outStruct.index = DTid.x;
	
	float value = length(Input[DTid.x]);
	if(value >= MinLength) Output.Append(outStruct);
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}