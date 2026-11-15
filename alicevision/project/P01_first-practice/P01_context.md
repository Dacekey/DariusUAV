# AliceVision Photogrammetry Practice - Project Context & Setup

## 1. Project Overview & Objectives
This project focuses on implementing and practicing 3D Reconstruction (Photogrammetry) using the **AliceVision / Meshroom** open-source framework. 
The goal is to process a set of unordered 2D high-resolution images (`P01_first-practice`) into a complete 3D polygonal textured mesh using AliceVision CLI tools or Python orchestration (via Jupyter Notebook).

---

## 2. Environment & Directory Structure

### Absolute Paths
* **Workspace Root**: `/home/dacekey/dariusuav/alicevision`
* **Current Project Directory**: `/home/dacekey/dariusuav/alicevision/project/P01_first-practice`
* **Meshroom / AliceVision Installation**: `/home/dacekey/dariusuav/alicevision/Meshroom-2023.3.0`

### Directory Layout
```text
/home/dacekey/dariusuav/alicevision/
├── Meshroom-2023.3.0/
│   ├── aliceVision/
│   │   ├── bin/               # Contains all AliceVision core CLI binaries
│   │   ├── lib/
│   │   └── share/
│   ├── meshroom_batch         # Automation script for end-to-end processing
│   ├── meshroom_compute
│   └── Meshroom               # GUI launcher script
└── project/
    └── P01_first-practice/
        ├── images/            # Input dataset (176 JPG high-res images)
        └── output/            # Target output folder for 3D meshes & intermediate files
```

---

## 3. Dataset Condition & Readiness
* **Input Dataset Path**: `/home/dacekey/dariusuav/alicevision/project/P01_first-practice/images`
* **File Count**: 176 image files (`MAX_0002.JPG` through `MAX_0177.JPG`).
* **Image Characteristics**: Average file size ~13 MB – 17 MB per JPG image, indicating high-resolution photographs suitable for detailed feature matching and dense 3D reconstruction.
* **Output Folder Status**: Prepared at `/home/dacekey/dariusuav/alicevision/project/P01_first-practice/output` (currently empty).

---

## 4. Software & CLI Tooling Status
All required binaries for the AliceVision 3D reconstruction pipeline are installed and verified at:
`/home/dacekey/dariusuav/alicevision/Meshroom-2023.3.0/aliceVision/bin`

Key core executable nodes available:
1. `aliceVision_cameraInit`
2. `aliceVision_featureExtraction`
3. `aliceVision_featureMatching`
4. `aliceVision_incrementalSfM` (Structure from Motion)
5. `aliceVision_depthMapEstimation` *(Requires NVIDIA CUDA GPU)*
6. `aliceVision_depthMapFiltering`
7. `aliceVision_meshing`
8. `aliceVision_meshFiltering`
9. `aliceVision_texturing`

---

## 5. Implementation Notes for AI Assistant / Developer
When assisting with implementation (e.g., inside a Jupyter Notebook `.ipynb`), you may choose between two approaches:

### Approach A: End-to-End Batch Execution
Execute the pre-packaged `meshroom_batch` wrapper via terminal or Python `subprocess`:
```bash
/home/dacekey/dariusuav/alicevision/Meshroom-2023.3.0/meshroom_batch \
    --input /home/dacekey/dariusuav/alicevision/project/P01_first-practice/images \
    --output /home/dacekey/dariusuav/alicevision/project/P01_first-practice/output
```

### Approach B: Step-by-Step Node Orchestration (Recommended for Notebook Learning)
Chain individual CLI commands from `aliceVision/bin/`. Ensure intermediate data folders (e.g., `cameraInit.sfm`, `features/`, `matches/`, `sfm/`, `depthmaps/`, `mesh/`) are managed correctly within the project directory or a temporary cache folder.

Standard Node Sequence:
1. **CameraInit**: Generate `.sfm` file containing camera sensor definitions.
2. **FeatureExtraction**: Extract SIFT/DSFT features for all input images.
3. **FeatureMatching**: Match feature descriptors across overlapping image pairs.
4. **StructureFromMotion (SfM)**: Reconstruct sparse 3D point cloud and camera poses.
5. **PrepareDenseScene & DepthMapEstimation**: Compute dense per-pixel depth maps (CUDA required).
6. **DepthMapFiltering & Meshing**: Generate 3D polygonal mesh (`.obj`).
7. **Texturing**: Project original image colors onto the 3D mesh (`texturedMesh.obj` + `.png`).
