#!/usr/bin/env bash

set -euo pipefail

world="${1:?world name required}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
world_file="$repo_root/gazebosim/custom_world/$world.sdf"
image="${UAV_GAZEBO_IMAGE:-px4io/px4-sitl-gazebo:latest}"
partition="${UAV_GZ_PARTITION:-dariusuav}"
gpu="${UAV_GZ_GPU:-nvidia}"
fuel_cache="$HOME/.gz/fuel"
camera_plugin="$repo_root/PX4-Autopilot/build/px4_sitl_default/src/modules/simulation/gz_plugins/libGstCameraSystem.so"
server_name="dariusuav-gz-server-$$"
gui_name="dariusuav-gz-gui-$$"
auth_file=""

cleanup() {
    docker stop "$gui_name" "$server_name" >/dev/null 2>&1 || true
    if [[ -n "$auth_file" ]]; then
        rm -f "$auth_file"
    fi
}
trap cleanup EXIT INT TERM

if [[ ! -f "$world_file" ]]; then
    echo "Gazebo world not found: $world_file" >&2
    exit 1
fi
if [[ ! -d "$fuel_cache" ]]; then
    echo "Gazebo Fuel cache not found: $fuel_cache" >&2
    exit 1
fi
if ! docker image inspect "$image" >/dev/null 2>&1; then
    echo "Docker image not found: $image" >&2
    echo "Run: docker pull $image" >&2
    exit 1
fi

gpu_args=()
camera_plugin_args=()
case "$gpu" in
    nvidia)
        gpu_args=(--gpus all
            -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,display,video
            -e __NV_PRIME_RENDER_OFFLOAD=1
            -e __GLX_VENDOR_LIBRARY_NAME=nvidia)
        ;;
    amd)
        gpu_args=(--device=/dev/dri)
        ;;
    software)
        gpu_args=(-e LIBGL_ALWAYS_SOFTWARE=1)
        ;;
    *)
        echo "Unknown UAV_GZ_GPU: $gpu (choose nvidia, amd, or software)" >&2
        exit 2
        ;;
esac
if [[ "$gpu" == nvidia && -f "$camera_plugin" ]]; then
    camera_plugin_args=(-v "$camera_plugin:/opt/px4-gazebo/lib/gz/plugins/libGstCameraSystem.so:ro")
fi

display_args=()
if [[ -n "${DISPLAY:-}" ]] && command -v xauth >/dev/null; then
    umask 077
    auth_file="$(mktemp)"
    xauth nlist "$DISPLAY" | sed 's/^..../ffff/' | xauth -f "$auth_file" nmerge -
    if [[ -s "$auth_file" ]]; then
        display_args=(-e "DISPLAY=$DISPLAY" -e XAUTHORITY=/tmp/px4.xauth
            -e QT_QPA_PLATFORM=xcb
            --mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix,readonly
            --mount "type=bind,src=$auth_file,dst=/tmp/px4.xauth,readonly")
    fi
fi
if [[ "${UAV_GZ_HEADLESS:-0}" != 1 && ${#display_args[@]} -eq 0 ]]; then
    echo "DISPLAY and Xauthority are required for the Gazebo GUI; use UAV_GZ_HEADLESS=1 for headless mode." >&2
    exit 1
fi

docker run -d --rm --name "$server_name" --network host \
    "${gpu_args[@]}" "${display_args[@]}" "${camera_plugin_args[@]}" \
    -e "GZ_PARTITION=$partition" \
    -v "$fuel_cache:/root/.gz/fuel:ro" \
    -v "$world_file:/opt/px4-gazebo/share/gz/worlds/$world.sdf:ro" \
    --entrypoint /bin/sh "$image" \
    -c "exec gz sim -s -r -v 2 /opt/px4-gazebo/share/gz/worlds/$world.sdf" >/dev/null

if [[ "${UAV_GZ_HEADLESS:-0}" != 1 ]]; then
    docker run -d --rm --name "$gui_name" --network host \
        "${gpu_args[@]}" "${display_args[@]}" \
        -e "GZ_PARTITION=$partition" \
        -v "$fuel_cache:/root/.gz/fuel:ro" \
        --entrypoint /bin/sh "$image" -c 'exec gz sim -g -v 2' >/dev/null
fi

echo "Gazebo world: $world (partition: $partition, GPU: $gpu). Press Ctrl+C to stop."
docker logs -f "$server_name"
