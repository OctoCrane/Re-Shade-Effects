#include "ReShadeUI.fxh"

uniform float Intensity < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.0; ui_max = 1.0;
> = 1.0;

uniform float Spread < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0.0; ui_max = 200.0;
> = 10.0;

uniform float3 ColorOffsets < __UNIFORM_COMBO_FLOAT3
    ui_min = float3(-1.,-1.,-1.); ui_max = float3(1.,1.,1.);
> = float3(0.06,0.01, -0.02);

uniform float2 Centre < __UNIFORM_COMBO_FLOAT2
> = float2(0.5,0.5);

#include "ReShade.fxh"

float3 ChromaticAbberation_Pass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target { 
    float3 screen = tex2D(ReShade::BackBuffer, texcoord);

    float2 distance = clamp(texcoord - Centre, -sqrt(2), sqrt(2));

    float3 offsets = normalize(ColorOffsets);
    

    float r = tex2D(ReShade::BackBuffer, clamp(texcoord + (distance * offsets.r * BUFFER_PIXEL_SIZE * Spread), 0., 1.)).r;
    float g = tex2D(ReShade::BackBuffer, clamp(texcoord + (distance * offsets.g * BUFFER_PIXEL_SIZE * Spread), 0., 1.)).g;
    float b = tex2D(ReShade::BackBuffer, clamp(texcoord + (distance * offsets.b * BUFFER_PIXEL_SIZE * Spread), 0., 1.)).b;

    float3 color = float3(r,g,b);
    color = lerp(screen, color, Intensity);

    return color;
}

technique ChromaticAbberation
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = ChromaticAbberation_Pass;
	}
}
