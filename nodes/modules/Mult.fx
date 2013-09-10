//@author: alg
//@help: Multiply first value by the second one
//@tags: particles
//@credits: dottore

#include "TextureProcessor.fxh"

texture MultTex <string uiname="Input 2 (XYZW)";>;
sampler MultSamp = sampler_state
{
    Texture   = (MultTex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float4 MAIN_PS(vs2ps In): COLOR
{
    float4 input = tex2D(InputSamp, In.TexCd);
	
	float4 mult = tex2D(MultSamp, In.TexCd);
	
    return input * mult;
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