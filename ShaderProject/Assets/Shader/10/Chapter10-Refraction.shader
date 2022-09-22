Shader "MyShader/Chapter10-Refraction"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _CubeMap ("Refraction Cubemap", Cube) = "_Skybox" {}
        _RefractColor ("Refraction Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _RefractAmount ("Refraction Amount", Range(0.0, 1.0)) = 0.5
        _RefractRadio ("Refraction Radio", Range(0.1, 1.0)) = 0.5
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" }

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
                float normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 worldViewDir : TEXCOORD3;
                float3 worldRefr : TEXCOORD4;
                float4 vertex : SV_POSITION;
            };

            samplerCUBE _CubeMap;
            float4 _CubeMap_ST;
            fixed3 _Color;
            fixed3 _RefractColor;
            float _RefractRadio;
            float _RefractAmount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _CubeMap);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefr = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractRadio);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldViewDir = normalize(i.worldViewDir);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldLightDir, worldNormal));

                fixed3 refraction = texCUBE(_CubeMap, i.worldRefr).rgb * _RefractColor.rgb;
                
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4(ambient + lerp(diffuse, refraction, _RefractAmount) * atten, 1.0);
            }
            ENDCG
        }
    }
}
