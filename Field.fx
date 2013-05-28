//@author: alg
//@help: Applyes vector field to the set of points
//@tags: particles
//@credits: dottore

#include "TextureProcessor.fxh"

float Power = 0.1;
bool FieldEnabled = false;
float4x4 FieldTransform <string uiname="Inverse Field Transform";>;
float4x4 FieldRotate;

texture FieldTex <string uiname="Field (XYZ)";>;
sampler FieldSamp = sampler_state
{
    Texture   = (FieldTex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    addressU = BORDER;
    addressV = BORDER;
    addressW = BORDER;
};

float4 THREE_D_PS(vs2ps In): COLOR
{
    float4 input = tex2D(InputSamp, In.TexCd);
	
	float4 fieldValue = tex3D(FieldSamp, mul(float4(input.rgb,1), FieldTransform) + 0.5);
	
	fieldValue = mul(fieldValue, FieldRotate);
	
    if(FieldEnabled)
    {
        input.rgb += fieldValue * Power;
    }
    
	return input;
}

float4 TWO_D_PS(vs2ps In): COLOR
{
    float4 input = tex2D(InputSamp, In.TexCd);
    
    float2 fieldValue = tex2D(FieldSamp, mul(float4(input.xy,1,1), FieldTransform) + 0.5);
    fieldValue = mul(fieldValue, FieldRotate);
    
    if(FieldEnabled)
    {
        input.xy += fieldValue * Power;
    }
    
    return input;
}

technique Three_D
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 THREE_D_PS();
    	AlphaBlendEnable = false;
    }
}

technique Two_D
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 TWO_D_PS();
        AlphaBlendEnable = false;
    }
}