using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture : PostEffectsBase
{
    public Shader motionBlurWithDepthTextureShader;
    private Camera myCamera;
    [Range(0.0f, 1.0f)]
    public float blurSize = 0.5f;
    private Material motionBlurWithDepthTextureMaterial;
    private Matrix4x4 previousViewProjectionMatrix;
    public Material material
    {
        get
        {
            motionBlurWithDepthTextureMaterial = CheckShaderAndCreateMaterial(motionBlurWithDepthTextureShader, motionBlurWithDepthTextureMaterial);
            return motionBlurWithDepthTextureMaterial;
        }
    }
    public Camera MyCamera
    {
        get
        {
            if(myCamera == null)
                myCamera = transform.GetComponent<Camera>();
            return myCamera;
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if(material != null)
        {
            material.SetFloat("_BlurSize", blurSize);

            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            Matrix4x4 currentViewProjectionMatrix = MyCamera.projectionMatrix * MyCamera.worldToCameraMatrix;
            Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
            material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
            previousViewProjectionMatrix = currentViewProjectionMatrix;

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    private void OnEnable() {
        MyCamera.depthTextureMode |= DepthTextureMode.Depth;
    }
}
