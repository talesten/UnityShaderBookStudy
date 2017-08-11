// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UnityStepBook/Chapter 7/Normal Map In Tangent Space"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
        _MainTex("Main Tex",2D) = "white"{}
        _BumpMap("Bump Map",2D) = "bump"{}
        _BumpScale("Bump Scale",Float) = 1.0
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("_Gloss",Range(8.0,256)) = 20.0
    }


        SubShader
        {
            Pass
            {
                Tags{"LightMode" = "ForwardBase"}

                CGPROGRAM

                    #pragma vertex vert
                    #pragma fragment frag
                    #include "Lighting.cginc"

                    fixed4 _Color;
                    sampler2D _MainTex;
                    float4 _MainTex_ST;
                    sampler2D _BumpMap;
                    float4 _BumpMap_ST;
                    float _BumpScale;
                    fixed4 _Specular;
                    float _Gloss;

                    struct a2v
                    {
                        float4 vertex:POSITION;
                        float3 normal:NORMAL;
                        float4 tangent:TANGENT;
                        float4 texcoord:TEXCOORD0;
                    };

                    struct v2f
                    {
                        float4 pos:SV_POSITION;//注意别写错成SV_TARGET 否则会什么都不显示
                        float4 uv:TEXCOORD0;
                        float3 lightDir:TEXCOORD1;
                        float3 viewDir:TEXCOORD2;
                    };

                    v2f vert(a2v v)
                    {
                        v2f o;
                        o.pos = UnityObjectToClipPos(v.vertex);
                        o.uv.xy = v.texcoord.xy*_MainTex_ST.xy + _MainTex_ST.zw;//计算平铺和偏移系数得出贴图的uv坐标
                        o.uv.zw = v.texcoord.xy*_BumpMap_ST.xy + _BumpMap_ST.zw;//计算平铺和偏移系数得出法线贴图的uv坐标

                        float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz))*v.tangent.w;
                        float3x3 rotation = float3x3(v.tangent.xyz, binormal.xyz, v.normal.xyz);//以顶点的法线 切线 副切线组成模型空间到切线空间的转换矩阵 按列排列 
                       // float3x3 rotation = float3x3(float3(1.0, 0, 0), float3(0, 1.0, 0), float3(0, 0, 1.0));
                        //TANGENT_SPACXE_ROTATION

                        o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;//ObjSpaceLightDir:世界坐标转到模型坐标.再和模型转切线矩阵相乘得到切线空间里光照方向 
                        o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;//同理得到切线空间里观察方向
                        return o;
                    }

                    fixed4 frag(v2f i) :SV_TARGET
                    {
                        fixed3 tangentLightDir = normalize(i.lightDir);
                        fixed3 tangentViewDir = normalize(i.viewDir);

                        fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);//unity已经对normalmap进行优化压缩 tex2D取出来的值不能直接用 所以必须使用UnpackNormal获取正确的Normal
                        fixed3 tangentNormal;//切线空间下的法线方向

                        tangentNormal = UnpackNormal(packedNormal);
                        tangentNormal.xy *= _BumpScale;
                        tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));//saturate:Clamps the value to the range [0, 1]  x*x+y*y+z*z=1;

                        fixed3 albedo = tex2D(_MainTex, i.uv).rgb*_Color.rgb;
                        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

                        fixed3 diffuse = _LightColor0.rgb*albedo*max(0, dot(tangentNormal, tangentLightDir));

                        fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                        fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
                        return fixed4(ambient + diffuse + specular, 1.0);
                    }

                ENDCG
            }
        }
    Fallback"Diffuse"
}