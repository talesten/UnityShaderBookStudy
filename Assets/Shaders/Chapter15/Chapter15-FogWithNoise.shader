// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"UnityStepBook/Chapter 15/Fog With Noise"{
    Properties{
        _MainTex("Base (RGB)",2D)="white"{}
        _FogDensity("Fog Density",Float)=1.0
        _FogColor("Fog Color",Color)=(1,1,1,1)
        _FogStart("Fog Start",Float)=0.0
        _FogEnd("Fog End",Float)=1.0
        _NoiseTex("Noise Texture",2D)="white"{}
        _FogXSpeed("Fog Horizontal Speed",Float) = 0.1
        _FogYSpeed("Fog Vertical Speed",Float) = 0.1
        _NoiseAmount("Noise Amount",Float) = 1
    }

    SubShader{
        CGINCLUDE

        #include "UnityCG.cginc"

        float4x4 _FrustumCornersRay;

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        half _FogDensity;
        fixed4 _FogColor;
        float _FogStart;
        float _FogEnd;
        sampler2D _NoiseTex;
        half _FogXSpeed;
        half _FogYSpeed;
        half _NoiseAmount;

        struct v2f {
            float4 pos:SV_POSITION;
            float2 uv:TEXCOORD0;
            float2 uv_depth:TEXCOORD1;
            float4 interpolatedRay:TEXCOORD2;
        };


        v2f vert(appdata_img v) {
            v2f o;

            o.pos = UnityObjectToClipPos(v.vertex);

            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;

            #if UNITY_UV_START_AT_TOP
            if (_MainTex_TexelSize.y < 0)
                o.uv_depth = 1 - o.uv_depth.y;
            #endif

            int index = 0;
            if (v.texcoord.x < 0.5&&v.texcoord.y < 0.5){
                index = 0;
            }//左下
            else if (v.texcoord.x > 0.5&&v.texcoord.y < 0.5) {
                index = 1;
            }//右下
            else if (v.texcoord.x > 0.5&&v.texcoord.y>0.5) {
                index = 2;
            }//右上
            else {
                index = 3;
            }//左上

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
                index = 3 - index;
            #endif

            o.interpolatedRay = _FrustumCornersRay[index];

            return o;
        }

        fixed4 frag(v2f i) :SV_Target{
            float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
            float3 worldPos = _WorldSpaceCameraPos + linearDepth*i.interpolatedRay.xyz;//通过世界空间内摄像机位置得到像素位置

            float2 speed = _Time.y*float2(_FogXSpeed, _FogYSpeed);
            float noise = (tex2D(_NoiseTex, i.uv + speed).r - 0.5)*_NoiseAmount;

            float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);//雾浓度
            fogDensity = saturate(fogDensity*_FogDensity*(1 + noise));

            fixed4 finalColor = tex2D(_MainTex, i.uv);
            finalColor.rgb = lerp(finalColor, _FogColor.rgb, fogDensity);

            return finalColor;
        }
        ENDCG

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
    FallBack Off
}