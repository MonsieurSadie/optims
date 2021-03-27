using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TerrainsGenerator : MonoBehaviour
{
	public int numTerrainX = 1;
	public int numTerrainZ = 1;
	public TerrainData terrainBaseData;
	List<Terrain> terrainBuffer = new List<Terrain>();

	[ContextMenu("CreateTerrains")]
	void CreateTerrains()
	{
		DeleteTerrains();

		float terrainWidth = terrainBaseData.size.x;
		float terrainDepth = terrainBaseData.size.z;

		for(int i=0; i<numTerrainX; i++)
		{
			for(int j=0; j<numTerrainZ; j++)
			{
				GameObject go = Terrain.CreateTerrainGameObject(terrainBaseData);
				terrainBuffer.Add(go.GetComponent<Terrain>());

				go.transform.position = new Vector3(i*terrainWidth, 0, j*terrainDepth);
				go.transform.parent = this.transform;
			}
		}
	}

	public float perlinSize = 0.5f;
	public float maxHeight = 0.5f;
	[ContextMenu("GenerateRandomTerrainData")]
	void GenerateRandomTerrainData()
	{
		int res = terrainBaseData.heightmapResolution;
		float[,] data = new float[res,res];
		for(int i=0; i<res; i++)
		{
			for(int j=0; j<res; j++)
			{
				data[i,j] = Mathf.PerlinNoise(i*perlinSize, j*perlinSize) * maxHeight;
			}

		}
		terrainBuffer[0].terrainData.SetHeights(0,0,data);
	}	

	[ContextMenu("DeleteTerrains")]
	void DeleteTerrains()
	{
		for(int i=0; i<terrainBuffer.Count; i++)
		{
			if(terrainBuffer[i] != null) DestroyImmediate(terrainBuffer[i].gameObject);
		}
		terrainBuffer.Clear();
	}
}
