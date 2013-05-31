#include "Pixel.fxh"

StructuredBuffer<pixel> Input;
float MinLength = 0;

AppendStructuredBuffer<pixel> Output : BACKBUFFER;

[numthreads(1, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{	
	pixel data = Input[DTid.x];
	
	float valueLength = length(float2(data.color.x, data.color.y));
	if(valueLength >= MinLength) Output.Append(data);
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}