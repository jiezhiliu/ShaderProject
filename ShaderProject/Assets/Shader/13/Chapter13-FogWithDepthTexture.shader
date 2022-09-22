Shader "MyShader/Chapter13-FogWithDepthTexture"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _FogDensity("Fog Density", Float) = 1.0
        _FogColor("Fog Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _FogStart("Fog Start", Float) = 0.0
        _FogStart("Fog End", Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;
            fixed4 _FogColor;
            float _FogStart;
            float _FogDensity;
            float _FogEnd;
            float4x4 _FrustumCornersRay;
        ENDCG

        Pass
        {
            ZTest Always
            ZWrite Off
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                half2 uv_depth : TEXCOORD1;
                float4 interpolatedRay : TEXCOORD2; 
                float4 vertex : SV_POSITION;
            };

           

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv_depth = v.uv;
                #if UNITY_UV_STARTS_AT_TOP
                    if(_MainTex_TexelSize.y < 0)
                        o.uv_depth.y = 1 - o.uv_depth.y;
                #endif
                int index = 0;
                if(v.uv.x < 0.5 && v.uv.y < 0.5)
                    index = 0;
                else if(v.uv.x > 0.5 && v.uv.y < 0.5)
                    index = 1;
                else if (v.uv.x > 0.5 && v.uv.y > 0.5)
                    index = 2;
                else
                    index = 3;
                
                #if UNITY_UV_STARTS_AT_TOP
                    if(_MainTex_TexelSize.y < 0)
                        index = 3 - index;
                #endif
                o.interpolatedRay = _FrustumCornersRay[index];
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));

                float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;
                float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
                fogDensity = saturate(fogDensity * _FogDensity);
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = lerp(col.rgb, _FogColor.rgb, fogDensity);
                return col;
            }
            ENDCG
        }
    }
}
