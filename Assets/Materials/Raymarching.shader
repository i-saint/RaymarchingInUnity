Shader "Custom/Raymarching" {

Properties {
	_Aspect ("Aspect", Float) = 1.0
}
SubShader {
	Tags { "RenderType"="Opaque" }

	CGINCLUDE
	float _Aspect;

	#include "UnityCG.cginc"
	#include "Raymarching.cginc"

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
		return main(pos.xy);
		//return float4(abs(pos.xxx), 1.0);
	}
	ENDCG

	Pass {
		CGPROGRAM
		#pragma target 3.0
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
	}
} 

}
