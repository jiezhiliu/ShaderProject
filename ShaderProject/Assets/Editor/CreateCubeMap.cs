using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class CreateCubeMap : EditorWindow
{
    public Cubemap cubeMap;
    [MenuItem("GameObject/Create Cube Map")]
    public static void TestCreateCubeMap()
    {
        CreateCubeMap createCubeMap = (CreateCubeMap)EditorWindow.GetWindow(typeof(CreateCubeMap), false, "创建CubeMap", true);
        createCubeMap.Show();
        
       
    }

    private void OnGUI() {
        GUILayout.BeginVertical();
        GUILayout.Space(20);
        cubeMap = (Cubemap)EditorGUILayout.ObjectField(cubeMap, typeof(Cubemap), true);
        if(GUILayout.Button("创建"))
        {
            GameObject go = new GameObject("Camera");
            Camera tempCamera = go.AddComponent<Camera>();
            go.transform.position = Vector3.zero;
            go.transform.localScale = Vector3.one;
            go.transform.localRotation = Quaternion.identity;
            tempCamera.RenderToCubemap(cubeMap);
            DestroyImmediate(go);
        }
    }
}
