//@author: alg
//@help: Generate random number by seed
//@tags: particles

#include "TextureProcessor.fxh"

int Seed = 1;

float rand_1_05(float2 uv)
{
    float2 noise = (frac(sin(dot(uv ,float2(12.9898,78.233)*2.0)) * 43758.5453));
    return abs(noise.x + noise.y) * 0.5;
}

float4 MAIN_PS(vs2ps In): COLOR
{	
	float3 c = tex2D(InputSamp, In.TexCd);
    return rand_1_05(In.TexCd.xy);
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique Main
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 MAIN_PS();
    	AlphaBlendEnable = false;
    }
}