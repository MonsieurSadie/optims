using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PigMover : MonoBehaviour
{
	Vector3 velocity;
	float maxSpeed = 10;
	float accel = 5;
	float rotSpeed = 180;

	float neighbourAreaSize = 3;

    void Start()
    {
        
    }

    void Update()
    {
    	Vector3 dir = Camera.main.transform.position - transform.position;
    	velocity += Vector3.ClampMagnitude(dir.normalized * accel * Time.deltaTime, maxSpeed);
      // try to go towards camera
      transform.position += velocity * Time.deltaTime;
      // orient towards movement dir
      Quaternion targetRot = Quaternion.LookRotation(dir.normalized, Vector3.up);
      transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRot, rotSpeed * Time.deltaTime);

      // check if we have neighbours
      Collider[] hits =  Physics.OverlapSphere(transform.position, neighbourAreaSize);

      Vector3 neighboursCenter = Vector3.zero;
      int numNeighbours = 0;
      for(int i = 0; i < hits.Length; i++)
      {
      	if(hits[i].gameObject.tag == "Pig")
      	{
      		neighboursCenter += hits[i].transform.position;
      		numNeighbours++;
      	}
      }
      if(numNeighbours > 0)
      {
      	neighboursCenter /= numNeighbours;
      	// go away from them !
        Vector3 neighboursDir = neighboursCenter - transform.position;
        velocity += -neighboursDir * 1;
      }
    }

    void OnDrawGizmos()
    {
      Gizmos.color = Color.red;
      Gizmos.DrawWireSphere(transform.position, neighbourAreaSize);
    }
}
