//@author: alg
//@help: Get lumiance of RGB pixels
//@tags: particles
//@credits: desaxismundi, dottore
//Source: http://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
Texture2D Texture;

float Power = 1;

[numthreads(64, 1, 1)]
void AverageBaseCS(vs2ps In)
{
    float4 input = tex2D(InputSamp, In.TexCd);
	
	float lumiance = (input.r + input.g + input.b) / 3;
    
    return lumiance * Power;
}

[numthreads(64, 1, 1)]
void LuminanceStandardObjectiveCS(vs2ps In)
{
    float4 input = tex2D(InputSamp, In.TexCd);
    
    float lumiance = (0.2126*input.r) + (0.7152*input.g) + (0.0722*input.b);
    
    return lumiance * Power;
}

[numthreads(64, 1, 1)]
void LuminancePerceivedOption1CS(vs2ps In)
{
    float4 input = tex2D(InputSamp, In.TexCd);
    
    float lumiance = (0.299*input.r) + (0.587*input.g) + (0.114*input.b);
    
    return lumiance * Power;
}

[numthreads(64, 1, 1)]
void LuminancePerceivedOption2CS(vs2ps In)
{
    float4 input = tex2D(InputSamp, In.TexCd);
    
    float lumiance = sqrt( 0.241 * pow(input.r, 2) + 0.691 * pow(input.g, 2) + 0.068 * (input.b, 2) );
    
	return lumiance * Power;
}

technique Average_Base
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 AVERAGE_BASE_PS();
    	AlphaBlendEnable = false;
    }
}

technique Lumiance_Standard_Objective
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 LUMINANCE_STANDARD_OBJECTIVE_PS();
        AlphaBlendEnable = false;
    }
}

technique Lumiance_Perceived_Option_1
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 LUMINANCE_PERCEIVED_OPTION_1_PS();
        AlphaBlendEnable = false;
    }
}

technique Lumiance_Perceived_Option_2
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 LUMINANCE_PERCEIVED_OPTION_2_PS();
        AlphaBlendEnable = false;
    }
}