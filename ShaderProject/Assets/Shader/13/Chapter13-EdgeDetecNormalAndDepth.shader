Shader "MyShader/Chapter13-EdgeDetecNormalAndDepth"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _EdgeOnly ("Edge Only", Float) = 1.0
        _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
        _BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
        _SampleDistance ("Sample Distance", Float) = 0.05
        _Sensitivity ("Sensitivity", Vector) = (1, 1, 1, 1)
    }
    SubShader
    {
        ZTest Always
        ZWrite Off
        Cull Off

        CGINCLUDE
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            float _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;
            float _SampleDistance;
            half4 _Sensitivity;
            sampler2D _CameraDepthNormalsTexture;

        ENDCG
        Pass
        {
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
                half2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            half CheckSame(half4 center, half4 sample2)
            {
                half2 centerNormal = center.xy;
                float centerDepth = DecodeFloatRG(center.zw);
                half2 sampleNormal = sample2.xy;
                float sampleDepth = DecodeFloatRG(sample2.zw);

                half2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity.x;
                int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
                float diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;
                int isSameDepth = diffDepth < 0.1 * centerDepth;

                return isSameNormal * isSameDepth ? 1.0 : 0.0;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;
                o.uv[0] = uv;
                
                #if UNITY_UV_STARTS_AT_TOP
                    if(_MainTex_TexelSize.y < 0)
                        uv.y = 1 - uv.y;
                #endif

                o.uv[1] = uv + _MainTex_TexelSize.xy + half2(1, 1) * _SampleDistance;
                o.uv[2] = uv + _MainTex_TexelSize.xy + half2(-1, -1) * _SampleDistance;
                o.uv[3] = uv + _MainTex_TexelSize.xy + half2(-1, 1) * _SampleDistance;
                o.uv[4] = uv + _MainTex_TexelSize.xy + half2(1, -1) * _SampleDistance;

                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                half4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
                half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
                half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
                half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

                half edge = 1.0;
                edge *= CheckSame(sample1, sample2);
                edge *= CheckSame(sample3, sample4);

                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }

            ENDCG
        }
    }
}
