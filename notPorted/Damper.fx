//@author: alg
//@help: Damping incoming values
//@tags: particles
//@credits: dottore, vvvv group, processing community
StructuredBuffer<float> Input;
RWStructuredBuffer<float> Output : BACKBUFFER;

float Power = 0.1;

[numthreads(64, 1, 1)]
void MainCS( uint3 DTid : SV_DispatchThreadID )
{       
    float current = Output[DTid.x];
    Output[DTid.x] += (Input[DTid.x] - current) * Power;
}

technique11 Main
{
    pass P0
    {
        SetComputeShader( CompileShader( cs_5_0, MainCS() ) );
    }
}