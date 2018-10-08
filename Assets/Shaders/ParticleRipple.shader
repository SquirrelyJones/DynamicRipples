Shader "Custom/ParticleRipple"
{
	Properties {
	_MainTex ("Particle Texture", 2D) = "white" {}
	}

	Category{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend DstColor SrcColor // overlay blend mode
		//Blend One One // additive blend mode
		ColorMask RGBA
		Cull Off
		Lighting Off
		ZWrite Off

		SubShader {
			Pass {

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;
			
				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					float2 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
				};
			
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.color = v.color;
					return o;
				}

				fixed4 frag (v2f IN) : SV_Target
				{
					half4 col = tex2D(_MainTex, IN.texcoord);
					col = lerp( half4( 0.5, 0.5, 0.5, 0.5 ), half4( col.xyz,1.0 ), col.w * IN.color.w );			
					return col;
				}
				ENDCG 
			}
		}	
	}
}
