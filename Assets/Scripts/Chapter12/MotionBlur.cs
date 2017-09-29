using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectsBase
{

    public Shader motionBlurShader;
    private Material motionBlurMaterial = null;

    public Material material
    {
        get
        {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;
        }
    }

    [Range(.0f, 0.9f)]
    public float blurAmount = .5f;

    private RenderTexture accumulationTexture;

    void OnDisable()
    {
        DestroyImmediate(accumulationTexture);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        //Debug.Log("OnRenderImage-----------------------");
        //if (material != null)
        //{
        //    if (accumulationTexture == null || accumulationTexture.width != src.width || accumulationTexture.height != src.height)
        //    {
        //        DestroyImmediate(accumulationTexture);
        //        accumulationTexture = new RenderTexture(src.width, src.height, 0);
        //        accumulationTexture.hideFlags = HideFlags.HideAndDontSave;//自己控制该变量的销毁
        //        Graphics.Blit(src, accumulationTexture);
        //    }

        //    accumulationTexture.MarkRestoreExpected();//表明需要进行渲染纹理的恢复操作
        //    material.SetFloat("_BlurAmount", 1.0f - blurAmount);

        //    Graphics.Blit(src, accumulationTexture, material);
        //    Graphics.Blit(accumulationTexture, dest);
        //}
        //else
        {
            RenderTexture buffer1 = RenderTexture.GetTemporary(src.width, src.height, 0);
            Graphics.Blit(src, buffer1, material);
            Graphics.Blit(buffer1, dest);
            RenderTexture.ReleaseTemporary(buffer1);

            //Graphics.Blit(src, dest);
        }
    }
}
