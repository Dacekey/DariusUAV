# [2026-06-13] 00 - General UAV Commands

## Description:
This is the main overview file that just contains useful things for easily checking. Do not need to check the log detailed files.

## Phase: 
`Introduction to UAVs | B:26/06/01 - E:26/../..`

## Author: `Darius`

## Commands:
```bash
uav_gzb (--baylands_x500 | --aruco_x500)
uav_px4 (--baylands_x500 | --aruco_x500)
uav_qgc
uav_env (--open | --close)
uav_clr (nothing | --kill)
```
---

### Terminal 1: `Gazebo Sim`
X. Best way:
```bash
uav_gzb --baylands_x500
uav_gzb --aruco_x500
```
A. baylands_x500 (Custom World)
```bash
cd ~/dariusuav/PX4-Autopilot
python3 Tools/simulation/gz/simulation-gazebo --world baylands_x500
```
B. aruco_x500 (Custom World)
```bash
cd ~/dariusuav/PX4-Autopilot
python3 Tools/simulation/gz/simulation-gazebo --world aruco_x500
```

---

### Terminal 2: `PX4 Autopilot`
X. Best way:
```bash
uav_px4 --baylands_x500
uav_px4 --aruco_x500
```
A. baylands_x500
```bash
cd ~/dariusuav/PX4-Autopilot
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=baylands_x500 PX4_SYS_AUTOSTART=4001 PX4_GZ_MODEL_NAME=x500 ./build/px4_sitl_default/bin/px4
```
B. aruco_x500
```bash
cd ~/dariusuav/PX4-Autopilot
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=aruco_x500 PX4_SYS_AUTOSTART=4001 PX4_GZ_MODEL_NAME=x500 ./build/px4_sitl_default/bin/px4
```

---

### Terminal 3: `QGroundControl Station`
X. Best way:
```bash
uav_qgc
```
or:
```bash
cd ~/dariusuav/apps
./QGroundControl-x86_64.AppImage
```

---

### Terminal 4: `Conda + MAVSDK (Scripts)`
X. Best way: (this will auto come to ~/dariusuav/mavsdk_test)
```bash
uav_env --open
uav_env --close
```
Turn on Conda environment:
```bash
ca_mavsdk
```
Run Scripts:
```bash
cd mavsdk_test
python <name_scripts>
```
Example:
```bash
ca_mavsdk
cd mavsdk_test
python takeoff_land.py
```

---

### Clean Up Old PX4/Gazebo Processes
X. Best way:
```bash
uav_clr
uav_clr --kill
```
or:
```bash
pkill -f px4
pkill -f "gz sim"
pkill -f gazebo
```

If needed:

```bash
pkill -9 -f px4
pkill -9 -f "gz sim"
pkill -9 -f gazebo
```