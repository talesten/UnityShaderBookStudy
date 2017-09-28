// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"UnityStepBook/Chapter 12/Gaussian Blur"{
    Properties{
        _MainTex("Base (RGB)",2D)="white"{}
        _BlurSize("Blur Size",Float) = 1.0
    }

    SubShader{
        CGINCLUDE// 类似cpp头文件 重复使用的代码放在这里

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _BlurSize;

        struct v2f {
            float4 pos:SV_POSITION;
            half2 uv[5]:TEXCOORD0;
        };

        v2f vertBlurVertical(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            half2 uv = v.texcoord;

            o.uv[0] = uv;//对领域2纹素单位采样 _BlurSize控制采样距离
            o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y*1.0)*_BlurSize;
            o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y*1.0)*_BlurSize;
            o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y*2.0)*_BlurSize;
            o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y*2.0)*_BlurSize;

            return o;
        }

        v2f vertBlurHorizontal(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            
            half2 uv = v.texcoord;

            o.uv[0] = uv;//对领域2纹素单位采样 _BlurSize控制采样距离
            o.uv[1] = uv + float2(_MainTex_TexelSize.x*1.0, 0.0)*_BlurSize;
            o.uv[2] = uv - float2(_MainTex_TexelSize.x*1.0, 0.0)*_BlurSize;
            o.uv[3] = uv + float2(_MainTex_TexelSize.x*2.0, 0.0)*_BlurSize;
            o.uv[4] = uv - float2(_MainTex_TexelSize.x*2.0, 0.0)*_BlurSize;

            return o;
        }

        fixed4 fragBlur(v2f i) :SV_Target{
            float weight[3] = { 0.4026, 0.2442, 0.0545 };//{ 0.2442, 0.0545, 0.4026, 0.2442, 0.0545 };由于对称性 只取3个权重 剩余两个迭代实现

        fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb*weight[0];

        for (int it = 1; it < 3; it++) {
            sum += tex2D(_MainTex, i.uv[it * 2 - 1]).rgb*weight[it];
            sum += tex2D(_MainTex, i.uv[it * 2]).rgb*weight[it];
        }

        return fixed4(sum, 1.0);
        }

        ENDCG

        ZTest Always Cull Off ZWrite Off

        Pass {
            NAME "GAUSSIAN_BLUR_VERTICAL"

            CGPROGRAM
            #pragma vertex vertBlurVertical//会自动调用CGINCLUDE中对应的函数
            #pragma fragment fragBlur
            ENDCG

        }

        Pass {
            NAME "GAUSSIAN_BLUR_HORIZONTAL"

            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur
            ENDCG
        }
    }
    FallBack "Diffuse"
}