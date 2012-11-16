//@author: alg
//@help: Replace Input 1 data by data from Input 2 channel by channel
//@tags: particles
//@credits: dottore

float4x4 tWVP: WORLDVIEWPROJECTION;

float4 Low;
float4 High;
int RandomX;

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

#define RANDOM_IA 16807
#define RANDOM_IM 2147483647
#define RANDOM_AM (1.0f/float(RANDOM_IM))
#define RANDOM_IQ 127773
#define RANDOM_IR 2836
#define RANDOM_MASK 123459876



float random ()
{
    int k;
    float ans;
    
    RandomX = pow(RandomX, RANDOM_MASK);
    k = RandomX / RANDOM_IQ;
    RandomX = RANDOM_IA * (RandomX - k * RANDOM_IQ ) - RANDOM_IR * k;
    
    if ( RandomX < 0 ) 
        RandomX += RANDOM_IM;
    
    ans = RANDOM_AM * RandomX;
    RandomX = pow(RandomX, RANDOM_MASK);
    
    return ans;
}

float4 random ( float4 low, float4 high )
{
    float4 v = float4( random(), random(), random(), random() );
    return low * ( 1.0f - v ) + high * v;
}

float4 MAIN_PS(vs2ps In): COLOR
{	
    return random();
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