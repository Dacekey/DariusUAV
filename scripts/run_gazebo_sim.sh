#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: uav_gzb --baylands_x500|--aruco_x500" >&2
}

case "${1:-}" in
    --baylands_x500)
        world="baylands_x500"
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

cd "$HOME/dariusuav/PX4-Autopilot" || exit 1

python3 Tools/simulation/gz/simulation-gazebo --world "$world"
