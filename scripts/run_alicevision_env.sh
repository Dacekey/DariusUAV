#!/usr/bin/env bash

# AliceVision / Meshroom Environment Setup Script
# Sourcing this script configures MESHROOM_ROOT, ALICEVISION_ROOT, LD_LIBRARY_PATH, and PATH.

export MESHROOM_ROOT="$HOME/dariusuav/alicevision/Meshroom-2023.3.0"
export ALICEVISION_ROOT="$MESHROOM_ROOT/aliceVision"
export ALICEVISION_SENSOR_DB="$ALICEVISION_ROOT/share/aliceVision/cameraSensors.db"

export LD_LIBRARY_PATH="$ALICEVISION_ROOT/lib:$MESHROOM_ROOT/lib:${LD_LIBRARY_PATH:-}"
export PATH="$ALICEVISION_ROOT/bin:$MESHROOM_ROOT:$PATH"

if [ "${1:-}" = "--check" ]; then
    echo "=== AliceVision Environment Configuration ==="
    echo "MESHROOM_ROOT:      $MESHROOM_ROOT"
    echo "ALICEVISION_ROOT:   $ALICEVISION_ROOT"
    echo "ALICEVISION_SENSOR: $ALICEVISION_SENSOR_DB"
    echo "PATH & LD_LIBRARY_PATH updated."
    
    if command -v aliceVision_cameraInit >/dev/null 2>&1; then
        echo "[OK] aliceVision_cameraInit binary detected in PATH."
    else
        echo "[ERROR] aliceVision_cameraInit not found in PATH."
    fi
    if command -v meshroom_batch >/dev/null 2>&1; then
        echo "[OK] meshroom_batch binary detected in PATH."
    else
        echo "[ERROR] meshroom_batch not found in PATH."
    fi
fi
