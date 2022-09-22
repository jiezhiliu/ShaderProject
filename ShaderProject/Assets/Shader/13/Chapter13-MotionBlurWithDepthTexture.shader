Shader "MyShader/Chapter13-MotionBlurWithDepthTexture"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TextelSize;
            sampler2D _CameraDepthTexture;
            float4x4 _CurrentViewProjectionInverseMatrix;
            float4x4 _PreviousViewProjectionMatrix;
            float _BlurSize;
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
                float2 uv_depth : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv_depth : TEXCOORD1;
                
                float4 vertex : SV_POSITION;
            };

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv_depth = v.uv_depth;

                #if UNITY_UV_STARTS_TOP
                    if(_MainTex_TextelSize.y < 0)
                        o.uv_depth.y = 1 - o.uv_depth.y;
                #endif 

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
                float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
                float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
                float4 worldPos = D / D.w;

                float4 currentPos = H;
                float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);

                previousPos /= previousPos.w;
                float2 velocity = (currentPos.xy - previousPos.xy) / 2.0;
                float2 uv = i.uv;

                fixed4 color = tex2D(_MainTex, uv);
                uv += velocity * _BlurSize;
                for (int j = 1; j < 3; j++, uv += velocity * _BlurSize) 
                {
                    fixed4 currentColor = tex2D(_MainTex, uv);
                    color += currentColor;
                }
               color /= 3;
               return fixed4(color.rgb, 1.0);
            }
            ENDCG
        }
    }
}
