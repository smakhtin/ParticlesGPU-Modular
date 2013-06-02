#include "Pixel.fxh"

StructuredBuffer<pixel> Input;

RWStructuredBuffer<pixel> Output : BACKBUFFER;

[numthreads(1, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{	
	Output[DTid.x] = Input[DTid.x];
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}