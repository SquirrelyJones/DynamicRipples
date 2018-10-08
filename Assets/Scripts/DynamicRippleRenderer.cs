using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DynamicRippleRenderer : MonoBehaviour
{
	public LayerMask layerMask;
	public int texSize = 2048;
	public float rippleDist = 64.0f;
    public Camera rippleCam;
	public RenderTexture targetTex;

    void Start() {
		CreateTexture();
		CreateCamera();
	}

	void CreateTexture() {
		targetTex = new RenderTexture(texSize, texSize, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear);
		targetTex.Create();
	}

	void CreateCamera() {
		rippleCam = this.gameObject.AddComponent<UnityEngine.Camera>(); // add a camera to this game object
		rippleCam.renderingPath = RenderingPath.Forward; // simple forward render path
		rippleCam.transform.rotation = Quaternion.Euler(90, 0, 0); // rotate the camera to face down
		rippleCam.orthographic = true; // the camera needs to be orthographic
		rippleCam.orthographicSize = rippleDist; // the area size that ripples can occupy
		rippleCam.nearClipPlane = 1.0f; // near clip plane doesn't have to be super small
		rippleCam.farClipPlane = 500.0f; // generous far clip plane
		rippleCam.depth = -10; // make this camera render before everything else
		rippleCam.targetTexture = targetTex; // set the target to the render texture we created
		rippleCam.cullingMask = layerMask; // only render the "Ripples" layer
		rippleCam.clearFlags = CameraClearFlags.SolidColor; // clear the texture to a solid color each frame
		rippleCam.backgroundColor = new Color(0.5f, 0.5f, 0.5f, 0.5f); // the ripples are rendered as overlay so clear to grey
		rippleCam.enabled = true;
	}

	void OnEnable() {
        Shader.EnableKeyword("DYNAMIC_RIPPLES_ON");
    }

    void OnDisable() {
        Shader.DisableKeyword("DYNAMIC_RIPPLES_ON");
    }	

	void LateUpdate() {

		Vector3 newPos = Vector3.zero;
		Vector3 viewOffset = Vector3.zero;

		if (Camera.main != null) {
			newPos = Camera.main.transform.position;
			viewOffset = newPos + Camera.main.transform.forward * rippleDist * 0.5f;
		}

        newPos.x = viewOffset.x;
        newPos.z = viewOffset.z;
        newPos.y += 250.0f;
        float mulSizeRes = (float)texSize / ( rippleDist * 2f );
        newPos.x = Mathf.Round (newPos.x * mulSizeRes) / mulSizeRes;
        newPos.z = Mathf.Round (newPos.z * mulSizeRes) / mulSizeRes;
        this.transform.position = newPos;
        this.transform.rotation = Quaternion.Euler(90, 0, 0);

        Shader.SetGlobalTexture ("_DynamicRippleTexture", targetTex);
        Shader.SetGlobalMatrix ("_DynamicRippleMatrix", rippleCam.worldToCameraMatrix);
        Shader.SetGlobalFloat ("_DynamicRippleSize", rippleCam.orthographicSize);

	}
}