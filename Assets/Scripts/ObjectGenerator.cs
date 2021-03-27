using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ObjectGenerator : MonoBehaviour
{
    public GameObject prefab;
    public int numEntities;
    public Vector3 spawnArea = new Vector3(20, 1, 20);

    [ContextMenu("Generate")]
    void Generate()
    {
    	Generate(numEntities);
    }

    public void Generate(int num)
    {
      for(int i=0; i<num; i++)
      {
         GameObject go = PrefabUtility.InstantiatePrefab(prefab) as GameObject;
         go.transform.position = new Vector3(
            transform.position.x + Random.Range(-spawnArea.x, spawnArea.x),
            transform.position.y + Random.Range(-spawnArea.y, spawnArea.y),
            transform.position.z + Random.Range(-spawnArea.z, spawnArea.z)
          );
         go.transform.parent = this.transform;
      }
    }

    void OnDrawGizmos()
    {
    	Gizmos.DrawWireCube(transform.position, spawnArea);
    }
}
