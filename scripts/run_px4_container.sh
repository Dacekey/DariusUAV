#!/usr/bin/env bash

set -euo pipefail

world="${1:?world name required}"
model="${2:?model name required}"
autostart="${3:?PX4 autostart required}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
px4_root="$repo_root/PX4-Autopilot"
image="${UAV_PX4_BUILD_IMAGE:-px4io/px4-dev-ros2-gazebo:main-jazzy}"
partition="${UAV_GZ_PARTITION:-dariusuav}"

if [[ ! -x "$px4_root/build/px4_sitl_default/bin/px4" ]]; then
    echo "PX4 SITL binary not found. Build it in the Ubuntu 24.04 PX4 development container first." >&2
    exit 1
fi
if ! docker image inspect "$image" >/dev/null 2>&1; then
    echo "Docker image not found: $image" >&2
    echo "Run: docker pull $image" >&2
    exit 1
fi

docker_tty=(-i)
if [[ -t 0 && -t 1 ]]; then
    docker_tty+=(-t)
fi

docker run --rm "${docker_tty[@]}" --network host \
    --user "$(id -u):$(id -g)" \
    -e HOME=/tmp/px4-home \
    -e "GZ_PARTITION=$partition" \
    -e PX4_GZ_STANDALONE=1 \
    -e "PX4_GZ_WORLD=$world" \
    -e "PX4_GZ_MODEL_NAME=$model" \
    -e "PX4_SYS_AUTOSTART=$autostart" \
    -v "$px4_root:/workspace" -w /workspace \
    --entrypoint /bin/bash "$image" \
    -lc 'exec ./build/px4_sitl_default/bin/px4'
