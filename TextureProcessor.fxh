float4x4 tWVP: WORLDVIEWPROJECTION;

texture InputTex <string uiname="Input (XYZW)";>;
sampler InputSamp = sampler_state
{
    Texture   = (InputTex);          
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