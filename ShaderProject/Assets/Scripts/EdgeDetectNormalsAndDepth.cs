using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectNormalsAndDepth : PostEffectsBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial;
    [Range(0.01f, 1.0f)]
    public float edgesOnly = 0.0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    [Range(0.001f, 1.0f)]
    public float sampleDistance = 0.05f;
    [Range(0.001f, 1.0f)]
    public float sensitivityDepth = 0.01f;
    [Range(0.001f, 1.0f)]
    public float sensitivityNormals = 0.01f;
    public Material material
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);

            return edgeDetectMaterial;
        }
    }
    private void OnEnable() {
        transform.GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }


    [ImageEffectOpaque]
   private void OnRenderImage(RenderTexture src, RenderTexture dest) {
       if(material != null)
       {
           material.SetFloat("_EdgeOnly", edgesOnly);
           material.SetColor("_EdgeColor", edgeColor);
           material.SetColor("_BackgroundColor", backgroundColor);
           material.SetFloat("_SampleDistance", sampleDistance);
           material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));

           Graphics.Blit(src, dest, material);    
       }
       else
       {

           Graphics.Blit(src, dest);
       }
   }

}
