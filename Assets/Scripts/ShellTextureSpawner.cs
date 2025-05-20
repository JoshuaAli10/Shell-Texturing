using Unity.Mathematics;
using UnityEngine;
using UnityEditor;
using UnityEditor.UIElements;

public class ShellTextureSpawner : MonoBehaviour
{
    private int _totalLayers;
    [SerializeField] private int m_totalLayers;
    [SerializeField] private Vector2 _scale = Vector2.one;
    [SerializeField] private AnimationCurve _samplingCurve;
    [SerializeField] private Mesh _mesh;
    [SerializeField] private Material _material;

    private MaterialPropertyBlock _propertyBlock;
    private Matrix4x4 _matrix4X4;

    private Matrix4x4[] _matrices;
    private float[] _samples;
    void Awake()
    {
        _propertyBlock = new MaterialPropertyBlock();
        _matrix4X4 = new Matrix4x4();

        UpdateInstances();
    }

    void Update()
    {
        Graphics.DrawMeshInstanced(_mesh, 0, _material, _matrices, _totalLayers, _propertyBlock);
    }
    public void UpdateInstances()
    {
        _matrix4X4.SetTRS(transform.position, Quaternion.identity, new Vector3(_scale.x, 1, _scale.y));

        _samples = new float[m_totalLayers];
        _matrices = new Matrix4x4[m_totalLayers];

        for (int i = 0; i < m_totalLayers; i++)
        {
            _matrices[i] = _matrix4X4;
            _samples[i] = _samplingCurve.Evaluate((float)i/m_totalLayers);
        }

        _totalLayers = m_totalLayers;

        _propertyBlock.SetFloatArray("_LayerIndex", _samples);
    }
}
[CustomEditor(typeof(ShellTextureSpawner))]
public class ShellTextureSpanerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        ShellTextureSpawner shellTextureSpaner = (ShellTextureSpawner)target;

        if (GUILayout.Button("Update Positions"))
        {
            shellTextureSpaner.UpdateInstances();
        }
    }
}