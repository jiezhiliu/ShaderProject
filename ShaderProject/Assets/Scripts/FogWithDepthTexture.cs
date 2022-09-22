using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithDepthTexture : PostEffectsBase
{
    public Shader fogWithDepthTextureShader;

    private Material fogWithDepthTextureMaterial;
    private Camera myCamera;
    private Transform cameraTransform;
    [Range(0.0f, 3.0f)]
    public float fogDensity = 1.0f;
    public Color fogColor = Color.white;
    public float fogStart = 0.0f;
    public float fogEnd = 2.0f;
    public Material material
    {
        get
        {
            fogWithDepthTextureMaterial = CheckShaderAndCreateMaterial(fogWithDepthTextureShader, fogWithDepthTextureMaterial);
            return fogWithDepthTextureMaterial;
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
    public Transform CameraTransform
    {
        get
        {
            if(cameraTransform == null)
                cameraTransform = MyCamera.transform;
            return cameraTransform;
        }
    }

    private void OnEnable() {
        MyCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if(material != null)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = MyCamera.fieldOfView;
            float near = MyCamera.nearClipPlane;
            float far = MyCamera.farClipPlane;
            float aspect = MyCamera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Rad2Deg);
            Vector3 toRight = CameraTransform.right * halfHeight * aspect;
            Vector3 toTop = CameraTransform.up * halfHeight;

            Vector3 topLeft = CameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = CameraTransform.forward * near + toTop + toRight;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = CameraTransform.forward * near - toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = CameraTransform.forward * near - toTop + toRight;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            material.SetMatrix("_FrustumCornersRay", frustumCorners);
            material.SetMatrix("_ViewProjectionInverseMatrix", (MyCamera.projectionMatrix * MyCamera.worldToCameraMatrix).inverse);

            material.SetFloat("_FogDensity", fogDensity);
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

}
