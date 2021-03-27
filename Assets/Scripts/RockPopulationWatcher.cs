using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RockPopulationWatcher : MonoBehaviour
{
	public int maxRocks = 1000;

    void Update()
    {
    	// count rocks
    	Rock[] rocks = FindObjectsOfType<Rock>();

    	if(rocks.Length < maxRocks)
    	{
    		Debug.Log("not enough rocks, creating some");
    		ObjectGenerator rocksGenerator = GameObject.Find("ROCKS").GetComponent<ObjectGenerator>();
    		rocksGenerator.Generate(10);
    	}
        
    }
}
