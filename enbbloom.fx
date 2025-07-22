// Bloom and Cloud Control Shader (enbbloom.fx)
// This shader is responsible for the bloom effect and provides the UI controls for the clouds.

#include "ENBFeeder.fxh"

// === Shared Uniforms ===
uniform float Timer < string UIName="Timer"; int UIHidden=1; >;
uniform float3 SunDirection < string UIName="Sun Direction"; int UIHidden=1; >;
uniform float WeatherType < string UIName="Weather Type"; int UIHidden=1; >;

// === Cloud Controls ===
uniform float CloudDensity < string UIName = "Cloud Density"; float UIMin = 0.0; float UIMax = 10.0; > = 1.0;
uniform float CloudDensityMultiplier < string UIName = "Cloud Density Multiplier"; float UIMin = 1.0; float UIMax = 100.0; > = 1.0;
uniform float CloudNoise < string UIName = "Cloud Noise";   float UIMin = 0.0; float UIMax = 10.0; > = 0.5;
uniform float CloudNoiseMultiplier < string UIName = "Cloud Noise Multiplier"; float UIMin = 1.0; float UIMax = 100.0; > = 1.0;
uniform float CloudSpeed < string UIName = "Cloud Speed";   float UIMin = 0.0; float UIMax = 10.0; > = 1.0;
uniform float CloudSpeedMultiplier < string UIName = "Cloud Speed Multiplier"; float UIMin = 1.0; float UIMax = 100.0; > = 1.0;


//BLOOM
float b < string UIName = "Bloom:: Intensité"; float UIMin = 0.0; float UIMax = 0.25; float UIStep = 0.0005; > = { 0.067 };

SamplerState Sampler1
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};

struct VS_INPUT_POST
{
	float3 pos	: POSITION;
	float2 txcoord	: TEXCOORD0;
};
struct VS_OUTPUT_POST
{
	float4 pos	: SV_POSITION;
	float2 txcoord0	: TEXCOORD0;
};

VS_OUTPUT_POST VS_Quad(VS_INPUT_POST IN)
{
	VS_OUTPUT_POST OUT;
	OUT.pos.xyz = IN.pos.xyz;
	OUT.pos.w = 1.0;
	OUT.txcoord0.xy = IN.txcoord.xy;
	return OUT;
}

float4 PS_Bloom(VS_OUTPUT_POST IN) : SV_Target
{
    float3 color = TextureColor.Sample(Sampler1, IN.txcoord0.xy).xyz;
    // Simple bloom implementation for now
    return float4(color * b, 1.0);
}

technique11 AaronXBloom
{
    pass p0
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Quad()));
        SetPixelShader(CompileShader(ps_5_0, PS_Bloom()));
    }
}
