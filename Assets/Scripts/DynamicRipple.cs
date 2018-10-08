using UnityEngine;

public class DynamicRipple : MonoBehaviour {

	private Renderer thisRenderer;

	void GetRenderer() {
		if (thisRenderer == null) {
			thisRenderer = this.GetComponent<Renderer>();
		}
	}

	private void Start() {
		GetRenderer();
	}

	private void OnWillRenderObject() {
		GetRenderer();
		//if (DynamicRippleRenderer.instance != null) {
		//	DynamicRippleRenderer.instance.AddRenderer(thisRenderer);
		//}
	}

	/*
	private void OnEnable() {
		GetRenderer();
		if (DynamicRippleRenderer.instance != null) {
			DynamicRippleRenderer.instance.AddRenderer(thisRenderer);
		}
	}

	private void OnDisable() {
		GetRenderer();
		if (DynamicRippleRenderer.instance != null) {
			DynamicRippleRenderer.instance.RemoveRenderer(thisRenderer);
		}
	}
	*/

	// Update is called once per frame
	//void Update () {
	//    if (DynamicRippleRenderer.instance != null)
	//    {
	//        DynamicRippleRenderer.instance.ActiveRipples ();
	//    } 
	//}


}