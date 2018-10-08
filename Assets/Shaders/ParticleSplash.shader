Shader "Custom/ParticleSplash"
{
	Properties {
	_MainTex ("Particle Texture", 2D) = "white" {}
	_InvFade("Fade Amount", Range(0.0, 5.0)) = 0.8
	}

	Category{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGBA
		Cull Off
		Lighting Off
		ZWrite Off

		SubShader {
			Pass {

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_particles

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;

				sampler2D_float _CameraDepthTexture;
				float _InvFade;
			
				struct appdata_t {
					float4 vertex : POSITION;
					float4 texcoord : TEXCOORD0;
					float4 texcoord1 : TEXCOORD1;
					fixed4 color : COLOR;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					float4 texcoord : TEXCOORD0;
					float4 texcoord1 : TEXCOORD1;
					fixed4 color : COLOR;
#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
#endif
				};
			
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.texcoord = v.texcoord;
					o.texcoord1 = v.texcoord1;
					o.color = v.color;

#ifdef SOFTPARTICLES_ON

					float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
					float3 viewDir = worldPos - _WorldSpaceCameraPos;
					float fadeDist = ( 1.0 / _InvFade );
					//worldPos -= viewDir * fadeDist * 0.5;
					o.vertex = UnityWorldToClipPos(worldPos);

					o.projPos = ComputeScreenPos(o.vertex);
					COMPUTE_EYEDEPTH(o.projPos.z);
					//o.projPos.z = -UnityWorldToViewPos(worldPos).z;
#endif

					return o;
				}

				fixed4 frag (v2f IN) : SV_Target
				{
					#ifdef SOFTPARTICLES_ON
						float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos)));
						float partZ = IN.projPos.z;
						float fade = saturate(_InvFade * (sceneZ - partZ));
						fade *= saturate(_InvFade * partZ * 2.0);
						IN.color.w *= fade;
					#endif
					
					half4 col = tex2D(_MainTex, IN.texcoord.xy);
					//half4 col2 = tex2D(_MainTex, IN.texcoord.zw);
					//col = lerp(col, col2, IN.texcoord1.x);
					col.xyz = pow(IN.color.xyz, 2.2);
					col.w = smoothstep(0.47, 0.53, col.w * IN.color.w);
					return col;
				}
				ENDCG 
			}
		}	
	}
}
