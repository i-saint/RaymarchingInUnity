Shader "Custom/DistanceFunctions" {

Properties {
	_Scene ("Scene", Int) = 0
	_BaseColor ("BaseColor", Color) = (0.15, 0.15, 0.2, 1.0)
	_GlowColor ("GlowColor", Color) = (0.75, 0.75, 1.0, 1.0)
}
SubShader {
	Tags { "RenderType"="Opaque" }

	CGINCLUDE
	#pragma target 3.0
	#include "UnityCG.cginc"

	int _Scene;
	float4 _BaseColor;
	float4 _GlowColor;

	#include "GLSLCompat.cginc"
	#include "DistanceFunctions.cginc"
	#include "Scene1.cginc"
	#include "Scene2.cginc"
	#include "Scene3.cginc"
	#include "Scene4.cginc"

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
		float4 ret = float4(1,1,1,1);
		switch(_Scene%4) {
		case 0: ret=Scene1(pos.xy); break;
		case 1: ret=Scene2(pos.xy); break;
		case 2: ret=Scene3(pos.xy); break;
		case 3: ret=Scene4(pos.xy); break;
		}
		return ret;
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
