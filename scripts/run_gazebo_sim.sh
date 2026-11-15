#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: uav_gzb --baylands_x500|--baylands_x500_mono_cam|--aruco_x500" >&2
}

case "${1:-}" in
    --baylands_x500)
        world="baylands_x500"
        ;;
    --baylands_x500_mono_cam)
        world="baylands_x500_mono_cam"
        ;;
    --aruco_x500)
        world="aruco_x500"
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        usage
        exit 2
        ;;
esac

shift
if [[ $# -gt 0 ]]; then
    usage
    exit 2
fi

if [[ -z "${UAV_SIM_BACKEND:-}" ]]; then
    . /etc/os-release
    if [[ "$VERSION_ID" == 26.04 ]]; then
        UAV_SIM_BACKEND=container
    else
        UAV_SIM_BACKEND=native
    fi
fi

if [[ "$UAV_SIM_BACKEND" == container ]]; then
    exec "$(dirname "${BASH_SOURCE[0]}")/run_gazebo_container.sh" "$world"
fi
if [[ "$UAV_SIM_BACKEND" != native ]]; then
    echo "Unknown UAV_SIM_BACKEND: $UAV_SIM_BACKEND" >&2
    exit 2
fi

cd "$HOME/dariusuav/PX4-Autopilot" || exit 1

python3 Tools/simulation/gz/simulation-gazebo --world "$world"
