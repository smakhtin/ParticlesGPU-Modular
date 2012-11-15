//@author: alg
//@help: Generate Perlin noise
//@tags: particles
//@credits: dottore

float4x4 tWVP: WORLDVIEWPROJECTION;

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

float4 BaseValue;

float4 MAIN_PS(vs2ps In): COLOR
{
    return noise(BaseValue);
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