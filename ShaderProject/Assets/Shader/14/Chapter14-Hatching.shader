Shader "MyShader/Chapter14-Hatching"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _TileFactor ("Tile Factor", Float) = 1
        _Outline ("Outline", Range(0, 1)) = 0.1
        _Hatch0 ("Hatch 0", 2D) = "white" {}
        _Hatch1 ("Hatch 1", 2D) = "white" {}
        _Hatch2 ("Hatch 2", 2D) = "white" {}
        _Hatch3 ("Hatch 3", 2D) = "white" {}
        _Hatch4 ("Hatch 4", 2D) = "white" {}
        _Hatch5 ("Hatch 5", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}
        UsePass "MyShader/Chapter14-ToonShading/OUTLINE"

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed3 hatchWeights0 : TEXCOORD1;
                fixed3 hatchWeights1 : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            sampler2D _Hatch0;
            sampler2D _Hatch1;
            sampler2D _Hatch2;
            sampler2D _Hatch3;
            sampler2D _Hatch4;
            sampler2D _Hatch5;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _TileFactor;
            float _Outline;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv.xy * _TileFactor;

                fixed3 worldlightDir = normalize(WorldSpaceLightDir(v.vertex));
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed diff = max(o ,dot(worldlightDir, worldNormal));

                o.hatchWeights0 = fixed3(0, 0, 0);
                o.hatchWeights1 = fixed3(0, 0, 0);

                float hatchFactor = diff * 7.0;
                if(hatchFactor < 6)
                {
                    if(hatchFactor > 5.0)
                        o.hatchWeights0.x = hatchFactor - 5.0;
                    else if(hatchFactor > 4.0)
                    {
                        o.hatchWeights0.x = hatchFactor - 4.0;
                        o.hatchWeights0.y = 1.0 - o.hatchWeights0.x;
                    }
                    else if(hatchFactor > 3.0)
                    {
                        o.hatchWeights0.y = hatchFactor - 3.0;
                        o.hatchWeights0.z = 1.0 - o.hatchWeights0.y;
                    }
                    else if(hatchFactor > 2.0)
                    {
                        o.hatchWeights0.z = hatchFactor - 2.0;
                        o.hatchWeights1.x = 1.0 - o.hatchWeights0.z;
                    }
                    else if(hatchFactor > 1.0)
                    {
                        o.hatchWeights1.x = hatchFactor - 1.0;
                        o.hatchWeights1.y = 1.0 - o.hatchWeights1.x;
                    }
                    else 
                    {
                        o.hatchWeights1.y = hatchFactor;
                        o.hatchWeights1.z = 1.0 - o.hatchWeights1.y;
                    }
                }
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
