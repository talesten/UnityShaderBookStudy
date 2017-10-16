// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"UnityStepBook/Chapter 15/Dissovle"{
    Properties{
        _BurnAmount("Burn Amount",Range(0.0,1.0))=0.0
        _LineWidth("Burn Line Width",Range(0.0,0.2))=0.1
        _MainTex("Base (RGB)",2D)="white"{}
        _BumpMap("Normal Map",2D)="bump"{}
        _BurnFirstColor("Burn First Color",Color)=(1,0,0,1)
        _BurnSecondColor("Burn Second Color",Color)=(1,0,0,1)
        _BurnMap("Burn Map",2D)="white"{}
    }

    SubShader{
        Tags{"RenderType" = "Opaque" "Queue" = "Geometry"}

        Pass{
            Tags{"LightMode" = "ForwardBase"}

            Cull Off

            CGPROGRAM

            #include"Lighting.cginc"
            #include"AutoLight.cginc"

            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            fixed _BurnAmount;
            fixed _LineWidth;
            sampler2D _MainTex;
            sampler2D _BumpMap;
            fixed4 _BurnFirstColor;
            fixed4 _BurnSecondColor;
            sampler2D _BurnMap;

            float4 _MainTex_ST;
            float4 _BumpMap_ST;
            float4 _BurnMap_ST;

            struct a2v {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f {
                float4 pos:SV_POSITION;
                float2 uvMainTex:TEXCOORD0;
                float2 uvBumpMap:TEXCOORD1;
                float2 uvBurnMap:TEXCOORD2;
                float3 lightDir:TEXCOORD3;
                float3 worldPos:TEXCOORD4;
                SHADOW_COORDS(5)
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uvBumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);

                TANGENT_SPACE_ROTATION;

                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) :SV_Target{

                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;//burnmap:噪声纹理 控制燃烧(溶解)位置 

                clip(burn.r - _BurnAmount);//结果小于0 剔除颜色 _BurnAmount越大 溶解的越多

                float3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));

                fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

                fixed3 diffuse = _LightColor0.rgb*albedo*max(0, dot(tangentNormal, tangentLightDir));

                //t=0:正常颜色 t=1:消融边界处  其余插值
                fixed t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);

                fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
                burnColor = pow(burnColor, 5);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed3 finalColor = lerp(ambient + diffuse*atten, burnColor, t*step(0.0001, _BurnAmount));//step(a,x)返回 (x >= a) ? 1 : 0 。

                return fixed4(finalColor, 1.0);
            }

            ENDCG
        }

        Pass{
            Tags{"LightMode" = "ShadowCaster"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_complie_shadowcaster

            #include"UnityCG.cginc"

            fixed _BurnAmount;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;

            struct v2f {
                V2F_SHADOW_CASTER;
                float2 uvBurnMap:TEXCOORD1;
            };

            v2f vert(appdata_base v) {
                v2f o;

                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);//texcoord
                return o;
            }

            fixed4 frag(v2f i) :SV_Target{
                fixed3 burn = tex2D(_BurnMap,i.uvBurnMap).rgb;

                clip(burn.r - _BurnAmount);

                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
    }
}