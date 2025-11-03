#include "ReShadeUI.fxh"

uniform float Intensity < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.0; ui_max = 1.0;
> = 0.35;

uniform int ColorsPerChannel <
    ui_type = "slider";
    ui_min = 0; ui_max = 256;
> = 3;

uniform float BrightnessThreshold < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.0; ui_max = 1.0;
> = 0.3;

uniform float DistanceThreshold < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.0; ui_max = 1.0;
> = 0.3;

#include "ReShade.fxh"

float3 Quantise(float3 color) {
    return floor(color * float(ColorsPerChannel - 1) + 0.5) / float(ColorsPerChannel - 1);
}


float3 BayerDithering_Pass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
    float3 colorInput = tex2D(ReShade::BackBuffer, texcoord).rgb;
    float depth = pow(tex2D(ReShade::DepthBuffer, texcoord).r,0.07);

    float greyscale = colorInput.r * 0.21 + colorInput.g * 0.72 + colorInput.b * 0.07;

    if (greyscale >= BrightnessThreshold || 1.0 - depth >= DistanceThreshold) {

        float4x4 bayer4 = float4x4(
            float4(0, 8, 2, 10),
            float4(12, 4, 14, 6),
            float4(3, 11, 1, 9),
            float4(15, 7, 13, 5)
        );

        float2 pixcoord = texcoord * ReShade::ScreenSize;

        float dither = bayer4[int(pixcoord.x) % 4][int(pixcoord.y) % 4] / 16 - 0.5;
        return Quantise(colorInput + dither * Intensity);
        //return 1.0;
    }
    return colorInput;
    //return 0.0;
}

technique BayerDithering {
    pass 
    {
        VertexShader = PostProcessVS;
        PixelShader = BayerDithering_Pass;
    }
}