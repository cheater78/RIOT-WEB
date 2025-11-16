#!/usr/bin/env bash
# export_flasher_args.sh <project_path> <canonical_board_name>
# will create a file <project_path>/bin/flasher_args/<canonical_board_name>.json, containing the flasher arguments
# e.g. export_flasher_args.sh esp32-wroom-32
# will create a file in <project_path>/bin/flasher_args/esp32-wroom-32.json

set -euo pipefail

PROJECT_PATH="${$1:-$(pwd)}"
CANONICAL_BOARD_NAME="${$2:-native}"
FLASHER_ARGS_FILE="${PROJECT_PATH}/bin/flasher_args/${CANONICAL_BOARD_NAME}.json"
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"

PROGRAMMER=$(make BOARD=$CANONICAL_BOARD_NAME info-debug-variable-PROGRAMMER)
FFLAGS=$(make BOARD=$CANONICAL_BOARD_NAME info-debug-variable-FFLAGS)

case "${PROGRAMMER}" in
	esptool)
		"${SCRIPT_DIR}/export_flasher_args_esptool.sh ${FLASHER_ARGS_FILE} ${FFLAGS}"
	exit 0
	;;
	*)
		echo "Programmer:'${PROGRAMMER}' not recognized or currently not implemented!" >&2
	exit 1
	;;
esac
