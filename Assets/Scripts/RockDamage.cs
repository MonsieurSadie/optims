using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RockDamage : MonoBehaviour
{
    float life = 100;
    ParticleSystem particles;

    void Start()
    {
    	particles = transform.GetComponentInChildren<ParticleSystem>();
    }

    void OnTriggerEnter(Collider other)
    {
    	if(other.tag == "Pig")
    	{
    		Debug.Log("Pig hit");
    		life -= 50;

    		if(life < 0)
    		{
				StartCoroutine(ExplodeThenDie());
    		}
    	}
    }


    IEnumerator ExplodeThenDie()
    {
    	Debug.Log("Exploding");

    	GetComponentInChildren<MeshRenderer>().enabled = false; // hide rock
    	particles.Play();

    	while(particles.isEmitting)
    	{
    		yield return null;
    	}
    	Destroy(this.gameObject);
    }
}
