# [2026-06-13] 00 - General UAV Commands

## Description

Lệnh vận hành nhanh cho world `baylands_x500_mono_cam` sau khi host nâng cấp lên Ubuntu 26.04.1 / ROS 2 Lyrical. Quy trình và trạng thái kiểm nghiệm chi tiết: [FEAT004](../feats/FEAT004_26.11.15_Ubuntu_26.04_PX4_Gazebo_ROS2_Compatibility.md).

## Phase

`Introduction to UAVs | B:26/06/01 - E:26/../..`

## Author

`Darius`

## Chạy mô phỏng

Chạy các bước cần giữ tiến trình trong terminal riêng. Trên Ubuntu 26.04, `uav_gzb` và `uav_px4` tự chạy Docker container Ubuntu 24.04; không cần gọi `docker run` thủ công.

### Terminal 1: Gazebo Sim

```bash
uav_gzb --baylands_x500_mono_cam
```

### Terminal 2: PX4 Autopilot

```bash
uav_px4 --baylands_x500_mono_cam
```

### Terminal 3: QGroundControl

```bash
uav_qgc
```

### Terminal 4: MAVSDK khi cần điều khiển model

```bash
uav_env --open
python takeoff_land.py
```

`uav_env --open` kích hoạt Conda và chuyển vào `~/dariusuav/mavsdk_test`. Khi xong: `uav_env --close`. Người dùng đã xác nhận một script MAVSDK điều khiển model chạy thành công sau cập nhật; `takeoff_land.py` là ví dụ có sẵn trong thư mục này.

## Kiểm tra topic camera từ Ubuntu host

```bash
GZ_PARTITION=dariusuav gz topic -l | grep image
```

Image topic:

```text
/world/baylands_x500_mono_cam/model/x500/link/camera_link/sensor/camera/image
```

## Xem ảnh camera

### Cách 1: Gazebo Image Display

Trong Gazebo GUI, bấm **Plugins** ở góc trên bên phải, chọn **Image Display** ở panel bên phải và chọn image topic ở trên. Bảo đảm mô phỏng đang **Play**.

### Cách 2: ROS 2 Lyrical qua bridge

Terminal bridge:

```bash
source_global_ros2
GZ_PARTITION=dariusuav ros2 run ros_gz_bridge parameter_bridge \
  '/world/baylands_x500_mono_cam/model/x500/link/camera_link/sensor/camera/image@sensor_msgs/msg/Image[gz.msgs.Image'
```

Terminal graph:

```bash
source_global_ros2
ros2 run rqt_graph rqt_graph
```

Terminal xem ảnh:

```bash
source_global_ros2
ros2 run rqt_image_view rqt_image_view
```

Chọn image topic trong `rqt_image_view`. `source_global_ros2` là alias zsh cho `source /opt/ros/lyrical/setup.zsh`. Phải đặt `GZ_PARTITION=dariusuav` cho bridge chạy trên host; nếu thiếu, graph có thể thấy topic nhưng không có frame.

## Chuẩn bị lại khi cần

Image Docker đã kéo và PX4 đã build trong đợt cập nhật. Chỉ dùng các lệnh sau khi cài máy mới, image bị xóa hoặc cần build lại mã PX4:

```bash
docker pull px4io/px4-sitl-gazebo:latest
docker pull px4io/px4-dev-ros2-gazebo:main-jazzy
./scripts/build_px4_container.sh
```

## Dừng mô phỏng

`Ctrl+C` ở các terminal Gazebo/PX4 để dừng; Gazebo script tự dọn container của nó. Khi cần dọn tiến trình cũ:

```bash
uav_clr --kill
```
