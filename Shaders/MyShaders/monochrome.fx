#include "ReShadeUI.fxh"

uniform float3 MonoChrome_Weight < __UNIFORM_COMBO_FLOAT3
> = float3(0.2126, 0.7152, 0.0722);

uniform float Saturation < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.0; ui_max = 1.0;
> = 0.0;

#include "ReShade.fxh"

float3 MonoChrome_Pass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
    float3 screen = tex2D(ReShade::BackBuffer, texcoord).rgb;

    float intensity = dot(screen, MonoChrome_Weight);

    float3 color = lerp(intensity, screen, Saturation);

    return color;
}

technique Monochrome
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MonoChrome_Pass;
	}
}
