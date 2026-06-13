#!/usr/bin/env bash

set -uo pipefail

usage() {
    echo "Usage: uav_clr [--kill]" >&2
}

signal=""

case "${1:-}" in
    "")
        ;;
    --kill)
        signal="-9"
        shift
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

if [ "$#" -gt 0 ]; then
    usage
    exit 2
fi

patterns=(
    "px4"
    "gz sim"
    "gazebo"
    "QGroundControl"
)

for pattern in "${patterns[@]}"; do
    if [ -n "$signal" ]; then
        pkill "$signal" -f "$pattern" 2>/dev/null || true
    else
        pkill -f "$pattern" 2>/dev/null || true
    fi
done
