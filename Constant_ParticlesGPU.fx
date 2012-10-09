//@author: alg
//@description: Draws a Constant ParticlesGPU Sprites mesh using the DataTexture
//@tags: particles sprites
//@credits: dottore, Viktor Vicsek for Sprites Function

float4x4 tW: WORLD;
float4x4 tV: VIEW;
float4x4 tP: PROJECTION;
float4x4 tVP: VIEWPROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

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

float4 Color :COLOR = 1;

struct vs2ps
{
    float4 Pos : POSITION;
    float4 TextureTexCd : TEXCOORD1;
};


vs2ps VS(
    float4 Pos : POSITION ,
	float4 TransformTexCd : TEXCOORD0,
    float4 TextureTexCd : TEXCOORD1)
{
    vs2ps Out = (vs2ps)0;
    
    float4 translateTileIndex = tex2Dlod(TranslateTileIndexSamp, TransformTexCd);
    float3 scale =  tex2Dlod(ScaleSamp, TransformTexCd);

    Pos = mul(Pos, tW);

    //Apply scale
    Pos.xyz *= scale.xyz;
    
    //Apply rotation
    //Pos.xyz  += particleTransform.xyz;
    
    //Apply translate
    Pos.xyz += translateTileIndex.xyz;

    Out.Pos = mul(Pos, tVP);
    
	if(EnableTile)
	{
		TextureTexCd.xy /= 16.;
    	TextureTexCd.xy += float2((translateTileIndex.w%16)/16.,floor(translateTileIndex.w/16.)/16.);
	}
	
	Out.TextureTexCd = TextureTexCd;
	
	return Out;
}

float4 MAIN_PS(vs2ps In): COLOR
{
    return tex2D(Samp, In.TextureTexCd) * Color;
}

technique Main
{
	pass P0
    {
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 MAIN_PS();
	}
}