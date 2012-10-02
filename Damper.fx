//@author: alg
//@help: Damping incoming values
//@tags: particles
//@credits: dottore, vvvv group, processing community

#include "TextureProcessor.fxh"

float Power = 0.1;

texture TargetTex <string uiname="Target Value";>;
sampler TargetSamp = sampler_state
{
    Texture   = (TargetTex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float4 LINEAR_PS(vs2ps In): COLOR
{
    float4 current = tex2D(InputSamp, In.TexCd);
	float4 target = tex2D(TargetSamp, In.TexCd);
	
	current += (target - current) * Power;
    return current;
}

technique Linear
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 LINEAR_PS();
    	AlphaBlendEnable = false;
    }
}