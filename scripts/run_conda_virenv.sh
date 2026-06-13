#!/usr/bin/env bash

UAV_CONDA_ENV="${UAV_CONDA_ENV:-uav-mavsdk}"
UAV_MAVSDK_TEST_DIR="${UAV_MAVSDK_TEST_DIR:-$HOME/dariusuav/mavsdk_test}"

usage() {
    echo "Usage: uav_env --open|--close" >&2
}

ensure_conda() {
    if command -v conda >/dev/null 2>&1; then
        return 0
    fi

    if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/anaconda3/etc/profile.d/conda.sh"
    elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    fi

    if ! command -v conda >/dev/null 2>&1; then
        echo "conda is not available in this shell" >&2
        return 1
    fi
}

exit_status=0
action=""

case "${1:-}" in
    --open)
        action="open"
        ;;
    --close)
        action="close"
        ;;
    -h|--help)
        usage
        ;;
    *)
        usage
        exit_status=2
        ;;
esac

if [ "$exit_status" -eq 0 ] && [ -n "$action" ]; then
    shift
    if [ "$#" -ne 0 ]; then
        usage
        exit_status=2
    fi
fi

if [ "$exit_status" -eq 0 ] && [ -n "$action" ]; then
    if ! ensure_conda; then
        exit_status=1
    fi
fi

if [ "$exit_status" -eq 0 ]; then
    case "$action" in
        open)
            conda activate "$UAV_CONDA_ENV" || exit_status="$?"
            if [ "$exit_status" -eq 0 ]; then
                cd "$UAV_MAVSDK_TEST_DIR" || exit_status="$?"
            fi
            ;;
        close)
            conda deactivate || exit_status="$?"
            ;;
    esac
fi

return "$exit_status" 2>/dev/null || exit "$exit_status"
