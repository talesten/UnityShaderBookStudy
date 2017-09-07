using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class TestMaterial : MonoBehaviour
{
    Renderer thisRenderer;
    // Use this for initialization
    void Start()
    {
        thisRenderer = GetComponent<Renderer>();
        thisRenderer.material.color = Color.red;
    }

}
