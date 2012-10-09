//@author: alg
//@description: Draws a Constant ParticlesGPU Sprites mesh using the DataTexture
//@tags: particles sprites
//@credits: dottore, Viktor Vicsek for Sprites Function

float4x4 tW: WORLD;
float4x4 tV: VIEW;
float4x4 tP: PROJECTION;
float4x4 tVP: VIEWPROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

float2 ViewportSize;
float TileSize = 16.0;

texture TranslateScaleTex <string uiname="TranslateXYZ (XYZ), UniformScale (W)";>;
sampler TranslateScaleSamp = sampler_state
{
    Texture   = (TranslateScaleTex);          
    MipFilter = LINEAR;                    
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture Texture <string uiname="Texture";>;
sampler Samp = sampler_state
{
    Texture   = (Texture);          
    MipFilter = LINEAR;        
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture TileIndexTex <string uiname="Tile Index (W)";>;
sampler TileIndexSamp = sampler_state
{
    Texture   = (TileIndexTex);          
    MipFilter = none;        
    MinFilter = none;
    MagFilter = none;
};

float4 Color :COLOR = 1;

struct vs2ps
{
    float4 Pos : POSITION;
    float4 TexCdTexture : TEXCOORD1;
    float4 TexCdTile : TEXCOORD2;
    float Size : PSIZE ;
};


vs2ps VS(
    float4 Pos : POSITION ,
    float4 TexCd : TEXCOORD0,
    float4 TexCdTexture : TEXCOORD1,
    float4 TexCdTile : TEXCOORD2)
{
    vs2ps Out = (vs2ps)0;
    
    float4 particleTransform = tex2Dlod(TranslateScaleSamp, TexCd);
    float4 tileIndex = tex2Dlod(TileIndexSamp, TexCd);
    
    Pos.xyz  += particleTransform.xyz;
    
    Out.Pos = mul(Pos, tWVP);
    
    Out.TexCdTexture = TexCdTexture;

    //TexCdTile.xy /= 16.;
    //TexCdTile.xy += float2((tileIndex.w%16)/16.,floor(tileIndex.w/16.)/16.);
	
	TexCdTile *= -1;
	
	Out.TexCdTile = TexCdTile;
	
	float size = min(ViewportSize.x, ViewportSize.y);
	
	float projScaleMax  = max(tP[0][0], tP[1][1]);
	
	//Detecting empty VIEW and PROJECTION matrixes (no camera)
	if(abs(tV[0][0] - tP[0][0]) < 0.001 || abs(tV[1][1] - tP[1][1]) < 0.001)
	{
		projScaleMax /=	2;
	}

	
	Out.Size = (size / 2) * (projScaleMax / Out.Pos.z) * particleTransform.w;
    
	return Out;
}

float4 SINGLE_TEXTURE_PS(vs2ps In): COLOR
{
    return tex2D(Samp, In.TexCdTexture) * Color;
}

float4 TILE_MAP_PS(vs2ps In): COLOR
{
    return tex2D(Samp, In.TexCdTexture) * float4(0, 1, 1, 1);
}

technique Single_Texture
{
	pass P0
    {
		FillMode = POINT;
		PointScaleEnable = true;
		PointSpriteEnable = true;
		
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 SINGLE_TEXTURE_PS();
	}
}

technique Tile_Map
{
	pass P0
    {
		FillMode = POINT;
		PointScaleEnable = true;
		PointSpriteEnable = true;
		
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 TILE_MAP_PS();
	}
}
