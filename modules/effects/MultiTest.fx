//@author: vvvv group
//@help: draws a mesh with a constant color
//@tags: template, basic
//@credits:

float4x4 tWVP: WORLDVIEWPROJECTION;

texture MainTex <string uiname="Texture";>;
sampler MainSamp = sampler_state
{
    Texture   = (MainTex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture SecondTex <string uiname="Second Texture";>;
sampler SecondSamp = sampler_state
{
    Texture   = (SecondTex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
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

struct MultiColor
{
	float4 first : COLOR0;
    float4 second : COLOR1;
};

MultiColor PS(vs2ps In)
{
	MultiColor Out = (MultiColor)0;
	
    float4 col = tex2D(MainSamp, In.TexCd);
	float4 col2 = tex2D(SecondSamp, In.TexCd);
	
	Out.first = col;
	Out.second = col2;
    return Out;
}

technique TConstant
{
    pass P0
    {
        VertexShader = compile vs_2_0 VS();
        PixelShader = compile ps_2_0 PS();
    	AlphaBlendEnable = false;
    }
}