using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterInteractor : MonoBehaviour {

	public float threshold = 0.1f;
	public ParticleSystem ripplesParticle;
	public GameObject splashPrefab;
	public GameObject jumpPrefab;

	bool underwater = false;

	public float acc = 50.0f;
	public float maxSpeed = 5.0f;
	public float jumpSpeed = 10.0f;
	public float boyancy = 20.0f;
	public float drag = 5.0f;

	private Vector3 velocity = Vector3.zero;

	// Use this for initialization
	void Start () {
		if(this.transform.position.y < -threshold) {
			underwater = true;
		}
	}
	
	// Update is called once per frame
	void Update () {

		// Add gravity
		velocity.y -= 9.8f * Time.deltaTime;

		Vector3 moveDir = Vector3.zero;

		//moveDir.x += Input.GetKey(KeyCode.LeftArrow) ? 1.0f : 0.0f;
		//moveDir.x += Input.GetKey(KeyCode.RightArrow) ? -1.0f : 0.0f;
		//moveDir.z += Input.GetKey(KeyCode.UpArrow) ? -1.0f : 0.0f;
		//moveDir.z += Input.GetKey(KeyCode.DownArrow) ? 1.0f : 0.0f;

		moveDir.x += Input.GetKey(KeyCode.A) ? 1.0f : 0.0f;
		moveDir.x += Input.GetKey(KeyCode.D) ? -1.0f : 0.0f;
		moveDir.z += Input.GetKey(KeyCode.W) ? -1.0f : 0.0f;
		moveDir.z += Input.GetKey(KeyCode.S) ? 1.0f : 0.0f;

		moveDir.Normalize();

		Vector3 flatVelocity = velocity;
		flatVelocity.y = 0f;

		float accCoef = 1.0f - Mathf.Clamp01( flatVelocity.magnitude / maxSpeed ) * Vector3.Dot(flatVelocity, moveDir);
		velocity += moveDir * acc * accCoef * Time.deltaTime;

		if (underwater) {

			// jump
			if (Input.GetKeyDown(KeyCode.Space)) {
				velocity.y = jumpSpeed;
				Vector3 surfacePos = this.transform.position;
				surfacePos.y = 0f;
				Instantiate(jumpPrefab, surfacePos, Quaternion.identity);
			}

			// add drag
			velocity -= velocity * drag * Time.deltaTime;

			// add boyancy
			velocity.y += Mathf.Clamp01(-this.transform.position.y) * boyancy * Time.deltaTime;

			// turn off ripples
			if (this.transform.position.y > threshold) {
				underwater = false;
				ripplesParticle.Stop();
			}
		} else {
			// turn on ripples
			if (this.transform.position.y < -threshold) {
				underwater = true;
				ripplesParticle.Play();
				Vector3 surfacePos = this.transform.position;
				surfacePos.y = 0f;
				Instantiate(splashPrefab, surfacePos, Quaternion.identity);
			}
		}

		this.transform.position += velocity * Time.deltaTime;
	}
}
