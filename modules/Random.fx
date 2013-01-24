//@author: alg
//@help: Generate random number by seed
//@tags: particles

#include "TextureProcessor.fxh"

float Seed = 1.0;
float4 Min = -1;
float4 Max = 1;

float map(float current, float currentMin, float currentMax, float targetMin, float targetMax)
{
	return targetMin + (current - currentMin) / (currentMax - currentMin) * (targetMax - targetMin);
}

float4 rand_1_05(float2 uv)
{
	Seed += 0.1;
    float noiseR = frac(sin(dot(float4(uv, uv) ,float4(12.9898 * pow(Seed, 2), 78.233 * Seed, 54.564 + Seed, 105.85 * -Seed)*2.0)) * 43758.5453);
	float noiseG = frac(sin(dot(float4(uv, uv) ,float4(43.7 * pow(Seed, 0.5), 64.2 * (Seed +Seed), 647.9 * Seed / 0.5 , 25.01 * Seed -0.5 * Seed)*2.0)) * 43758.5453);
	float noiseB = frac(sin(dot(float4(uv, uv) ,float4(54.2323 * Seed, 123.2 * Seed, 23.2 * Seed, 52.232 * Seed)*2.0)) * 43758.5453);
	float noiseA = frac(sin(dot(float4(uv, uv) ,float4(33.3 * Seed, 34.4 * Seed, 23 * Seed, 2323 * Seed)*4.723)) * 43758.5453);
	
    return float4(map(noiseR, -0.5453, 0.5453, Min.r, Max.r), map(noiseG, -0.5453, 0.5453, Min.g, Max.g), map(noiseB, -0.5453, 0.5453, Min.b, Max.b), map(noiseA, -0.5453, 0.5453, Min.a, Max.a));
}

float4 MAIN_PS(vs2ps In): COLOR
{	
	float3 c = tex2D(InputSamp, In.TexCd);
    return rand_1_05(In.TexCd.xy);
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