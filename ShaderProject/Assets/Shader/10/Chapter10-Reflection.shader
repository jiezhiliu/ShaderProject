// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "MyShader/Chapter10-Reflection"
{
    Properties
    {
        _CubeMap ("Reflection Cubemap", Cube) = "_Skybox" {}
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _ReflectColor ("Reflection Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _ReflectAmount ("Reflection Amount", Range(0.0, 1.0)) = 0.5

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgonreProjector" = "True" }
        

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 worldViewDir : TEXCOORD3;
                float3 worldRefl : TEXCOORD4;
                float4 vertex : SV_POSITION;
            };

            samplerCUBE _CubeMap;
            float4 _CubeMap_ST;
            fixed3 _Color;
            fixed3 _ReflectColor;
            float _ReflectAmount;



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv.xy * _CubeMap_ST.xy + _CubeMap_ST.zw;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 reflection = texCUBE(_CubeMap, i.worldRefl).rgb * _ReflectColor.rgb;

                return fixed4(ambient + lerp(diffuse, reflection, _ReflectAmount) * atten, 1.0);
            }
            ENDCG
        }
    }
}
