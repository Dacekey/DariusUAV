# [2026-06-13] 02 - PX4 Gazebo Standalone and Baylands World Test

## Session Goal

The goal of today's UAV learning session was to explore how to use PX4 SITL, Gazebo Sim, QGroundControl, and MAVSDK Python with different Gazebo worlds, especially `baylands`, and to test a cleaner PX4-Gazebo standalone workflow.

The main focus was:

- Test different Gazebo worlds with PX4 SITL.
- Understand whether worlds should be loaded by PX4 or Gazebo.
- Run PX4 and Gazebo separately in standalone mode.
- Diagnose a Gazebo camera control issue.
- Find a stable workflow for running PX4 with an existing model inside Gazebo.

---

## Background

From the previous UAV milestone, the basic simulation pipeline was already working:

- PX4 SITL could run with Gazebo Sim.
- The `x500` UAV model could be launched.
- QGroundControl could connect to PX4 SITL.
- MAVSDK Python could run a simple takeoff and land script.

Today's session built on top of that foundation.

---

## Worlds Tested

I tested several PX4 Gazebo worlds:

- `baylands`
- `ridge`
- `windy`
- `aruco`
- `default`


## Important Concept Learned

A key concept from this session:

> The Gazebo world belongs to Gazebo, not PX4.

PX4 is the autopilot. Gazebo is responsible for:

- Loading the world.
- Running physics.
- Displaying the 3D scene.
- Managing models and sensors.

PX4 can either:

1. Ask Gazebo to spawn a model, or
2. Bind/connect to a model that already exists in Gazebo.

---

## First Working Standalone Method: PX4 Spawns the Model

I first used the following standalone structure.

### Terminal 1: Launch Gazebo World

```bash
cd ~/dariusuav/PX4-Autopilot
python3 Tools/simulation/gz/simulation-gazebo --world baylands
```

### Terminal 2: Launch PX4 Standalone and Spawn x500

```bash
cd ~/dariusuav/PX4-Autopilot
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=baylands make px4_sitl gz_x500
```

### Result

This successfully spawned the `x500` model into the `baylands` world.

QGroundControl could connect successfully.

MAVSDK Python could also run the takeoff script successfully.

However, there was a problem:

> After PX4 connected and spawned the model, Gazebo camera controls stopped working.

I could not properly rotate, pan, or zoom the camera in the Gazebo viewport. When PX4 was stopped or disconnected, Gazebo camera controls worked normally again.

## Important Breakthrough

I considered another architecture:

> Instead of letting PX4 spawn the model into Gazebo, load/import the `x500` model into Gazebo first, then let PX4 only bind/connect to that existing model.

This turned out to solve the camera problem.

---

## Stable Working Method: Gazebo Has the Model First, PX4 Only Binds

### Workflow

1. Start Gazebo and load the world.
2. Import the `x500` model into the world manually.
3. Check the model name in the Gazebo Entity Tree.
4. Start PX4 standalone and bind it to the existing model using `PX4_GZ_MODEL_NAME`.

---

## Working Test with `aruco`

### Terminal 1: Launch Gazebo

```bash
cd ~/dariusuav/PX4-Autopilot
python3 Tools/simulation/gz/simulation-gazebo --world aruco
```

Then I imported the `x500` model into the world using Gazebo.

The model name in the Entity Tree was checked. Example names:

- `x500`
- `x500_0`

### Terminal 2: Launch PX4 and Bind to Existing Model

If the model name is `x500`:

```bash
cd ~/dariusuav/PX4-Autopilot
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=aruco PX4_SYS_AUTOSTART=4001 PX4_GZ_MODEL_NAME=x500 ./build/px4_sitl_default/bin/px4
```

If the model name is `x500_0`:

```bash
cd ~/dariusuav/PX4-Autopilot
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=aruco PX4_SYS_AUTOSTART=4001 PX4_GZ_MODEL_NAME=x500_0 ./build/px4_sitl_default/bin/px4
```

### Result

This method worked.

Gazebo camera controls worked normally after PX4 connected.

---

## Working Test with `baylands`

After the `aruco` test succeeded, I repeated the same workflow with `baylands`.

### Terminal 1: Launch Baylands

```bash
cd ~/dariusuav/PX4-Autopilot
python3 Tools/simulation/gz/simulation-gazebo --world baylands
```

Then I imported the `x500` model into the `baylands` world.

### Terminal 2: PX4 Bind to Existing x500

If the model name is `x500`:

```bash
cd ~/dariusuav/PX4-Autopilot
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=baylands PX4_SYS_AUTOSTART=4001 PX4_GZ_MODEL_NAME=x500 ./build/px4_sitl_default/bin/px4
```

If the model name is `x500_0`:

```bash
cd ~/dariusuav/PX4-Autopilot
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=baylands PX4_SYS_AUTOSTART=4001 PX4_GZ_MODEL_NAME=x500_0 ./build/px4_sitl_default/bin/px4
```

### Result

The `baylands` test also worked.

The camera issue disappeared with this method.

---

## Key Technical Difference

There are two different PX4-Gazebo workflows:

### Method A: PX4 Spawns the Model

```bash
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=baylands make px4_sitl gz_x500
```

Meaning:

- Gazebo loads the world.
- PX4 asks Gazebo to spawn the `x500` model.
- PX4 binds to the newly spawned model.

Problem observed:

- Gazebo camera control could stop working after PX4 connected.

### Method B: PX4 Binds to an Existing Model

```bash
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=baylands PX4_SYS_AUTOSTART=4001 PX4_GZ_MODEL_NAME=x500 ./build/px4_sitl_default/bin/px4
```

Meaning:

- Gazebo already has the `x500` model in the world.
- PX4 does not spawn a new model.
- PX4 only connects to the existing model.

