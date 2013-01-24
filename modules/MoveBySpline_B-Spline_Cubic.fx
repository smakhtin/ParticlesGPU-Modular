//@author: alg
//@help: Replace Input 1 data by data from Input 2 channel by channel
//@tags: particles
//@credits: dottore
#include "TextureProcessor.fxh"

texture ControlsTex <string uiname="Control Points (XYZ)";>;
sampler ControlsSamp = sampler_state
{
    Texture   = (ControlsTex);          
    MipFilter = POINT;
    MinFilter = POINT;
    MagFilter = POINT;
    AddressU = clamp;
    ADDRESSV = wrap;
};

int ControlsCount <string uiname="Control Points Count";>;
float PositionU;

float4 BSplineCubic(float4 p1, float4 p2, float4 p3, float4 p4, float range) {
    float mu = frac(range);
    float4 a0 = p4 - p3*3 + p2*3 - p1;
    float4 a1 = p3*3 - p2*6 + p1*3.;
    float4 a2 = p3*3 - p1*3;
    float4 a3 = p3 + p2*4 + p1;
    
    return (a3+mu*(a2+mu*(a1+mu*a0)))/6.;
}

float4 MAIN_PS(vs2ps In): COLOR
{
    float4 pointState = tex2D(InputSamp, In.TexCd);

    float pointU = pointState.w + PositionU;
    
    float cSize = (ControlsCount-1)*0.9999;
    float pixelSize = 1.0 / cSize;
	
	float aproximateSegment = frac(pointU) / (1.0 / (ControlsCount - 1));
	int index = floor(aproximateSegment);
	float currentU = frac(aproximateSegment) / 3.0;

    float4 point1 = tex2D(ControlsSamp, float4(pixelSize * (index - 1), In.TexCd.yzw));
    float4 point2 = tex2D(ControlsSamp, float4(pixelSize * index, In.TexCd.yzw));
    float4 point3 = tex2D(ControlsSamp, float4(pixelSize * (index + 1), In.TexCd.yzw));
    float4 point4 = tex2D(ControlsSamp, float4(pixelSize * (index + 2), In.TexCd.yzw));

//	float4 point1 = tex2D(ControlsSamp, float4(pixelSize * -1, In.TexCd.yzw));
//	float4 point2 = tex2D(ControlsSamp, float4(pixelSize * 0, In.TexCd.yzw));
//	float4 point3 = tex2D(ControlsSamp, float4(pixelSize * 1, In.TexCd.yzw));
//	float4 point4 = tex2D(ControlsSamp, float4(pixelSize * 2, In.TexCd.yzw));

    float4 coords = BSplineCubic(point1, point2, point3, point4, currentU * cSize);
	
	coords.xyz += pointState.xyz;
    coords.w = pointU;
	
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