float4x4 tV : VIEW;
float4x4 tVP : VIEWPROJECTION;
float4x4 tVI : VIEWINVERSE;
float4x4 tWVP : WORLDVIEWPROJECTION;
float4x4 tP : PROJECTION;

float3 g_positions[4]:IMMUTABLE =
    {
        float3( -1, 1, 0 ),
        float3( 1, 1, 0 ),
        float3( -1, -1, 0 ),
        float3( 1, -1, 0 ),
    };

float2 g_texcoords[4]:IMMUTABLE =
	{ 
        float2(0,1), 
        float2(1,1),
        float2(0,0),
        float2(1,0),
	};

float WidthMult = 0.001;

StructuredBuffer<float2> StartXY;
StructuredBuffer<float2> EndXY;

StructuredBuffer<float> Width;

float4 StartColor <bool color=true;> = 1;
float4 EndColor <bool color=true;> = 1;

struct VS_IN
{
	uint vi :SV_VertexID;
};

struct vs2ps
{
	float4 Pos: SV_POSITION;
    float4 StartPos: COLOR3;
	float4 EndPos : COLOR4;
	float Width : SIZE;
	float4 Color : COLOR;
};

vs2ps VS(VS_IN input)
{
	vs2ps Out = (vs2ps)0;
	int index = input.vi;
	
    Out.Width = Width[input.vi] * WidthMult;
	
	Out.StartPos = float4(StartXY[index], 0, 1);
	Out.EndPos = float4(EndXY[index], 0, 1);
	
    return Out;
}

[maxvertexcount(4)]
void GS(point vs2ps input[1], inout TriangleStream<vs2ps> SpriteStream)
{
    vs2ps output;
	
	float2 tangent = input[0].EndPos.xy - input[0].StartPos.xy;
	float2 normal = normalize(float2(tangent.y, -tangent.x));
    
    //
    // Emit two new triangles
    //
    for(uint i=0; i<4; i++)
    {
    	//0 - start, 1- finish
    	int startFinish = i % 2;
    	
    	float lineWidth = startFinish == 0 ? 0 : input[0].Width;
        
    	float3 vertexPos = g_positions[i];
    	float2 offset = vertexPos.y * normal * lineWidth;
    	offset *= mul(float4(1, 1, 0, 0), tP).xy;
    	
        //vertexPos = mul( vertexPos, (float3x3)tVI );
    	vertexPos.xy = startFinish == 0 ? input[0].StartPos.xy : input[0].EndPos.xy;
    	
    	vertexPos.xy += offset;
    	
        output.Pos = mul( float4(vertexPos,1.0), tVP );
        output.Color = startFinish == 0 ? StartColor : EndColor;
        output.Width = lineWidth;
    	
    	output.StartPos = 0;
    	output.EndPos = 0;
    	
        SpriteStream.Append(output);
    }
	
    SpriteStream.RestartStrip();
}


// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): SV_Target
{
    float4 col = In.Color;
	
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
    	SetGeometryShader( CompileShader( gs_5_0, GS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}
