//@author: vvvv group
//@help: draws a mesh with a constant color
//@tags: template, basic
//@credits:

float4x4 tWVP: WORLDVIEWPROJECTION;

float DamperPower = 0.1;
float FieldPower = 0.1;
bool FieldEnabled = false;
float4x4 FieldTransform <string uiname="inverse (FieldTexture transform)";>;
float4x4 FieldRotate;

texture Tex <string uiname="Current Value";>;
sampler Samp = sampler_state
{
    Texture   = (Tex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture TargetTex <string uiname="Target Value";>;
sampler TargetSamp = sampler_state
{
    Texture   = (TargetTex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture FieldTex <string uiname="Field Texture";>;
sampler FieldSamp = sampler_state
{
    Texture   = (FieldTex);          
    MipFilter = POINT;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
	addressU = BORDER;
    addressV = BORDER;
    addressW = BORDER;
};

struct vs2ps
{
    float4 Pos : POSITION;
    float4 TexCd : TEXCOORD0;
};

vs2ps VS(
    float4 Pos : POSITION,
    float4 TexCd : TEXCOORD0)
{
    vs2ps Out = (vs2ps)0;

    Out.Pos = mul(Pos, tWVP);

    Out.TexCd = TexCd;

    return Out;
}

float4 PS(vs2ps In): COLOR
{
    float4 current = tex2D(Samp, In.TexCd);
	float4 target = tex2D(TargetSamp, In.TexCd);	
	
	float4 fieldValue = tex3D(FieldSamp, mul(float4(current.rgb,1), FieldTransform) + 0.5);
	//float4 fieldValue = tex2D(FieldSamp, In.TexCd);
	//float4 fieldValue = (1, 1, 1, 1);
	fieldValue = mul(fieldValue, FieldRotate);
	
	if(FieldEnabled)
	{
		current.rgb += fieldValue * FieldPower;
	}
	else{
		current += (target - current) * DamperPower;
	}
    
	return current;
}

technique TConstant
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
    	AlphaBlendEnable = false;
    }
}