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

	Pos.xyz *= 2;
	
	Out.Pos = Pos;
    //Out.Pos = mul(Pos, tWVP);

    Out.TexCd = TexCd;

    return Out;
}

float4 PS(vs2ps In): COLOR
{
    float4 col = tex2D(MainSamp, In.TexCd);
	
    return col;
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