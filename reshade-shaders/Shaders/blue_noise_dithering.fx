#ifndef NoiseTexelSize
	#define NoiseTexelSize 64
#endif


#include "ReShadeUI.fxh"

uniform float Intensity < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.0; ui_max = 1.0;
> = 0.35;

uniform int ColorsPerChannel <
    ui_type = "slider";
    ui_min = 0; ui_max = 256;
> = 3;


#include "ReShade.fxh"

texture texNoise < source = "bluenoise_16x16.png"; > { Width = NoiseTexelSize; Height = NoiseTexelSize; Format = RGBA8; };
sampler samplerNoise { Texture = texNoise; AddressU = REPEAT; AddressV = REPEAT; AddressW = REPEAT;};


float3 Quantise(float3 color) {
    return floor(color * float(ColorsPerChannel - 1) + 0.5) / float(ColorsPerChannel - 1);
}

float3 BlueNoiseDithering_Pass(float4 vpos : SV_POSITION, float2 texcoord : TexCoord) : SV_TARGET {

    float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
    float2 noisecoord = (texcoord * ReShade::ScreenSize)  / NoiseTexelSize;

    float3 noisecolor = tex2D(samplerNoise, noisecoord).rgb;

    return Quantise(color + noisecolor * Intensity);

}

technique BlueNoiseDithering {
    pass 
    {
        VertexShader = PostProcessVS;
        PixelShader = BlueNoiseDithering_Pass;
    }
}