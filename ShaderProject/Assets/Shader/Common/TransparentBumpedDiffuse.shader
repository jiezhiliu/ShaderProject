// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "MyShader/TransparentBumpedDiffuse"
{
    Properties
    {
        _Color ("Base(RGB Trans(A))", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpTex ("Normal Map", 2D) = "bump" {}
        _BumpScale ("BumpScale", Float) = 1.0
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" }
        

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;

            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 T0 : TEXCOORD1;
                float4 T1 : TEXCOORD2;
                float4 T2 : TEXCOORD3;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            float _BumpScale;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.uv.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;

                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                fixed3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                o.T0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.T1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.T2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldPos = fixed3(i.T0.w, i.T1.w, i.T2.w);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpTex, i.uv.zw));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                tangentNormal = normalize(half3(dot(i.T0.xyz, tangentNormal), dot(i.T1.xyz, tangentNormal), dot(i.T2.xyz, tangentNormal)));
                // sample the texture
                fixed4 texColor = tex2D(_MainTex, i.uv);
                fixed3 albedo = _Color.rgb * texColor.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, worldLightDir));

                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                return fixed4(ambient + diffuse * atten, texColor.a * _Color.a);
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            ZWrite Off

            Blend One One
            CGPROGRAM
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;

            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 T0 : TEXCOORD1;
                float4 T1 : TEXCOORD2;
                float4 T2 : TEXCOORD3;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            float _BumpScale;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.uv.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;

                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                fixed3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                o.T0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.T1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.T2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldPos = fixed3(i.T0.w, i.T1.w, i.T2.w);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpTex, i.uv.zw));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                tangentNormal = normalize(half3(dot(i.T0.xyz, tangentNormal), dot(i.T1.xyz, tangentNormal), dot(i.T2.xyz, tangentNormal)));
                // sample the texture
                fixed4 texColor = tex2D(_MainTex, i.uv);
                fixed3 albedo = _Color.rgb * texColor.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, worldLightDir));

                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                return fixed4(diffuse * atten, texColor.a * _Color.a);
            }
            ENDCG
        }
    }

}
