Shader "MyShader/DebugShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"


            struct v2f
            {
                // float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                fixed3 color : COLOR0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // UNITY_TRANSFER_FOG(o,o.vertex);

                // 可视化法线方向
                // o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);

                // 可视化切线方向
                // o.color = v.tangent * 0.5 + fixed3(0.5, 0.5, 0.5); 

                // 可视化副切线方向
                // fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                // o.color = binormal * 0.5 + fixed3(0.5, 0.5, 0.5);

                // 可视化第一组纹理坐标
                // o.color = fixed3(v.texcoord.xy, 0.0);

                // 可视化第二组纹理坐标
                // o.color = fixed3(v.texcoord1.xy, 0.0);

                // 可视化第一组纹理坐标小数部分
                // o.color = frac(v.texcoord);
                // if(any(saturate(v.texcoord) - v.texcoord))
                // {
                //     o.color.b = 0.5;
                // }

                // 可视化第二组纹理坐标的小数部分
                // o.color = frac(v.texcoord1);
                // if(any(saturate(v.texcoord1)- v.texcoord1))
                // {
                //     o.color.b = 0.5;
                // }

                // 可视化顶点颜色
                o.color = v.color.rgb;


                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                // return col;

                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
}
