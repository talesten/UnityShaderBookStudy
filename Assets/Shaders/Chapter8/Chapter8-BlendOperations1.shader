// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"UnityStepBook/Chapter 8/Blend Operation 1"{
    Properties{
        _Color("Color Tint",Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="white"{}
        _AlphaScale("Alpha Scale",Range(0,1)) = 1
    }

        SubShader{
            Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

            Pass{
                Tags{"LightMode" = "ForwardBase"}

            ZWrite Off

            //Normal 正常 透明度混合
            //Blend SrcAlpha OneMinusSrcAlpha

            //Soft Additive 柔和相加
            //Blend OneMinusDstColor One

            //Multiply 正片叠底(相乘)
            //Blend DstColor Zero

            //2x Multiply 两倍相乘
            //Blend DstColor SrcColor

            //Darken 变暗
            //BlendOp Min     //右半边消失是因为和缓冲区的屏幕底色混合取Min
            //Blend One One//使用Min操作 本语句将被忽略

            //Lighten 变亮
            //BlendOp Max
            //Blend One One//使用Max操作 本语句将被忽略

            //Screen 滤色
            //Blend OneMinusDstColor One
            //Or 等同于
            //Blend One OneMinusSrcColor

            //Linear Dodge 线性减淡
            //Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

            struct a2v {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy*_MainTex_ST.xy + _MainTex_ST.zw;

                return o;
            }

            fixed4 frag(v2f i) :SV_Target{
                fixed4 texColor = tex2D(_MainTex,i.uv);

                return fixed4(texColor.rgb*_Color.rgb, texColor.a*_AlphaScale);//输出的颜色将和颜色缓冲区的混合 混合因子的方法由上述Blend指定
            }

            ENDCG
        }
    }

}