Texture2D texture2d <string uiname="Texture";>;

StructuredBuffer<float3> VerticesXYZ;
StructuredBuffer<float4> Color;
StructuredBuffer<float> Width;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tWVP : WORLDVIEWPROJECTION;
	float4x4 tP : PROJECTION;
	float4 cAmb <bool color=true;String uiname="Ambient Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float BinSize = 2;
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;
	uint vi :SV_VertexID;
	uint ii : SV_InstanceID;
};

struct vs2ps
{
    float4 PosP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
	float4 Color: COLOR;
};

uint getIndex(uint instanceIndex, int binSize, uint vertexIndex)
{
	return instanceIndex * binSize + vertexIndex;
}

vs2ps VS(VS_IN input)
{
	vs2ps Out = (vs2ps)0;
	
	
	
	uint interval = input.ii;
	
	float lineIndex = interval / (BinSize - 1);
	lineIndex = lineIndex - frac(lineIndex);
	
	uint p1VertexIndex = interval + lineIndex;
	uint p2VertexIndex = interval + 1 + lineIndex;
	
	float u = input.PosO.x + 0.5;
	
    float w = Width[0] * 0.003;
   
    //Out.uv = float2(u, Pos.y*2);
    
    // get point on curve
    float4 p;
    //p = float4(lerp(Point1, Point2, u), 1);

    // get position in projection space
    //p = mul(p, tWVP);

    // get tangent in projection space
    float4 p1 = mul(float4(VerticesXYZ[p1VertexIndex], 1), tWVP);
    float4 p2 = mul(float4(VerticesXYZ[p2VertexIndex], 1), tWVP);

    p = lerp(p1, p2, u);

    p1 /= p1.w;
    p2 /= p2.w;
    float4 tangent = p2 - p1;

    //p = lerp(p1, p2, u);

    // get normal in projection space
    float2 normal = normalize(float2(tangent.y, -tangent.x));

    // translate point to get a thick curve
    float2 off = input.PosO.y * normal * w * p.w;

    // correct aspect ratio
    off *= mul(float4(1, 1, 0, 0), tP);

    p+= float4(off, 0, 0);

    //tangent = normalize(tangent);
    //float3 normal = cross(tangent, float3(0,0,1));
    //p += Pos.y * float4(normal, 0) * w * p.w;

    // output pos p
    Out.PosP = p; input.PosO;

    input.TexCd.x *= .1 * length(tangent) / w;

    //ouput texturecoordinates
    Out.TexCd = mul(input.TexCd, tTex);
	
	int colorIndex = input.vi % 2 > 0 ? 1 : 0;
	Out.Color = Color[colorIndex];
    return Out;
}


// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample(g_samLinear, In.TexCd.xy) * In.Color;
    //col.a *= 1 - pow(abs(In.uv.y), 4);
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique10 TLine
{
    pass P0
    {
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}
