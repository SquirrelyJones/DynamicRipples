Shader "Custom/Water" {
	Properties {
		_Color ("Color Dark", Color) = (1,1,1,1)
		_Color2("Color Light", Color) = (1,1,1,1)
		_FoamColor("Foam Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Scrolling("Water Scrolling", Vector) = (0,0,0,0)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		// multi compile for turning ripples on and off
		#pragma multi_compile _ DYNAMIC_RIPPLES_ON

		// the ripple include file that has the functions for sampling the ripple texture
		#include "RippleInclude.cginc"

		// the variables 
		sampler2D _MainTex;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color; // light color of the water
		fixed4 _Color2; // light color of the water
		fixed4 _FoamColor; // the color of the foam
		float4 _Scrolling; // X and Y scrolling speed for the water texture, Z and W is scrolling speed for the second water texture

		struct Input {
			float2 uv_MainTex; // needed for the water texture coords
			float3 worldNormal; // needed for WorldNormalVector() to work
			float3 worldPos; // we need the world position fro sampling the ripple texture
			INTERNAL_DATA // also needed for WorldNormalVector() to work and any other normal calculations
		};

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex + frac(_Time.yy * _Scrolling.xy));
			fixed4 c2 = tex2D(_MainTex, IN.uv_MainTex * 1.3 + frac(_Time.yy * _Scrolling.zw));

			// blend textures together
			c = (c + c2) * 0.5;

			// get the normal, foam, and height params
			half3 normal = half3(c.x, c.y, 1) * 2.0 - 1.0;
			normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
			half foam = smoothstep(0.4, 0.6, c.z * c.z );
			half height = c.w;

#ifdef DYNAMIC_RIPPLES_ON
			// get the world normal, tangent, and binormal for masking the ripples and converting world normals to tangent normals
			float3 worldNormal = WorldNormalVector(IN, float3(0, 0, 1));
			float3 worldTangent = WorldNormalVector(IN, float3(1, 0, 0));
			float3 worldBinormal = WorldNormalVector(IN, float3(0, 1, 0));
			
			// sample the ripple texture
			half4 ripples = WaterRipples(IN.worldPos, worldNormal);

			// convert normal from world space to local space and add to surface normal
			// we only need the X and Y since this is an overlay for the existing water normals
			float2 rippleNormal = 0;
			rippleNormal.x = dot(worldTangent, half3(ripples.x, 0, ripples.y));
			rippleNormal.y = dot(worldBinormal, half3(ripples.x, 0, ripples.y));
			
			// add the normal foam and height contributions
			normal.xy += rippleNormal;
			foam += ripples.z * 5.0;
			height += ripples.w;
#endif
			// tighten the foam transition for a toony look
			foam = smoothstep(0.45, 0.55, foam);

			// modify the height ( which is used as a light dark color mask ) by the normal
			height = height + (normal.x * 0.5) - (normal.y * 0.5);

			// smooth step the height to get a tighter transition
			height = smoothstep(0.50, 0.55, height);

			// blend between the light and dark water color based on the height
			float3 waterColor = lerp( _Color.rgb, _Color2.rgb, height );

			// blend between the water color and the foam color
			waterColor = lerp(waterColor, _FoamColor.rgb, foam);

			// half the color to the albedo for shadow
			o.Albedo = waterColor * 0.5;
			// half the color to the emissive for consistancy
			o.Emission = waterColor * 0.5;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			// normal is flat but still needs to be set to get the INTERNAL_DATA
			o.Normal = float3(0,0,1);
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
