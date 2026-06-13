#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: uav_px4 --baylands_x500|--aruco_x500" >&2
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

PX4_GZ_STANDALONE=1 \
PX4_GZ_WORLD="$world" \
PX4_SYS_AUTOSTART=4001 \
PX4_GZ_MODEL_NAME=x500 \
./build/px4_sitl_default/bin/px4
