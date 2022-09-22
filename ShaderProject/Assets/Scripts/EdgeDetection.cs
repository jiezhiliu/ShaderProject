using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial;
    [Range(0, 3)]
    public float edgesOnly = 0.0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    public Material material 
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }
    private void OnRenderImage(RenderTexture src, RenderTexture dest) 
    {
        if(material != null)
        {
            material.SetFloat("_EdgesOnly", edgesOnly);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetColor("_EdgeColor", edgeColor);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
