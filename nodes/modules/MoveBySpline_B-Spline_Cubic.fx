//@author: alg
//@help: Replace Input 1 data by data from Input 2 channel by channel
//@tags: particles
//@credits: dottore
#include "TextureProcessor.fxh"
#define PI 3.14159265f

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

float NextPointU <float uimin=0.0; float uimax=1.0; string uiname="Next Point U Addition";> = 0.01;

float4 BSplineCubic(float4 p1, float4 p2, float4 p3, float4 p4, float range) {
    float mu = frac(range);
    float4 a0 = p4 - p3*3 + p2*3 - p1;
    float4 a1 = p3*3 - p2*6 + p1*3.;
    float4 a2 = p3*3 - p1*3;
    float4 a3 = p3 + p2*4 + p1;
    
    return (a3+mu*(a2+mu*(a1+mu*a0)))/6.;
}

struct pointData
{
	float4 position : COLOR;
	float u;
	float4 point1;
	float4 point2;
	float4 point3;
	float4 point4;
	float cSize;
};

pointData CalculatePoint(vs2ps In)
{
	pointData Out = (pointData)0;
	
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

    float4 coords = BSplineCubic(point1, point2, point3, point4, currentU * cSize);
	
	coords.xyz += pointState.xyz;
    coords.w = pointU;
	
	Out.position = coords;
	Out.u = currentU;
	Out.cSize = cSize;
	Out.point1 = point1;
	Out.point2 = point2;
	Out.point3 = point3;
	Out.point4 = point4;
	
    return Out;
}

float4 MAIN_PS(vs2ps In): COLOR
{
    return CalculatePoint(In).position;
}

struct coordsWithRotation
{
	float4 coords : COLOR;
	float4 rotation : COLOR1;
};

coordsWithRotation CALCULATE_ROTATION_PS(vs2ps In)
{
	coordsWithRotation Out = (coordsWithRotation)0;
	pointData calculatedPoint = CalculatePoint(In);
	
	float nextU = calculatedPoint.u + NextPointU;
	float4 nextPos = BSplineCubic(calculatedPoint.point1, calculatedPoint.point2, calculatedPoint.point3, calculatedPoint.point4, nextU * calculatedPoint.cSize);
	
	float4 delta = nextPos - calculatedPoint.position;
	
	float rotationZ = atan2(delta.y, delta.x) / (2 * PI);
	Out.rotation = float4(0, 0, rotationZ, 0);
	Out.coords = calculatedPoint.position;
    return Out;
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

technique Calculate_Rotation
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 CALCULATE_ROTATION_PS();
    	AlphaBlendEnable = false;
    }
}