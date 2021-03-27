using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RockAction : MonoBehaviour
{
	float startHeight;
	float speed;
	float timer;
	float timerTarget = 2;

    void Start()
    {
    	startHeight = transform.position.y;    
    	speed = Random.Range(1f, 7f);
    }

    
    void Update()
    {
		// do a sin
		transform.position = new Vector3(transform.position.x,
										 startHeight + Mathf.Sin(speed * Time.time) * 0.1f,
										 transform.position.z);

		timer += Time.deltaTime;
		if(timer > timerTarget)
		{
			Debug.Log("doing timed action");
    		timer = 0;
		}
    }
}
