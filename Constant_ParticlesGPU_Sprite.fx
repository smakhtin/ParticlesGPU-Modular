//@author: alg
//@description: Draws a Constant ParticlesGPU Sprites mesh using the DataTexture
//@tags: particles sprites
//@credits: dottore, Viktor Vicsek for Sprites Function

float4x4 tV: VIEW;
float4x4 tVP: VIEWPROJECTION;
float4x4 tVI : VIEWINVERSE;
 
StructuredBuffer<float> Radius;
StructuredBuffer<float3> TranslateXYZ;

Texture2D Texture;
float4 Color <bool color=true;> = 1;

float3 g_positions[4]:IMMUTABLE =
    {
        float3( -1, 1, 0 ),
        float3( 1, 1, 0 ),
        float3( -1, -1, 0 ),
        float3( 1, -1, 0 ),
    };

float2 g_texcoords[4]:IMMUTABLE = 
    { 
        float2(0,1), 
        float2(1,1),
        float2(0,0),
        float2(1,0),
    };

SamplerState textureSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

struct VS_IN
{
    uint id : SV_VertexID;  
};

struct vs2gs
{
    float4 Pos : POSITION ;
};

struct gs2ps
{
    float4 PosWVP : SV_POSITION ;
    float2 TexCd : TEXCOORD0;
};

vs2gs VS(VS_IN input)
{
    vs2gs Out = (vs2gs)0;
    float3 position = TranslateXYZ[input.id];
    Out.Pos = float4(position, Radius[input.id]);
    return Out;
}

[maxvertexcount(4)]
void GS(point vs2gs input[1], inout TriangleStream<gs2ps> SpriteStream)
{
    gs2ps output;
    
    //
    // Emit two new triangles
    //
    for(int i=0; i<4; i++)
    {
        float4 p = input[0].Pos;    
        float3 position = g_positions[i].xyz * p.w;
        position = mul( position, (float3x3)tVI ) + p.xyz;
        
        float3 norm = mul(float3(0,0,-1),(float3x3)tVI );
        output.PosWVP = mul( float4(position,1.0), tVP );
        
        output.TexCd = g_texcoords[i];
        SpriteStream.Append(output);
    }
    SpriteStream.RestartStrip();
}

float4 PS_Tex(gs2ps In): SV_Target
{
    float4 col = Texture.Sample( textureSampler, In.TexCd) * Color;
    //if (col.r < 0.5f) { discard; }
    return col;
}

technique10 Main
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
        SetGeometryShader( CompileShader( gs_4_0, GS() ) );
        SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
    }
}