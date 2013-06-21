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
float Alpha = 1.;

StructuredBuffer<int> Size;
StructuredBuffer<int> BackSize;

StructuredBuffer<float4> Position;
StructuredBuffer<float4> Tangent;

StructuredBuffer<float4> Color;

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
	float4 Color : COLOR;
};
//---- B-Spline ----------------------------------------------------------------
bool rel <string uiname="Relative Tangent";>;
bool next <string uiname="Relative to n/n+1";>;
struct pota { float4 Pos; float4 Tang; };
pota BezierSplinePW(float4 p1, float4 t1, float4 p2, float4 t2, float range) {
	pota Out = (pota)0;
	
	float mu = frac(range);
		
    float4 c1 = t1+(p1*rel);
    float4 c2 = lerp(t2, lerp(p1+t2,p2-t2,next), rel);
  
    float mum1 = 1 - mu;
    float mum13 = mum1 * mum1 * mum1;
    float mu3 = mu * mu * mu;

	Out.Pos = mum13*p1 + 3*mu*mum1*mum1*c1 + 3*mu*mu*mum1*c2 + mu3*p2;
	//Out.Pos = lerp(p1,p2,mu);
	//Out.Tang = float4(1,0,1,1);
	Out.Tang = 3*(c1-p1)*mum1*mum1+3*(c2-c1)*2*mu*mum1+3*(p2-c2)*mu*mu;
	return Out;
}

int globalIndex(int index, int instanceIndex, int size)
{
	return instanceIndex * size + index;
}


// VERTEXSHADER-----------------------------------------------------------------
vs2ps VS_Spline(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    Out.LightDirV = normalize(-mul(lDir, tV));
	
	float4 pos = input.PosO * 0.9999;
	float linPos = frac(pos.x + 0.5f);
	float segmentLength = 1.0f / (Size[input.ii] - 1.0f);
	float currentSegment = linPos / segmentLength;
	currentSegment = currentSegment - frac(currentSegment);
	
	int p1Index = currentSegment;
	int p2Index = min(currentSegment + 1, Size[input.ii] - 1);
	int t1Index = currentSegment * 2;
	int t2Index = t1Index + 1;
	
	float range = frac(linPos / segmentLength);

	int tangentSize = (max(BackSize[input.ii] - 1, 0)) * 2;

	float4 p1 = Position[p1Index + max(BackSize[input.ii], 0)];
	float4 p2 = Position[p2Index + max(BackSize[input.ii], 0)];

	float4 t1 = Tangent[t1Index + tangentSize];
	float4 t2 = Tangent[t2Index + tangentSize];
	
	pota curve = BezierSplinePW(p1, float4(t1.xyz, 0), p2, float4(t2.xyz, 0), range);
    
	float4 spline = curve.Pos;

	float3 rVec = 0;
	sincos(t1.w, rVec.y, rVec.z);
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
	
	Out.Color = Color[input.ii];
    return Out;
}
// PIXELSHADER------------------------------------------------------------------
float4 PS(vs2ps In): SV_Target
{
	float4 col = Tex.Sample(g_samLinear,In.TexCd.xy) * In.Color;
    float3 n = normalize(cross(In.Tang,In.Bi));    
    col.rgb *= PhongDirectional(n, In.ViewDirV, In.LightDirV);
    col.a *= Alpha;
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