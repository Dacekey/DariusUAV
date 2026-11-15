# DariusUAV - UAV Simulation & Control Workspace

This repository is a structured development workspace for UAV simulation, autopilot control, and autonomous mission scripting using **PX4 Autopilot**, **Gazebo Sim**, **QGroundControl**, and **MAVSDK Python**.

---

## 🛠️ System Requirements

- **Operating System:** Ubuntu 26.04.1 host with Ubuntu 24.04 Docker containers for PX4/Gazebo (verified setup)
- **ROS 2:** Lyrical on the Ubuntu 26.04 host
- **Autopilot Suite:** PX4 Autopilot SITL (v1.15.0+ / Main Branch)
- **Simulation Engine:** Gazebo Sim (Harmonic / version 8.13+)
- **Ground Control Station:** QGroundControl (AppImage)
- **Python Environment:** Conda or virtualenv (Python 3.11)

---

## 📂 Git-Ignored External Assets (.gitignore)

To keep this repository lightweight and focused on custom code/configurations, several large or external components are excluded from Git tracking via `.gitignore`. You must set these up locally:

1. **`PX4-Autopilot/` (Directory):** 
   - A cloned instance of the PX4 Autopilot repository. Because it contains its own extensive build system and history, it is ignored by Git in this workspace.
2. **`apps/QGroundControl-x86_64.AppImage` (Executable):**
   - The Ground Control Station precompiled AppImage (~180MB) is ignored to avoid bloating the repository.

---

## 🚀 Setup & Installation Guide

### 1. Clone & Build PX4 Autopilot
Clone the PX4 Autopilot repository directly into the workspace root. The native dependency setup and build commands below apply to Ubuntu 24.04; use the container build below on Ubuntu 26.04.

```bash
# Clone the repository
git clone --recursive https://github.com/PX4/PX4-Autopilot.git

# Set up PX4 dependencies (run from PX4-Autopilot directory)
cd PX4-Autopilot
bash Tools/setup/ubuntu.sh

# Run a first-time build to compile the default SITL target
make px4_sitl gz_x500
```

### 2. Set Up the Python Conda Environment
Create and configure the Python environment for MAVSDK script execution:

```bash
# Create the environment with Python 3.11
conda create -n uav-mavsdk python=3.11 -y

# Activate the environment
conda activate uav-mavsdk

# Install required Python packages
pip install -r requirements.txt
```

### 3. Install QGroundControl
Download the QGroundControl AppImage and save it inside the `apps` directory:

```bash
# Create the apps directory if it doesn't exist
mkdir -p apps

# Download the AppImage (example using wget)
wget https://s3-us-west-2.amazonaws.com/qgroundcontrol/latest/QGroundControl.AppImage -O apps/QGroundControl-x86_64.AppImage

# Grant execution permissions
chmod +x apps/QGroundControl-x86_64.AppImage
```

