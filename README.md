# DariusUAV - UAV Simulation & Control Workspace

This repository is a structured development workspace for UAV simulation, autopilot control, and autonomous mission scripting using **PX4 Autopilot**, **Gazebo Sim**, **QGroundControl**, and **MAVSDK Python**.

---

## 🛠️ System Requirements

- **Operating System:** Ubuntu 24.04 LTS (recommended)
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
Clone the PX4 Autopilot repository directly into the workspace root and build the SITL targets:

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

---

## ⚙️ Helper Scripts & Environment Aliases

The repository contains several preconfigured runner scripts under `scripts/`. It is recommended to add the following aliases to your shell config (e.g., `~/.bashrc` or `~/.zshrc`) for smooth operation:

```bash
# UAV Environment Shortcuts
alias uav_gzb="~/dariusuav/scripts/run_gazebo_sim.sh"
alias uav_px4="~/dariusuav/scripts/run_px4_autopilot.sh"
alias uav_qgc="~/dariusuav/scripts/run_qgroundcontrol.sh"
alias uav_env="source ~/dariusuav/scripts/run_conda_virenv.sh"
alias uav_clr="~/dariusuav/scripts/run_clear_allenv.sh"
```

---

## 🚦 How to Run the Simulation

For the most stable viewport camera control, run Gazebo and PX4 SITL using the standalone bind method:

### 1. Launch Gazebo World
Launch the simulator with your target custom world:
```bash
uav_gzb --baylands_x500
# OR
uav_gzb --aruco_x500
```

### 2. Bind PX4 Autopilot SITL
Once Gazebo is open and the vehicle model is loaded, run PX4 to bind to the existing simulation entity:
```bash
uav_px4 --baylands_x500
# OR
uav_px4 --aruco_x500
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

### 5. Cleaning Up Simulation Processes
To kill any background simulator or PX4 processes that did not exit properly:
```bash
uav_clr --kill
```
