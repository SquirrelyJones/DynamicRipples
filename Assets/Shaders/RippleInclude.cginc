#ifndef DYNAMIC_RIPPLE_INCLUDED
#define DYNAMIC_RIPPLE_INCLUDED

sampler2D _DynamicRippleTexture;
float4x4 _DynamicRippleMatrix;
float _DynamicRippleSize;

float4 WaterRipples(float3 worldPos, float3 worldNormal) {
	float2 rippleCoords = mul(_DynamicRippleMatrix, float4(worldPos, 1)).xy * (1.0 / _DynamicRippleSize);
	half rippleMask = saturate((1.0 - abs(rippleCoords.x)) * 20) * saturate((1.0 - abs(rippleCoords.y)) * 20) * saturate(worldNormal.y);
	half4 ripples = tex2D( _DynamicRippleTexture, saturate(rippleCoords.xy * 0.5 + 0.5) );
	ripples.xyz = pow(ripples.xyz, 0.45);

	ripples = ripples * 2.0 - 1.0;
	ripples *= rippleMask;

	return ripples;
}

#endif // DYNAMIC_RIPPLE_INCLUDED