### 4. Link Custom Gazebo Worlds
This repository contains custom world definitions (including the pre-loaded `x500` drone and experimental visual markers) under [gazebosim/custom_world/](file:///home/dacekey/dariusuav/gazebosim/custom_world/). For Gazebo Sim and PX4 to locate them, you must symlink these world files into the Gazebo simulation cache directory (`~/.simulation-gazebo/worlds/`):

```bash
# Ensure the Gazebo worlds directory exists
mkdir -p ~/.simulation-gazebo/worlds

# Symlink the custom worlds from the workspace
ln -sf ~/dariusuav/gazebosim/custom_world/*.sdf ~/.simulation-gazebo/worlds/
```

---

## ⚙️ Helper Scripts & Environment Aliases

The repository contains several preconfigured runner scripts under `scripts/`. It is recommended to add the following aliases to your shell config (e.g., `~/.bashrc` or `~/.zshrc`) for smooth operation:

```bash
# UAV Environment Shortcuts
alias uav_gzb="~/dariusuav/scripts/run_gazebo_sim.sh"
alias uav_px4="~/dariusuav/scripts/run_px4_autopilot.sh"
alias uav_qgc="~/dariusuav/scripts/run_qgroundcontrol.sh"
alias uav_env="source ~/dariusuav/scripts/run_conda_virenv.sh"
alias uav_av="source ~/dariusuav/scripts/run_alicevision_env.sh"
alias uav_clr="~/dariusuav/scripts/run_clear_allenv.sh"
```

### Ubuntu 26.04 simulation backend

On Ubuntu 26.04, `uav_gzb` and `uav_px4` use Docker automatically. This keeps
Gazebo Harmonic and the PX4 SITL build in their supported Ubuntu 24.04
environment. The PX4 binary is built from this repository's checkout, including
local source changes. The host ROS 2 Lyrical installation remains separate.
The camera image topic has been successfully bridged into Lyrical on the host
by setting `GZ_PARTITION=dariusuav` for `ros_gz_bridge`.

Prepare the two images and build PX4 once (or rebuild after changing PX4 source):

```bash
docker pull px4io/px4-sitl-gazebo:latest
docker pull px4io/px4-dev-ros2-gazebo:main-jazzy
./scripts/build_px4_container.sh
```

Run `uav_gzb --baylands_x500_mono_cam` and `uav_px4 --baylands_x500_mono_cam`
in separate terminals as below. Gazebo opens through XWayland and uses the
NVIDIA GPU by default. Set `UAV_GZ_GPU=amd` to use the integrated Radeon GPU,
or `UAV_GZ_GPU=software` to render on the CPU. Set `UAV_GZ_HEADLESS=1` when a
window is unnecessary. Both commands use the same Gazebo partition
(`dariusuav` by default). Set
`UAV_SIM_BACKEND=native` to use the host Gazebo and PX4 binaries instead.
When the local PX4 plugin has been built, the NVIDIA mode also uses its NVENC
H.264 camera encoder for the UDP stream on port 5600.

---

## 🚦 How to Run the Simulation

The verified workflow below uses `baylands_x500_mono_cam`. On Ubuntu 26.04,
`uav_gzb` and `uav_px4` start Docker containers automatically; no manual
`docker run` step is needed after the images and PX4 binary are prepared.

### 1. Launch Gazebo World
Launch the custom world:
```bash
uav_gzb --baylands_x500_mono_cam
```

### 2. Bind PX4 Autopilot SITL
Once Gazebo is open and the vehicle model is loaded, run PX4 to bind to the existing simulation entity:
```bash
uav_px4 --baylands_x500_mono_cam
```

### 3. Start QGroundControl
Open the ground station to view telemetry and maps:
```bash
uav_qgc
```

### 4. Run MAVSDK Scripts
Activate the environment and run MAVSDK control scripts:
```bash
uav_env --open
python takeoff_land.py
```

MAVSDK control with a script was confirmed successful after the update.
`takeoff_land.py` is the example script available in this workspace; the exact
script used for that confirmation was not recorded.

### 5. Inspect and view the camera

Check the Gazebo image topic from the Ubuntu host:

```bash
GZ_PARTITION=dariusuav gz topic -l | grep image
```

To view it directly in Gazebo, open **Plugins → Image Display** and select
`/world/baylands_x500_mono_cam/model/x500/link/camera_link/sensor/camera/image`.

To view it through ROS 2 Lyrical, run these in separate host terminals:

```bash
# Bridge terminal
source_global_ros2
GZ_PARTITION=dariusuav ros2 run ros_gz_bridge parameter_bridge \
  '/world/baylands_x500_mono_cam/model/x500/link/camera_link/sensor/camera/image@sensor_msgs/msg/Image[gz.msgs.Image'
```

```bash
# ROS graph terminal
source_global_ros2
ros2 run rqt_graph rqt_graph
```

```bash
# ROS image terminal; select the image topic in the window
source_global_ros2
ros2 run rqt_image_view rqt_image_view
```

`source_global_ros2` is the local zsh alias for `source /opt/ros/lyrical/setup.zsh`.
The Gazebo/PX4 containers receive the partition from their scripts; the host
bridge needs it explicitly. Both ROS graph discovery and image display were
verified after setting the partition.

### 6. Cleaning Up Simulation Processes
To kill any background simulator or PX4 processes that did not exit properly:
```bash
uav_clr --kill
```

For the full Ubuntu 26.04 migration record, see
[FEAT004](vaults/feats/FEAT004_26.11.15_Ubuntu_26.04_PX4_Gazebo_ROS2_Compatibility.md).
