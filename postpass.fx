// Post-processing Shader (postpass.fx)
// This shader will be responsible for tonemapping and other visual effects.
// It will be called from effect.txt as the final pass.

#include "ENBFeeder.fxh"

// Shared uniforms from enbbloom.fx
uniform float Timer < string UIName="Timer"; int UIHidden=1; >;
uniform float3 SunDirection < string UIName="Sun Direction"; int UIHidden=1; >;
uniform float WeatherType < string UIName="Weather Type"; int UIHidden=1; >;
uniform float3 CameraPosition < string UIName="Camera Position"; int UIHidden=1; >;

// Samplers
SamplerState Sampler1
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};

// Vertex Shader
VS_OUTPUT_POST VS_Quad(VS_INPUT_POST IN)
{
	VS_OUTPUT_POST OUT;
	OUT.pos.xyz = IN.pos.xyz;
	OUT.pos.w = 1.0;
	OUT.txcoord0.xy = IN.txcoord.xy;
	return OUT;
}

// Tonemapping
float3 tonemap(float3 color)
{
    color = color / (color + 1.0);
    return pow(color, 1.0/2.2);
}

// Pixel Shader
float4 PS_PostProcess(VS_OUTPUT_POST IN) : SV_Target
{
    float4 color = TextureColor.Sample(Sampler1, IN.txcoord0.xy);

    // Tonemapping
    color.rgb = tonemap(color.rgb);

    // Vignette
    float2 uv = IN.txcoord0.xy - 0.5;
    float vignette = 1.0 - dot(uv, uv) * 0.5;
    color.rgb *= vignette;

    return color;
}

technique11 PostProcess
{
    pass p0
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Quad()));
        SetPixelShader(CompileShader(ps_5_0, PS_PostProcess()));
    }
}
