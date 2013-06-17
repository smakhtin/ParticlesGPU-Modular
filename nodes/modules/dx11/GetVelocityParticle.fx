#include "Particle.fxh"

StructuredBuffer<particle> Particle;

RWStructuredBuffer<float3> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{		
	Output[DTid.x] = Particle[DTid.x].vel;
}

technique11 Main
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
	}
}