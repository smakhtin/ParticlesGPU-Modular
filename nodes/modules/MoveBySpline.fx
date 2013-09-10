//@author: alg
//@help: Replace Input 1 data by data from Input 2 channel by channel
//@tags: particles
//@credits: dottore
#include "TextureProcessor.fxh"

texture Point1Tex <string uiname="Point1 (XYZ)";>;
sampler Point1Samp = sampler_state
{
    Texture   = (Point1Tex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture Point2Tex <string uiname="Point2 (XYZ)";>;
sampler Point2Samp = sampler_state
{
    Texture   = (Point2Tex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture Tangent1Tex <string uiname="Tangent1 (XYZ)";>;
sampler Tangent1Samp = sampler_state
{
    Texture   = (Tangent1Tex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture Tangent2Tex <string uiname="Tangent2 (XYZ)";>;
sampler Tangent2Samp = sampler_state
{
    Texture   = (Tangent2Tex);          
    MipFilter = LINEAR;         
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

int Size;
float GlobalState;
bool rel = true;

float4 BezierSpline(float4 p1, float4 t1, float4 p2, float4 t2, float range) { 
    float mu = frac(range);
        
    float4 c1 = t1+(p1*rel);
    float4 c2 = lerp(t2,-t2,rel)+(p2*rel);
  
    float mum1 = 1 - mu;
    float mum13 = mum1 * mum1 * mum1;
    float mu3 = mu * mu * mu;

    return mum13*p1 + 3*mu*mum1*mum1*c1 + 3*mu*mu*mum1*c2 + mu3*p2;
}

float4 MAIN_PS(vs2ps In): COLOR
{
    float4 pointState = tex2D(InputSamp, In.TexCd);

    float linearPosition = pointState.w; 
	
    float4 point1 = tex2D(Point1Samp, In.TexCd);
    float4 point2 = tex2D(Point2Samp, In.TexCd);

    float4 tangent1 = tex2D(Tangent1Samp, In.TexCd);
    float4 tangent2 = tex2D(Tangent2Samp, In.TexCd);


    linearPosition += GlobalState;
    float cSize = (Size-1)*0.9999; 

    float4 coords = BezierSpline(point1, tangent1, point2, tangent2, linearPosition * cSize);
	
	coords.xyz += pointState.xyz;
    coords.w = linearPosition;
	
    return coords;
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