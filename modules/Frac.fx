//@author: alg
//@help: Returns a fractional part of input
//@tags: particles
//@credits: dottore

#include "TextureProcessor.fxh"

float4 MAIN_PS(vs2ps In): COLOR
{
    float4 input = tex2D(InputSamp, In.TexCd);
	
    return frac(input);
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