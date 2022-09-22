Shader "MyShader/Chapter12-GaussianBlur"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
        ZTest Always
        ZWrite Off
        Cull Off

        CGINCLUDE
            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            float _BlurSize;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            fixed4 fragBlur (v2f i) : SV_Target
            {
                float weight[3] = {0.4026, 0.2442, 0.0545};
                fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
                for (int j = 1; j < 3; j++)
                {
                    sum += tex2D(_MainTex, i.uv[j]).rgb * weight[j];
                    sum += tex2D(_MainTex, i.uv[2 * j]).rgb * weight[j]; 
                }
                return fixed4(sum, 1.0);
            }
        ENDCG

       

        // 竖直
        Pass
        {
            NAME "GAUSSIAN_BLUR_VERTICAL"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragBlur

            #include "UnityCG.cginc"

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;
                o.uv[0] = uv;
                o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
                o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;

                return o;
            }
            ENDCG
        }

        // 水平
        Pass
        {
            NAME "GAUSSIAN_BLUR_HORIZONTAL"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragBlur
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;
                o.uv[0] = uv;
                o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.x * 1.0) * _BlurSize;
                o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.x * 1.0) * _BlurSize;
                o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.x * 2.0) * _BlurSize;
                o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.x * 2.0) * _BlurSize;
                
                return o;
            }
            ENDCG
        }
    }
}
