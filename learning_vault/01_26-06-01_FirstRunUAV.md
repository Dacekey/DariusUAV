# [26-06-01] 01 - First Run UAV

## Milestone

Today I reached the first milestone in my UAV learning journey: I successfully ran a basic UAV simulation pipeline on Ubuntu 24.04.

The working pipeline is:

## What I completed

* Installed and ran PX4 Autopilot SITL.
* Launched Gazebo Sim with the PX4 `x500` UAV model.
* Confirmed that Gazebo displayed the drone model `x500_0` in the `default` world.
* Confirmed that PX4 started successfully and showed the PX4 shell prompt `pxh>`.
* Installed and launched QGroundControl using the AppImage from GitHub Release.
* Confirmed that this QGroundControl command works:

```bash
./QGroundControl-x86_64.AppImage
```

* Completed the initial QGroundControl setup:

  * Unit system: Metric
  * Firmware: PX4 Pro
  * Vehicle: Multi-Rotor

* Successfully connected QGroundControl to PX4 SITL.

* Created a conda environment for MAVSDK Python.

* Installed MAVSDK Python inside the conda environment.

* Wrote the first MAVSDK Python script to control the simulated drone. Check:
  
  ``` /home/dacekey/dariusuav/mavsdk_test/takeoff_land.py ```

* Tested the full setup using three terminals:

  * Terminal 1: PX4 SITL + Gazebo
  * Terminal 2: QGroundControl
  * Terminal 3: MAVSDK Python script
  * Terminal 4: Gazebo only

## Main commands used

### Terminal 1: PX4 SITL + Gazebo

```bash
cd ~/dariusuav/PX4-Autopilot
make px4_sitl gz_x500
```
```bash
cd ~/dariusuav
uav_px4
```

### Terminal 2: QGroundControl

```bash
cd ~/dariusuav/apps
./QGroundControl-x86_64.AppImage
```
```bash
cd ~/dariusuav
uav_qgc
```

### Terminal 3: MAVSDK Python

```bash
conda activate uav-mavsdk
cd ~/dariusuav/mavsdk_test
python takeoff_land.py
```
```bash
ca_mavsdk
cd ~/dariusuav/mavsdk_test
python takeoff_land.py
```
```bash
conda deactivate
```

### Terminal 4: Gazebo only
```bash
cd ~/dariusuav
uav_gzb
```

**Check more for alias on:**
```
~/.zshrc
```
## Meaning of this milestone

I confirmed that my basic UAV simulation environment is working:

* PX4 SITL runs the autopilot.
* Gazebo Sim provides the simulated UAV and world.
* QGroundControl works as the ground control station.
* MAVSDK Python can be used to write control scripts for the drone.

This is the first foundation for learning UAV programming, autonomous missions, ROS2 offboard control, computer vision, and UAV autonomy.

## Next steps

* Run the MAVSDK script several times to understand the connect, arm, takeoff, and land flow.
* Add telemetry reading: altitude, position, battery, and flight mode.
* Write a simple waypoint mission script.
* Take notes on MAVLink, MAVSDK, PX4 flight modes, and QGroundControl.
