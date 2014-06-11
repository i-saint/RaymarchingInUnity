using UnityEngine;
using System.Collections;

public class SceneSwitcher : MonoBehaviour {

	int scene = 0;

	void Start()
	{
		scene = 0;
		RenderSettings.skybox.SetInt("_Scene", scene);
	}

	void OnGUI()
	{
		if (GUI.Button(new Rect(10,10, 100, 30), "next scene"))
		{
			++scene;
			RenderSettings.skybox.SetInt("_Scene", scene);
		}
	}
}
