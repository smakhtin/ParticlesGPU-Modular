//@author: alg
//@help: Switch between 2 textures
//@tags: particles
//@credits:
StructuredBuffer<float> Input1;
StructuredBuffer<float> Input2;

RWStructuredBuffer<float> Output : BACKBUFFER;

bool Switch = false;

[numthreads(64, 1, 1)]
float4 MainCS(uint3 DTid : SV_DispatchThreadID)
{	
	if(!Switch)
	{
        Output[DTid.x] = Input1[DTid.x]
	}
	else
	{
		Output[DTid.x] = Input2[DTid.x]
	}
}

technique Main
{
    pass P0
    {
        SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
    }
}