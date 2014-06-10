Shader "Custom/DistanceFunctions" {

Properties {
	_BaseColor ("BaseColor", Color) = (0.15, 0.15, 0.2, 1.0)
	_GlowColor ("GlowColor", Color) = (0.75, 0.75, 1.0, 1.0)
}
SubShader {
	Tags { "RenderType"="Opaque" }

	CGINCLUDE
	#pragma target 3.0
	#include "UnityCG.cginc"

	float4 _BaseColor;
	float4 _GlowColor;
	#include "Scene1.cginc"

	struct appdata_t {
		float4 vertex : POSITION;
	};
	struct v2f {
		float4 vertex : SV_POSITION;
		float4 spos : TEXCOORD0;
	};
	
	v2f vert (appdata_t v)
	{
		v2f o;
		o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
		o.spos = o.vertex;
		return o;
	}
	float4 frag (v2f i) : SV_Target
	{
		float4 pos = i.spos / i.spos.w;
		return Scene1(pos.xy);
	}
	ENDCG

	Pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
	}
} 

}
