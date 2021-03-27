// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/CellShading"
{
	Properties
	{
		_ASEOutlineColor( "Outline Color", Color ) = (0,0,0,0)
		_ASEOutlineWidth( "Outline Width", Float ) = 0.02
		_DiffuseLightColor("DiffuseLightColor", Color) = (0,0,0,0)
		_DiffuseDarkColor("DiffuseDarkColor", Color) = (0,0,0,0)
		_DiffuseThreshold("DiffuseThreshold", Range( 0 , 1)) = 0.1714574
		_SpecularColor("SpecularColor", Color) = (0,0,0,0)
		_SpecularWidth("SpecularWidth", Range( 0 , 1)) = 0.5
		_SpecularStrength("SpecularStrength", Float) = 10
		_RimColor("RimColor", Color) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		float4 _ASEOutlineColor;
		float _ASEOutlineWidth;
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += ( v.normal * _ASEOutlineWidth );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _ASEOutlineColor.rgb;
			o.Alpha = 1;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		ZWrite On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float3 viewDir;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _DiffuseLightColor;
		uniform float _DiffuseThreshold;
		uniform float4 _DiffuseDarkColor;
		uniform float _SpecularWidth;
		uniform float _SpecularStrength;
		uniform float4 _SpecularColor;
		uniform float4 _RimColor;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float dotResult4 = dot( ase_worldlightDir , ase_normWorldNormal );
			float temp_output_16_0 = step( _DiffuseThreshold , dotResult4 );
			float3 lightBounceDir110 = reflect( -ase_worldlightDir , ase_worldNormal );
			float dotResult26 = dot( lightBounceDir110 , i.viewDir );
			float dotResult47 = dot( ( 1.0 - i.viewDir ) , ase_worldNormal );
			float smoothstepResult56 = smoothstep( 0.45 , 0.55 , max( dotResult47 , 0.0 ));
			c.rgb = ( ( ( _DiffuseLightColor * temp_output_16_0 ) + ( ( 1.0 - temp_output_16_0 ) * _DiffuseDarkColor ) ) + ( step( _SpecularWidth , pow( max( dotResult26 , 0.0 ) , _SpecularStrength ) ) * _SpecularColor ) + ( smoothstepResult56 * _RimColor ) ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
0;0;1920;1139;1642.814;589.1113;1;False;False
Node;AmplifyShaderEditor.CommentaryNode;43;-1983.603,781.7311;Inherit;False;2764.989;863.2671;réflections du toon shading;3;114;42;29;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-1933.603,831.7311;Inherit;False;971.3311;811.753;Calcul de la valeur de réflection : view dir DOT light bounce. On voit une réflection quand la lumière illumine une surface et qu'elle est renvoyée vers notre oeil.;3;106;109;110;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;106;-1916.077,907.9038;Inherit;False;694.3309;389.5858;Direction du rebond de la lumière : réflection de l'angle d'arrivée de la lumière par rapport à la normale du vertex;4;24;25;18;17;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;17;-1895.653,958.9992;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;18;-1857.954,1115.584;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;25;-1654.177,1012.043;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;15;-1463.366,-698.9222;Inherit;False;2193.238;1275.432;;8;105;103;104;6;102;34;97;1;Partie diffuse du shader;1,1,1,1;0;0
Node;AmplifyShaderEditor.ReflectOpNode;24;-1533.322,1014.467;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-1167.502,1103.797;Inherit;False;lightBounceDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;54;-660.9242,1888.579;Inherit;False;1385.777;639;le principe du rim lighting est d'imaginer qu'une lumière arrive dans la direction opposée au regard. L'objet que l'on regarde est donc entre le regard et cette lumière. . La lumière ne va donc éclairer que les bords de l'objet. Pour réaliser cet effet, pas besoin de lumière, il suffit de regarder si les normales des vertex sont alignées avec le regard.;7;48;49;46;53;56;45;55;Rim Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;109;-1484.865,1309.354;Inherit;False;477.3453;304;on calcule maintenant l'alignement entre la vue et la direction de la réflection de lumière;3;111;26;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;42;-895.8444,836.7604;Inherit;False;1264.039;784.1919;Tweaking specular : généralement on veut du contrôle sur la taille du halo de réflection, pour pouvoir notamment imiter différents matériaux, plus ou moins réfléchissants;3;30;113;112;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;97;-1395.108,-264.8556;Inherit;False;463.7386;371.8541;Compute light phong (light dot vertex normal). givex black if vertex points perpendicular to light or in opposite direction;3;4;3;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-1384.555,-208.7573;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;112;-883.8446,973.7606;Inherit;False;696.0001;480.022;Ici on va utiliser une node power (une courbe exponentielle) afin de diminuer la taille (une courbe exponentielle, par rapport à une courbe linéaire va abaisser les valeurs vers 0 sur la première moitié de la courbe). Plus la valeur de puissance est élevée, plus l'effet est prononcé.;2;32;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-1459.62,1344.584;Inherit;False;110;lightBounceDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;46;-567.8219,2066.184;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;27;-1452.95,1412.22;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;3;-1317.119,-64.77326;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;4;-1144.061,-156.0974;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;115;-615.8219,2002.183;Inherit;False;611.6436;404.2839;Alignement Regard - Normale du vertex/pixel;1;47;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;102;-490.1363,-375.8357;Inherit;False;285;303.9999;On filtre en ne laissant passer que les pixels qui sont illuminés (>threshold. Ce dernier permet de piloter la quantité de pixels que l'on considère illuminés));1;16;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-804.2396,-324.0266;Inherit;False;Property;_DiffuseThreshold;DiffuseThreshold;3;0;Create;True;0;0;0;False;0;False;0.1714574;0.551;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;26;-1232.318,1376.224;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;48;-583.8219,2242.184;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;49;-391.8219,2146.184;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;32;-849.1192,1020.407;Inherit;False;325;299;Remove the parts where dot produces -1;1;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StepOpNode;16;-440.1364,-325.8357;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;104;-474.7436,-25.00091;Inherit;False;646.9196;491.2513;On inverse la texture avec One Minus pour faire de même pour la partie ombrée (ce qui était en noir devient blanc et on peut ainsi le coloriser);3;13;7;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;113;-168.3632,977.3825;Inherit;False;520.9371;476.5554;encoreune fois, on ne veut pas de dégradé afin d'avoir notre effet cartoon (donc step pour appliquer un masque);3;39;19;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;47;-247.822,2146.184;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-753.1192,1340.406;Inherit;False;Property;_SpecularStrength;SpecularStrength;6;0;Create;True;0;0;0;False;0;False;10;3.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;31;-769.1192,1068.407;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-401.7223,-574.0787;Inherit;False;Property;_DiffuseLightColor;DiffuseLightColor;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.8117647,0.2196078,0.5421416,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-149.1821,1024.09;Inherit;False;Property;_SpecularWidth;SpecularWidth;5;0;Create;True;0;0;0;False;0;False;0.5;0.265;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;30;-481.1191,1164.406;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;55;9.216101,2113.044;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;-424.7436,254.2504;Inherit;False;Property;_DiffuseDarkColor;DiffuseDarkColor;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2830189,0.02002492,0.2192627,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;103;-128.7291,-483.241;Inherit;False;285;304;On multiplie par la couleur de diffuse  Tous les pixels illuminés étant blancs grâce à la précédente opération, on obtient alors l"aspect carton propre au cell shading;1;94;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;14;-381.1139,24.99914;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;119;-1436.333,-1807.133;Inherit;False;1868.112;733.5538;;4;139;137;124;120;Diffuse avec texture de ramp;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-62.82412,36.74741;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;45;215.822,2281.091;Inherit;False;Property;_RimColor;RimColor;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;56;183.822,2041.091;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.45;False;2;FLOAT;0.55;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;105;363.5903,-256.899;Inherit;False;285;304;On ajoute les deux parties pour obtenir notre cell shading;1;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-78.72907,-433.2411;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;36;131.2462,1044.671;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;132.2438,1277.459;Inherit;False;Property;_SpecularColor;SpecularColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.5471698,0.2348701,0.4874092,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;114;450.6191,1086.53;Inherit;False;285;304;Et on multiplie enfin par la couleur que l'on veut pour la réflection;1;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;117;1287.828,1029.104;Inherit;False;286;304;On additionne toutes les composantes de notre toon shader;1;44;Chocapics;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;120;-1368.792,-1723.537;Inherit;False;463.7386;371.8541;Compute light phong (light dot vertex normal). givex black if vertex points perpendicular to light or in opposite direction;3;123;122;121;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;413.5903,-206.899;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;137;-259.2213,-1625.185;Inherit;False;602.3113;459.7147;LIGHT RAMP;3;141;140;138;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;450.101,2152.797;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;500.6191,1136.529;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;34;-876.0635,-214.4117;Inherit;False;325;299;Remove the parts where dot produces -1 (clamp* [-1, 1] to [0,1];1;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;124;-849.7469,-1673.093;Inherit;False;325;299;Remove the parts where dot produces -1 (clamp* [-1, 1] to [0,1];1;126;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;35;-809.3511,-155.241;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;141;-145.3545,-1379.029;Inherit;False;Property;_DiffuseLightColor2;DiffuseLightColor;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.8117647,0.2196078,0.5421416,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;44;1337.828,1079.104;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;121;-1358.239,-1667.438;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;122;-1290.803,-1523.454;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;123;-1117.745,-1614.779;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;126;-783.0346,-1613.922;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;139;-458.4504,-1614.014;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;138;-217.7573,-1573.052;Inherit;True;Property;_LightRamp2;LightRamp;8;0;Create;True;0;0;0;False;0;False;-1;823623045450c994ea01e781cd95f9ef;823623045450c994ea01e781cd95f9ef;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;99.58826,-1572.839;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1732.867,840.9333;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Custom/CellShading;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;True;0.02;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;116;119.822,1993.091;Inherit;False;551.3329;486.4143;Encore une fois, on utilise un step (ici avec un léger dégradé entre le blanc et le noir) pour que notre rim soit "tooné";0;;1,1,1,1;0;0
WireConnection;25;0;17;0
WireConnection;24;0;25;0
WireConnection;24;1;18;0
WireConnection;110;0;24;0
WireConnection;4;0;2;0
WireConnection;4;1;3;0
WireConnection;26;0;111;0
WireConnection;26;1;27;0
WireConnection;49;0;46;0
WireConnection;16;0;6;0
WireConnection;16;1;4;0
WireConnection;47;0;49;0
WireConnection;47;1;48;0
WireConnection;31;0;26;0
WireConnection;30;0;31;0
WireConnection;30;1;28;0
WireConnection;55;0;47;0
WireConnection;14;0;16;0
WireConnection;13;0;14;0
WireConnection;13;1;7;0
WireConnection;56;0;55;0
WireConnection;94;0;1;0
WireConnection;94;1;16;0
WireConnection;36;0;39;0
WireConnection;36;1;30;0
WireConnection;11;0;94;0
WireConnection;11;1;13;0
WireConnection;53;0;56;0
WireConnection;53;1;45;0
WireConnection;41;0;36;0
WireConnection;41;1;19;0
WireConnection;35;0;4;0
WireConnection;44;0;11;0
WireConnection;44;1;41;0
WireConnection;44;2;53;0
WireConnection;123;0;121;0
WireConnection;123;1;122;0
WireConnection;126;0;123;0
WireConnection;139;0;126;0
WireConnection;138;1;139;0
WireConnection;140;0;138;0
WireConnection;140;1;141;0
WireConnection;0;13;44;0
ASEEND*/
//CHKSM=B795F5B0AA77D24A861CE1B42C4AC3438913D7B9