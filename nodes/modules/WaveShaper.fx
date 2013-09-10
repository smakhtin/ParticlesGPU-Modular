//@author: alg
//@help: Applying waveshaping function
//@tags: particles
//@credits: dottore

#include "TextureProcessor.fxh"

float4 SINE_PS(vs2ps In): COLOR
{
    float4 input = tex2D(InputSamp, In.TexCd);
	
    return (sin(radians(input * 360)) + 1) / 2;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique Sine
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 SINE_PS();
    	AlphaBlendEnable = false;
    }
}