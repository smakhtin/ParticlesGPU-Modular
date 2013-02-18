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

texture RotateTex <string uiname="RotateXYZ (XYZ)";>;
sampler RotateSamp = sampler_state
{
    Texture   = (RotateTex);          
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

#define minTwoPi -6.283185307179586476925286766559
#define TwoPi 6.283185307179586476925286766559

//rotate point by quaternion

float3 rotPbyQ (float3 p, float4 q){

   return  p*(q.x*q.x - q.y*q.y - q.z*q.z - q.w*q.w) +
         2*q.yzw*dot(q.yzw, p) + 2*cross(p, q.yzw)*q.x;

}

//rotate point by euler angles
float3 rotate(float3 pointPos, float pitch, float yaw, float roll)
{

  pitch *= minTwoPi;
  yaw    = minTwoPi*(yaw+0.25);
  roll  *= minTwoPi;

  pointPos.xyz = float3(-pointPos.z, pointPos.y, pointPos.x);

  float4 es;
  float coy = cos(yaw*0.5);
  float siy = sin(yaw*0.5);

  es.x = cos(0.5*(roll+pitch))*coy;
  es.y = sin(0.5*(roll-pitch))*siy;
  es.z = cos(0.5*(roll-pitch))*siy;
  es.w = sin(0.5*(roll+pitch))*coy;

  return rotPbyQ(pointPos, es);
}

vs2ps VS(
    float4 Pos : POSITION ,
	float4 TransformTexCd : TEXCOORD0,
    float4 TextureTexCd : TEXCOORD1)
{
    vs2ps Out = (vs2ps)0;
    
    float4 translateTileIndex = tex2Dlod(TranslateTileIndexSamp, TransformTexCd);
    float3 scale =  tex2Dlod(ScaleSamp, TransformTexCd);
    float3 rotateXYZ = tex2Dlod(RotateSamp, TransformTexCd);

    Pos = mul(Pos, tW);

    //Apply scale
    Pos.xyz *= scale.xyz;
    
    //Apply rotation
    Pos.xyz = rotate(Pos.xyz, rotateXYZ.x, rotateXYZ.y, rotateXYZ.z);
    
    //Apply translate
    Pos.xyz += translateTileIndex.xyz;

    Out.Pos = mul(Pos, tWVP);
    
	if(EnableTile)
	{
		TextureTexCd.xy /= TileSize;
    	TextureTexCd.xy += float2((translateTileIndex.w%TileSize)/TileSize,floor(translateTileIndex.w/TileSize)/TileSize);
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

technique WorkingAlpha
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 MAIN_PS();
        AlphaBlendEnable = false;
 
        AlphaTestEnable = true;
        AlphaFunc = Greater;
        AlphaRef = 245;
 
        ZEnable = true;
        ZWriteEnable = true;
 
        CullMode = None;
    }
    pass P1
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 MAIN_PS();
        AlphaBlendEnable = true;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;
 
        AlphaTestEnable = true;
        AlphaFunc = LessEqual;
        AlphaRef = 245;
 
        ZEnable = true;
        ZWriteEnable = false;
 
        CullMode = None;
    }
}