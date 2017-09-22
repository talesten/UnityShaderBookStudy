// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"UnityStepBook/Chapter 11/Billboard"{
    Properties{
        _MainTex("Main Tex",2D)="white"{}
        _Color("Color Tint",Color) = (1,1,1,1)
        _VerticalBillboarding("Vertical Restraints",Range(0,1)) = 1
    }

    SubShader{
        Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"  "DisableBatching" = "True"}

        Pass{
            Tags  {"LightMode" = "ForwardBase"}

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _VerticalBillboarding;

            struct a2v {
                float4 vertex:POSITION;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
                float4 tempNormal:TEXCOORD1;
            };

            v2f vert(a2v v) {
                v2f o;

                float3 center = float3(0, 0, 0);
                float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));//模型空间下 摄像机位置(视角位置 ) unity_WorldToObject:是指当前顶点所属模型的世界到模型转换矩阵

                //float3 viewer = mul( float4(_WorldSpaceCameraPos, 1), unity_WorldToObject);//模型空间下 摄像机位置(视角位置 )

                float3 normalDir = viewer - center;//法线方向
                normalDir.y = normalDir.y*_VerticalBillboarding;//_VerticalBillboarding:约束法线垂直方向的程度
                normalDir = normalize(normalDir);
                o.tempNormal = float4(normalDir, 1);

                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
                float3 rightDir = normalize(cross(upDir, normalDir));
                upDir = normalize(cross(normalDir, rightDir));

                //float3 center1 = float3(3, 3, 3);
                float3 centerOffs = v.vertex.xyz- center;
                float3 localPos = center + rightDir*centerOffs.x + upDir*centerOffs.y + normalDir*centerOffs.z;

                o.pos = UnityObjectToClipPos(float4(localPos, 1));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag(v2f i) :SV_Target{
                fixed4 c = tex2D(_MainTex,i.uv);
                c.rgb *= _Color.rgb;

                //return i.tempNormal;
                return c;
            }

            ENDCG
        }
    }
    FallBack"Transparent/VertexLit"
}