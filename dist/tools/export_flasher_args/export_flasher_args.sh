#!/usr/bin/env bash
# export_flasher_args.sh <canonical_board_name>
# will create a file ./bin/<canonical_board_name>/flasher_args.json, containing the flasher arguments
# e.g. export_flasher_args.sh esp32-wroom-32
# will create a file in ./bin/esp32-wroom-32/flasher_args.json

set -euo pipefail

CANONICAL_BOARD_NAME="${1:-native}"
FLASHER_ARGS_FILE="$(realpath ./bin/${CANONICAL_BOARD_NAME}/flasher_args.json)"
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"

echo "Fetching Programmer and FFLAGS using board: ${CANONICAL_BOARD_NAME}"
PROGRAMMER=$(make BOARD=${CANONICAL_BOARD_NAME} info-debug-variable-PROGRAMMER)
echo "resolved programmer: ${PROGRAMMER}"
FFLAGS=$(make BOARD=${CANONICAL_BOARD_NAME} info-debug-variable-FFLAGS)
echo "resolved FFLAGS: ${FFLAGS}"

mkdir -p "$(dirname ${FLASHER_ARGS_FILE})"
touch "${FLASHER_ARGS_FILE}"
echo "running script from: $(realpath .)"
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
