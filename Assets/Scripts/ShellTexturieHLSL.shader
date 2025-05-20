Shader "Custom/ShellTextureHLSL"
{
    Properties
    {
        _BottomColor ("Bottom Color", Color) = (1, 1, 1, 1)
        _TipColor ("Tip Color", Color) = (1, 1, 1, 1)
        _Density ("Density", float) = 50
        _Height ("Height", float) = 1
        _SwayOffset ("Sway Offset", Vector) = (1, 1, 0, 0)
        _SwaySpeed ("Sway Speed", float) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            Cull off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float lerpValue : TEXCOORD1;
            };

            uniform float4 _BottomColor;
            uniform float4 _TipColor;
            uniform float _Density;
            uniform float _Height;
            uniform float2 _SwayOffset;
            uniform float _SwaySpeed;
            uniform float _LayerIndex[1023];

            float random(float2 uv)
            {
                return frac(dot(uv, float2(12.9898, 78.233)) * 43758.5453123);
            }

            float3 ObjectScale()
            {
                return float3(
                    length(unity_ObjectToWorld._m00_m10_m20),
                    length(unity_ObjectToWorld._m01_m11_m21),
                    length(unity_ObjectToWorld._m02_m12_m22)
                );
            }

            v2f vert(appdata v, uint instanceID: SV_InstanceID)
            {
                UNITY_SETUP_INSTANCE_ID(v);

                v2f o;
                float lerpValue = 0.5;

                #ifdef UNITY_INSTANCING_ENABLED
                lerpValue = _LayerIndex[instanceID];
                #endif

                float yOffset = _Height * lerpValue;
                float3 scale = ObjectScale();

                float swayFactor = (sin(_Time.y * _SwaySpeed) + 1.0) * 0.5;
                float lerpValueCubed = lerpValue * lerpValue * lerpValue;
                float3 swayOffset = float3(_SwayOffset.x, 1, _SwayOffset.y) * float3(1.0 / scale.x, 0.0, 1.0 / scale.z);

                float3 pos = v.vertex + swayFactor * lerpValueCubed * swayOffset + v.normal * yOffset;

                float4 lerpedColor = lerp(_BottomColor, _TipColor, lerpValue);

                o.pos = UnityObjectToClipPos(pos);
                o.color = v.color * lerpedColor;  
                o.uv = v.uv;                      
                o.lerpValue = lerpValue;          

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float2 scaledUV = i.uv * _Density;

                float2 flooredUV = floor(scaledUV) / _Density;

                float rand = random(flooredUV);

                float steppedRandom = step(i.lerpValue, rand);
                if (rand == 0 || steppedRandom < 0.5)
                    discard;

                float2 fracUV = frac(scaledUV) * 2.0 - 1.0;
                float radius = 1.0 - i.lerpValue / rand;

                if (dot(fracUV, fracUV) > radius * radius)
                    discard;

                return half4(steppedRandom, steppedRandom, steppedRandom, 1.0) * i.color * i.lerpValue;
            }

            ENDCG
        }
    }

    FallBack "Diffuse"
}
