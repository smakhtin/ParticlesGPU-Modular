//@author: alg
//@help: Resize texture with different interpolation techniques
//@tags: particles
//@credits:

#include "TextureProcessor.fxh"

texture PointTex <string uiname="Point (XYZW)";>;
sampler PointSamp = sampler_state
{
    Texture   = (PointTex);          
    MipFilter = POINT;         
    MinFilter = POINT;
    MagFilter = POINT;
};

texture NoneTex <string uiname="None (XYZW)";>;
sampler NoneSamp = sampler_state
{
    Texture   = (NoneTex);          
    MipFilter = NONE;         
    MinFilter = NONE;
    MagFilter = NONE;
};

int SelectedInterpolation = 0;

float4 INTERPOLATION_PS(vs2ps In): COLOR
{
    float4 linearInput = tex2D(InputSamp, In.TexCd);
	float4 pointInput = tex2D(PointSamp, In.TexCd);
	float4 noneInput = tex2D(NoneSamp, In.TexCd);
    
	if (SelectedInterpolation == 0)
	{
		return linearInput;
	}
	else if (SelectedInterpolation == 1)
	{
		return pointInput;
	}
	else
	{
		return noneInput;
	}
    
}

technique Interpolation
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 INTERPOLATION_PS();
    	AlphaBlendEnable = false;
    }
}