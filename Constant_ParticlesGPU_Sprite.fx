//@author: alg
//@description: Draws a Constant ParticlesGPU Sprites mesh using the DataTexture
//@tags: particles sprites
//@credits: dottore, Viktor Vicsek for Sprites Function

float4x4 tW: WORLD;
float4x4 tV: VIEW;
float4x4 tP: PROJECTION;
float4x4 tVP: VIEWPROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

bool NoCamera;
float2 ViewportSize;

texture TexTransform <string uiname="Transform Texture";>;
sampler SampTransform = sampler_state
{
    Texture   = (TexTransform);          
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
    float4 Pos : POSITION ;
    float4 TexCd2 : TEXCOORD2 ;
    float Size : PSIZE ;
};


vs2ps VS(
    float4 Pos : POSITION ,
    float4 TexCd : TEXCOORD0 ,
    float4 TexCd2 : TEXCOORD2 )
{
    vs2ps Out = (vs2ps)0;
    
    float4 particleTransform = tex2Dlod(SampTransform, TexCd);
    
    Pos.xyz  += particleTransform.xyz;
    
    Out.Pos = mul(Pos, tWVP);
    
    Out.TexCd2 = TexCd2;
	
	float size = max(ViewportSize.x, ViewportSize.y);
	float z = Out.Pos.z;
	
	if(NoCamera)
	{
		z =	1;
	}

	
	Out.Size = (size / 2) * (tP[0][0] / z) * particleTransform.w;
    
	return Out;
}

float4 PS(vs2ps In): COLOR
{
	float a=0;
    return tex2D(Samp, In.TexCd2) * Color;
}

technique Particles_3d_Sprites
{
	pass P0
    {
		FillMode = POINT;
		PointScaleEnable = true;
		PointSpriteEnable = true;
		
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS();
	}
}
