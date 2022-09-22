Shader "MyShader/Chapter12-Bloom"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Bloom ("Bloom (RGB)", 2D) = "black" {}
        _BlurSize ("Blur Size", Float) = 1.0
        _LuminanceThreshold ("Luminance Threshold", Float) = 0.5
    }
    SubShader
    {
        ZTest Always
        ZWrite Off
        Cull Off

        CGINCLUDE
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TextelSize;
            float _LuminanceThreshold;
            sampler2D _Bloom;
            float _BlurSize;
        ENDCG

        Pass
        {
            // 提取较亮区域
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            fixed luminance (fixed4 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed val = clamp(luminance(col) - _LuminanceThreshold , 0.0, 1.0);
                return col * val;
            }
            ENDCG
        }

        UsePass "MyShader/Chapter12-GaussianBlur/GAUSSIAN_BLUR_VERTICAL"

        UsePass "MyShader/Chapter12-GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"

        Pass
        {
            // 混合
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half4 uv : TEXCOORD0;
            };

            struct v2f
            {
                half4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv;
                o.uv.zw = v.uv;
                #if UNITY_UV_STARTS_TOP
                    if(_MainTex_TextelSize.y < 0.0)
                        o.uv.w = 1.0 - o.uv.w;
                #endif

                return o;
            }
            fixed luminance (fixed4 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
            }
            ENDCG
        }
    }
}
