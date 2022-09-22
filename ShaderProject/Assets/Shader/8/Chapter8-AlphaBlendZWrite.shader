// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "MyShader/Chapter8-AlphaBlendZWrite"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Main Tex", 2D) = "white" {}
        _AlphaScale ("AlphaScale", Range(0, 1)) = 0.5

    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "true" "RenderType"="transparent" }
        Pass
        {
            ZWrite On
            ColorMask 0 
        }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            // Cull Off
            ZWrite Off
            // 正常，透明度混合
            Blend SrcAlpha OneMinusSrcAlpha
            // 柔和相加
            // Blend OneMinusDstColor One
            // 正片叠底
            // Blend DstColor Zero
            // 两倍相乘
            // Blend DstColor SrcColor
            // 变暗
            // BlendOp Min
            // Blend One One 
            // 变亮
            // BlendOp Max
            // Blend One One
            // 滤色
            // Blend OneMinusDstColor  One
            // 线性减淡
            // Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed3 _Color;
            float _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);

                fixed3 albedo = _Color.rgb * texColor.rgb;
                fixed3 diffuse = _LightColor0.rgb * saturate(dot(worldNormal, worldLightDir)) * albedo;

                return fixed4(texColor.rgb, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
}
