#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
px4_root="$repo_root/PX4-Autopilot"
image="${UAV_PX4_BUILD_IMAGE:-px4io/px4-dev-ros2-gazebo:main-jazzy}"

if ! docker image inspect "$image" >/dev/null 2>&1; then
    echo "Docker image not found: $image" >&2
    echo "Run: docker pull $image" >&2
    exit 1
fi

docker run --rm --user "$(id -u):$(id -g)" --network host \
    -e HOME=/tmp/px4-home \
    -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory \
    -e 'GIT_CONFIG_VALUE_0=*' \
    -v "$px4_root:/workspace" -w /workspace \
    --entrypoint /bin/bash "$image" \
    -lc 'mkdir -p "$HOME"; make px4_sitl_default'
