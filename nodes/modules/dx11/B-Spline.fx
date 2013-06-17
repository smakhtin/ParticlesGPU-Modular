//@author: woei
//@help: creates a cubic b-spline ribbon along 3d coordinates, calculated on the GPU
//@tags: curve, spline, b-spline, cubic
// PARAMETERS-------------------------------------------------------------------
//transforms
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tWV: WORLDVIEW;
float4x4 tWVP: WORLDVIEWPROJECTION;
#include "PhongDirectional.fxh"

//texture
Texture2D Tex <string uiname="Texture";>;
SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;
float alpha = 1.;
float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };

int Size;
StructuredBuffer<float4> Position;

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;	
	float3 NormO: NORMAL;
	
	//uint vi :SV_VertexID;
	uint ii : SV_InstanceID;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd : TEXCOORD0;
    float3 LightDirV: TEXCOORD2;
    float3 ViewDirV: TEXCOORD3;
    float3 Tang : TEXCOORD4;
    float3 Bi : TEXCOORD5;
	float4 Depth : TEXCOORD6;
};
//---- B-Spline ----------------------------------------------------------------
struct pota { float4 Pos; float4 Tang; };
pota BSplineCubic(float4 p1, float4 p2, float4 p3, float4 p4, float range) {
	pota Out = (pota)0;

    float mu = frac(range);
   	float4 a0 = p4 - p3*3 + p2*3 - p1;
   	float4 a1 = p3*3 - p2*6 + p1*3.;
	float4 a2 = p3*3 - p1*3;
   	float4 a3 = p3 + p2*4 + p1;
	
	Out.Pos = (a3+mu*(a2+mu*(a1+mu*a0)))/6.;
	Out.Tang = (mu*(2*a0*mu+a1)+mu*(a0*mu+a1)+a2)/6.;
	return Out;
}

int globalIndex(int index, int instanceIndex, int size)
{
	return instanceIndex * size + index;
}


// VERTEXSHADER-----------------------------------------------------------------
float pitch;
vs2ps VS_Spline(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    Out.LightDirV = normalize(-mul(lDir, tV));
	
	float4 pos = input.PosO * 0.9999;
	float linPos = frac(pos.x + 0.5f);
	float segmentLength = 1.0f / (Size - 1.0f);
	float currentSegment = linPos / segmentLength;
	currentSegment = currentSegment - frac(currentSegment);
	
	int p1Index = max(currentSegment - 1, 0);
	int p2Index = currentSegment;
	int p3Index = min((currentSegment + 1), Size - 1);
	int p4Index = min((currentSegment + 2), Size - 1);
	
	float range = frac(linPos / segmentLength);
	
	pota curve = BSplineCubic(Position[globalIndex(p1Index, input.ii, Size)], Position[globalIndex(p2Index, input.ii, Size)], Position[globalIndex(p3Index, input.ii, Size)], Position[globalIndex(p4Index, input.ii, Size)], range);
    
	float4 spline = curve.Pos;

	float3 rVec = 0;
	sincos(pitch,rVec.y,rVec.z);
	float3x3 tR = float3x3(float3(1,0,0), float3(0,rVec.z,-rVec.y), rVec);

	float3 tang = normalize(curve.Tang);
	float3 bitang = normalize(cross(tang,rVec));
	float3x3 tBN = float3x3((float3)0,bitang,cross(tang,bitang));
	
	input.PosO.xyz = spline.xyz+(mul(input.PosO.xyz, tBN) * spline.w);
	
	bitang = normalize(cross(tang,mul(input.NormO, tR)));
	
    Out.PosWVP  = mul(input.PosO, tWVP);	
    Out.TexCd = mul(input.TexCd, tTex);

    //normal in view space
    Out.ViewDirV = -normalize(mul(input.PosO, tWV));
    Out.Tang = tang;
    Out.Bi = bitang;
	Out.Depth = mul(input.PosO, tWVP);
    return Out;
}
// PIXELSHADER------------------------------------------------------------------
float4 PS(vs2ps In): SV_Target
{
	float4 col = Tex.Sample(g_samLinear,In.TexCd.xy) * cAmb;
    float3 n = normalize(cross(In.Tang,In.Bi));    
    col.rgb *= PhongDirectional(n, In.ViewDirV, In.LightDirV);
    col.a*=alpha;
    return mul(col, tColor);
}

float4 PS_Depth(vs2ps In): SV_Target
{
    float4 col = In.Depth.z;
    col.a =1;
    return col;
}
// TECHNIQUES-------------------------------------------------------------------
technique10 BSplineCubic_PhongDirectional
{
    pass P0
    {
        VertexShader = compile vs_4_0 VS_Spline();
        PixelShader = compile ps_4_0 PS();
    }
}
technique10 BSplineSplineCubic_Depth
{
    pass P0
    {
        VertexShader = compile vs_4_0 VS_Spline();
        PixelShader = compile ps_4_0 PS_Depth();
    }
}