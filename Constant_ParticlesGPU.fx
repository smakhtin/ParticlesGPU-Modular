//@author: alg
//@description: Draws a Constant ParticlesGPU Sprites mesh using the DataTexture
//@tags: particles sprites
//@credits: dottore

// -----------------------------------------------------------------------------
// !!!TYPES INCLUDE BEGIN 
// -----------------------------------------------------------------------------
float4x4 tW: WORLD ;
float4x4 tV: VIEW ;
float4x4 tVP: VIEWPROJECTION ;
float4x4 tWV: WORLDVIEW ;
float4x4 tWVP: WORLDVIEWPROJECTION ;

struct vs2ps
{
    float4 PosW: TEXCOORD0 ;
    float3 PosWV : TEXCOORD1 ;
    float4 PosWVP: POSITION ;
    
    float3 NormWV: NORMAL ;
    
    float2 TexCdShadow : TEXCOORD2 ;
    float3 LightDirWV: TEXCOORD3 ;
    float3 ViewDirWV: TEXCOORD4 ;
    float2 TexCd: TEXCOORD5 ;
};

// -----------------------------------------------------------------------------
// MRE OUTPUT STRUCT:
// -----------------------------------------------------------------------------
struct mrtOut
{
    float4 color : COLOR0;
    float4 space : COLOR1;
    float4 normal : COLOR2;
    float4 velocity : COLOR3;
};

float GI <String uiname="Global Illumination Amount";> = 1;

// -----------------------------------------------------------------------------
// !!!TYPES INCLUDE END 
// -----------------------------------------------------------------------------

bool EnableTile = false;
float TileSize = 16.0;

texture TranslateTileIndexTex <string uiname="TranslateXYZ (XYZ), Tile Index (W)";>;
sampler TranslateTileIndexSamp = sampler_state
{
    Texture   = (TranslateTileIndexTex);          
    MipFilter = none;                    
    MinFilter = none;
    MagFilter = none;
};

texture ScaleTex <string uiname="ScaleXYZ (XYZ)";>;
sampler ScaleSamp = sampler_state
{
    Texture   = (ScaleTex);          
    MipFilter = none;                    
    MinFilter = none;
    MagFilter = none;
};

texture Texture <string uiname="Texture";>;
sampler Samp = sampler_state
{
    Texture   = (Texture);          
    MipFilter = LINEAR;        
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float4 Color : COLOR = 1;

vs2ps VS(
    float4 PosO : POSITION,
    float3 NormO : NORMAL,
	float4 TransformTexCd : TEXCOORD0,
    float4 TextureTexCd : TEXCOORD1)
{
    vs2ps Out = (vs2ps)0;
    
    float4 translateTileIndex = tex2Dlod(TranslateTileIndexSamp, TransformTexCd);
    float3 scale =  tex2Dlod(ScaleSamp, TransformTexCd);

    //PosO = mul(PosO, tW);

    //Apply scale
    PosO.xyz *= scale.xyz;
    
    //Apply rotation
    //PosO.xyz  += particleTransform.xyz;
    
    //Apply translate
    PosO.xyz += translateTileIndex.xyz;
    NormO.xyz += translateTileIndex.xyz;

    Out.PosWV = mul(PosO, tWV);
    Out.PosWVP = mul(PosO, tWVP);

    Out.NormWV = mul(NormO, tWV);
    
	if(EnableTile)
	{
		TextureTexCd.xy /= TileSize;
    	TextureTexCd.xy += float2((translateTileIndex.w%TileSize)/TileSize,floor(translateTileIndex.w/TileSize)/TileSize);
	}
	
	Out.TexCd = TextureTexCd;
	
	return Out;
}

float4 MAIN_PS(vs2ps In): COLOR
{
    mrtOut Out = (mrtOut)0;

    Out.color = tex2D(Samp, In.TexCd) * Color;

    Out.space.xyz = In.PosWV;
    Out.space.w = 1.0f;

    Out.normal = float4(normalize(In.NormWV.xyz),GI);

    return c;
}

technique Main
{
	pass P0
    {
        ALPHABLENDENABLE = FALSE;
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 MAIN_PS();
	}
}