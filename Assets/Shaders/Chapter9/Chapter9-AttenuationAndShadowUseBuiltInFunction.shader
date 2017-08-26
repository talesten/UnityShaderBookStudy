// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"UnityStepBook/Chapter 9/Attenuation  And Shadow Ues Built In Function"{
    Properties{
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) = 20
    }
    SubShader{
        Tags{ "RenderType" = "Opaque" }

        Pass{
            Tags{ "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };
            struct v2f {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) :SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*max(0, dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                //fixed atten = 1.0;
                //fixed shadow = SHADOW_ATTENUATION(i);
                UNITY_LIGHT_ATTENUATION(atten, i,i.worldPos);

                //return fixed4(ambient + (diffuse + specular)*atten*shadow, 1.0);
                return fixed4(ambient + (diffuse + specular)*atten, 1.0);
        }
        ENDCG
    }

        Pass{
            Tags{ "LightMode" = "ForwardAdd" }
            Blend One One

            CGPROGRAM
            #pragma multi_compile_fwdadd//一定要写正确
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f {
                float4 position:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(a2v v) {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) :SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*max(0, dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4((diffuse + specular)*atten, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}