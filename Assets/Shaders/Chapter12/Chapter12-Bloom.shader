// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"UnityStepBook/Chapter 12/Bloom"{
    Properties{
        _MainTex("Base (RGB)",2D)="white"{}
        _Bloom("Bloom",2D)="black"{}
        _LuminanceThreshold("Luminance Threshold",Float) = 0.5
        _BloomSize("Blur Size",Float) = 1.0
    }

    SubShader{
        CGINCLUDE

        #include  "UnityCG.cginc"
        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _Bloom;
        float _LuminanceThreshold;
        float _BlurSize;

        struct v2f {
            float4 pos:SV_POSITION;
            half2 uv:TEXCOORD0;
        };

        v2f vertExtraBright(appdata_img v) {
            v2f o;

            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;

            return o;
        }

        fixed luminance(fixed4 color) {
            return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
        }

        fixed4 fragExtraBright(v2f  i) :SV_Target{
            fixed4 c = tex2D(_MainTex,i.uv);
            fixed val = clamp(luminance(c) - _LuminanceThreshold, 0.0, 1.0);

            return c*val;
        }

        struct v2fBloom {
            float4  pos:SV_POSITION;
            half4 uv:TEXCOORD0;
        };

        v2fBloom vertBloom(appdata_img v) {
            v2fBloom o;

            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;

            #if UNITY_UV_START_AT_TOP//处理平台差异性
            if (_MainTex_TexelSize.y < 0.0)
                o.uv.w = 1.0 - o.uv.w;

            #endif
            return o;
        }

        fixed4 fragBloom(v2fBloom i) :SV_Target{
            return tex2D(_MainTex,i.uv.xy) + tex2D(_Bloom,i.uv.zw);
        }

        ENDCG

        ZTest Always Cull Off ZWrite Off

        Pass {                              //Pass:0
            CGPROGRAM
            #pragma vertex vertExtraBright
            #pragma fragment fragExtraBright
            ENDCG
        }

        UsePass "UnityStepBook/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_VERTICAL"                              //Pass:1
        UsePass "UnityStepBook/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_HORIZONTAL"                              //Pass:2


        Pass {                              //Pass:3
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom
            ENDCG
        }
    }
}