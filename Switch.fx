//@author: alg
//@help: Switch between 2 textures
//@tags: particles
//@credits:

#include "TextureProcessor.fxh"

texture SecondTex <string uiname="Input 2 (XYZW)";>;
sampler SecondSamp = sampler_state
{
    Texture   = (SecondTex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

bool Switch = false;

float4 MAIN_PS(vs2ps In): COLOR
{
    float4 input = tex2D(InputSamp, In.TexCd);
	float4 secondInput = tex2D(SecondSamp, In.TexCd);
	
	if(!Switch)
	{
		return input;
	}
	else
	{
		return secondInput;
	}
}

technique Main
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 MAIN_PS();
    	AlphaBlendEnable = false;
    }
}