Result:

- Gazebo camera control worked normally.
- PX4 connected successfully.
- QGroundControl and MAVSDK could be used.

---

## Commands Used Frequently

### Clean Up Old PX4/Gazebo Processes

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

### Launch QGroundControl

```bash
uav_qgc
```

or:

```bash
cd ~/dariusuav/apps
./QGroundControl-x86_64.AppImage
```

### Run MAVSDK Test Script

```bash
ca_mavsdk
cd ~/dariusuav/mavsdk_test
python takeoff_land.py
```

---

## Update: Custom Gazebo Worlds with Preloaded x500

After testing the standalone PX4-Gazebo workflow, I found that letting PX4 spawn the `x500` model into Gazebo could cause a Gazebo viewport camera issue. The camera could not rotate, pan, or zoom properly after PX4 connected.

To avoid this, I tested a better workflow:

- Gazebo loads a world that already contains the `x500` model.
- PX4 does not spawn a new vehicle model.
- PX4 only binds/connects to the existing `x500` model using `PX4_GZ_MODEL_NAME=x500`.

This workflow solved the Gazebo camera viewport issue.

---

### Custom World 1: `baylands_x500`

I created a custom Baylands world with the `x500` model already included.

The custom world file is:

```bash
baylands_x500.sdf
```
The file was placed in the Gazebo simulation cache:
```bash
~/.simulation-gazebo/worlds/baylands_x500.sdf
```
Inside the SDF file, the world name must match the world name used by PX4:
```bash
<world name="baylands_x500">
```
The x500 model was added inside the world:
```bash
<include>
  <uri>model://x500</uri>
  <name>x500</name>
  <pose>0 0 0.3 0 0 0</pose>
</include>
```
To launch the custom Baylands world:
```bash
cd ~/dariusuav/PX4-Autopilot
python3 Tools/simulation/gz/simulation-gazebo --world baylands_x500
```
To start PX4 and bind it to the existing x500 model:
```bash
cd ~/dariusuav/PX4-Autopilot
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=baylands_x500 PX4_SYS_AUTOSTART=4001 PX4_GZ_MODEL_NAME=x500 ./build/px4_sitl_default/bin/px4
```
**Result**:
- Gazebo successfully loaded the custom Baylands world.
- The x500 model was already present in the world.
- PX4 successfully connected to the existing x500 model.
- QGroundControl connected successfully.
- MAVSDK takeoff/land script worked.
- Gazebo camera viewport worked normally.

---

### Custom World 2: `aruco_x500`

I also created a custom ArUco world with the x500 model already included.

The custom world file is:

```bash
aruco_x500.sdf
```
The file was placed in the Gazebo simulation cache:
```bash
~/.simulation-gazebo/worlds/aruco_x500.sdf
```
Inside the SDF file, the world name was changed to:
```bash
<world name="aruco_x500">
```
The x500 model was added before the closing </world> tag:
```bash
<include>
  <uri>model://x500</uri>
  <name>x500</name>
  <pose>0 0 0.3 0 0 0</pose>
</include>
```
To launch the custom ArUco world:
```bash
cd ~/dariusuav/PX4-Autopilot
python3 Tools/simulation/gz/simulation-gazebo --world aruco_x500
```

To start PX4 and bind it to the existing x500 model:
```bash
cd ~/dariusuav/PX4-Autopilot
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=aruco_x500 PX4_SYS_AUTOSTART=4001 PX4_GZ_MODEL_NAME=x500 ./build/px4_sitl_default/bin/px4
```
**Result**:
- Gazebo successfully loaded the custom ArUco world.
- The world contained both the ArUco marker and the x500 drone.
- PX4 successfully bound to the existing x500 model.
- The Gazebo camera viewport issue did not appear.
- This custom world is useful for future UAV + Computer Vision experiments.

---

## Final Conclusion

Today's stable workflow is:

```text
1. Start Gazebo with the target world.
2. Import or preload the x500 model into Gazebo.
3. Start PX4 standalone using PX4_GZ_MODEL_NAME to bind to the existing model.
4. Open QGroundControl.
5. Run MAVSDK Python scripts.
```

The most stable method for this machine is:

```bash
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=<world_name> PX4_SYS_AUTOSTART=4001 PX4_GZ_MODEL_NAME=<model_name> ./build/px4_sitl_default/bin/px4
```

Example for `baylands`:

```bash
PX4_GZ_STANDALONE=1 PX4_GZ_WORLD=baylands PX4_SYS_AUTOSTART=4001 PX4_GZ_MODEL_NAME=x500 ./build/px4_sitl_default/bin/px4
```

---

## Lessons Learned

- Gazebo worlds should be thought of as Gazebo-side assets.
- PX4 is the autopilot, not the world loader.
- PX4 can either spawn a model or bind to an existing model.
- On this machine, binding to an existing Gazebo model is more stable than letting PX4 spawn the model.
- `aruco` is useful for future Computer Vision work.
- `baylands` is heavier but can run successfully with the stable workflow.
- Avoid using `LIBGL_ALWAYS_SOFTWARE=1` with this Gazebo setup because it caused a segmentation fault.
- There are two different ways to use PX4 with Gazebo models:
  ```note
  PX4_SIM_MODEL / make px4_sitl gz_x500
  → PX4 spawns the drone model into Gazebo.

  PX4_GZ_MODEL_NAME=x500
  → PX4 connects to an existing drone model that is already inside the Gazebo world.
  ```
- For my current machine and setup, the second method is more stable:
  ```note
  Gazebo loads custom world with x500 already included.
  PX4 binds to the existing x500 model.

  => This avoids the Gazebo camera viewport issue that happened when PX4 spawned the model dynamically.
  ```


