#include "ReShadeUI.fxh"

uniform float Intensity < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.0; ui_max = 1.0;
> = 1.0;

#include "ReShade.fxh"

float3 Inverse_Pass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
    float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;

    color = lerp(color, float3(1.,1.,1.) - color, Intensity);

    return color;
}

technique Inverse
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = Inverse_Pass;
	}
}
