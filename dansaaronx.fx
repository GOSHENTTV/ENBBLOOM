// Volumetric Clouds Shader (dansaaronx.fx)
// This shader will be responsible for rendering the 3D clouds.
// It will be called from effect.txt as a separate pass.

#include "ENBFeeder.fxh"

// Shared uniforms from enbbloom.fx
uniform float Timer < string UIName="Timer"; int UIHidden=1; >;
uniform float3 SunDirection < string UIName="Sun Direction"; int UIHidden=1; >;
uniform float WeatherType < string UIName="Weather Type"; int UIHidden=1; >;
uniform float3 CameraPosition < string UIName="Camera Position"; int UIHidden=1; >;
uniform float CloudDensity;
uniform float CloudDensityMultiplier;
uniform float CloudNoise;
uniform float CloudNoiseMultiplier;
uniform float CloudSpeed;
uniform float CloudSpeedMultiplier;

Texture2D noisetex < string ResourceName = "AaronX/18690.png"; > ;

// Samplers
SamplerState Sampler1
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};

SamplerState SamplerNoise
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
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

// 3D noise function
float noise(float3 p)
{
    float3 i = floor(p);
    float3 f = frac(p);
    f = f*f*(3.0-2.0*f);

    float2 uv = (i.xy+float2(37.0,17.0)*i.z) + f.xy;
    float2 rg = noisetex.Sample(SamplerNoise, (uv+0.5)/256.0).rg;
    return lerp(rg.x, rg.y, f.z);
}

// Pixel Shader
float4 PS_VolumetricClouds(VS_OUTPUT_POST IN) : SV_Target
{
    float2 uv = IN.txcoord0.xy;
    float3 rayDir = normalize(float3(uv * 2.0 - 1.0, 1.0));
    float3 rayPos = CameraPosition;

    float4 color = float4(0.0, 0.0, 0.0, 1.0);

    float density = 0.0;

    for (int i = 0; i < 64; i++)
    {
        rayPos += rayDir * 0.1;

        float3 p = rayPos;
        p.x += Timer * CloudSpeed * CloudSpeedMultiplier * 0.01;

        float d = noise(p * 0.1 * CloudNoise * CloudNoiseMultiplier);

        density += d * CloudDensity * CloudDensityMultiplier * 0.01;
    }

    color.rgb = float3(1.0, 1.0, 1.0) * density;
    color.a = 1.0 - density;

    return color;
}

technique11 VolumetricClouds
{
    pass p0
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Quad()));
        SetPixelShader(CompileShader(ps_5_0, PS_VolumetricClouds()));
    }
}
