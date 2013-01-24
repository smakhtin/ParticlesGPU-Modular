//@author: alg
//@help: Replace Input 1 data by data from Input 2 channel by channel
//@tags: particles
//@credits: dottore

#include "TextureProcessor.fxh"

bool4 ReplaceXYZW = (true, true, true, true);

texture ReplaceTex <string uiname="Input 2 (XYZW)";>;
sampler ReplaceSamp = sampler_state
{
    Texture   = (ReplaceTex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float4 MAIN_PS(vs2ps In): COLOR
{
    float4 input = tex2D(InputSamp, In.TexCd);
	
	float4 replace = tex2D(ReplaceSamp, In.TexCd);
	
	if(ReplaceXYZW.r == true)
	{
		input.r = replace.r;
	}
	
	if(ReplaceXYZW.g == true)
	{
		input.g = replace.g;
	}
	
	if(ReplaceXYZW.b == true)
	{
		input.b = replace.b;
	}
	
	if(ReplaceXYZW.a == true)
	{
		input.a = replace.a;
	}
	
    return input;
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