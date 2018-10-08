using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyAfterSeconds : MonoBehaviour {

    [SerializeField]
    float seconds = 1.0f;

	// Use this for initialization
	void Start () {
        StartCoroutine(Kill ());
	}

    IEnumerator Kill ( ){

        yield return new WaitForSeconds (seconds);
        Destroy (this.gameObject);
    }
	
}
