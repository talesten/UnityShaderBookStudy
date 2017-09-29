// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"UnityStepBook/Chapter 12/Motion Blur"{
    Properties{
        _MainTex("Base (RGB)",2D)="white"{}
        _BlurAmount("Blur Amount",Float) = 1.0
    }

    SubShader{
        CGINCLUDE

        #include"UnityCG.cginc"

        sampler2D  _MainTex;
        fixed _BlurAmount;

        struct v2f {
            float4 pos : SV_POSITION;
            half2 uv:TEXCOORD0;
        };

        v2f vert(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        fixed4 fragRGB(v2f i) :SV_Target{
            return fixed4(tex2D(_MainTex,i.uv).rgb,_BlurAmount);
        }

        half4 fragA(v2f i) : SV_Target{
            return tex2D(_MainTex,i.uv);//ColorMask A 因此只会输出A值
        }
        ENDCG

        ZTest Always Cull Off ZWrite  Off

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            //Blend SrcAlpha OneMinusDstAlpha
            ColorMask G           //只输出rgb通道 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragRGB
            ENDCG
        }

        Pass {
            Blend One  Zero
            ColorMask R        //只输出片元产生的颜色的a通道

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragA
            ENDCG
        }
    }
}