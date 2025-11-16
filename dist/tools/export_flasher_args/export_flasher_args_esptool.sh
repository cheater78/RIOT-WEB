#!/usr/bin/env bash
set -euo pipefail

# esptool-stub <output.json> <flash_cmd_args[]>

OUTPUT_FILE="$1"
shift

BAUD_RATE=0
FLASH_MODE=""
FLASH_SIZE=""
FLASH_FREQ=""
COMPRESS=true
ERASE_ALL=false
FLASH_FILES=()

arg_value() {
	if [ $# -lt 2 ]; then
		echo "Error: missing value for $1" >&2
		exit 1
	fi
	echo $2
}



while (( $# )); do
	case "$1" in
	--chip|--port|--before|--after)
		# omitted - not supported by esptool-js
		shift 2
		;;
	write-flash)
		# should always be there, but no use (just the cmd for flashing)
		shift
		;;
	--baud)
		BAUD_RATE=$(arg_value $*)
		shift 2
		;;
	--flash-mode)
		FLASH_MODE=$(arg_value $*)
		shift 2
		;;
	--flash-size)
		FLASH_SIZE=$(arg_value $*)
		shift 2
		;;
	--flash-freq)
		FLASH_FREQ=$(arg_value $*)
		shift 2
		;;
	--erase-all)
		ERASE_ALL=true
		shift
		;;
	--no-compress|-u)
		COMPRESS=false
		shift
		;;
	--compress|-z)
		COMPRESS=true
		shift
		;;
	0x*)
		blob_file=$(arg_value $*)
		FLASH_FILES+=("\"$1\":\"$blob_file\"")
		shift 2
		;;
	--*)
		echo "ERROR: unrecognised option '$1'" >&2
		exit 1
		;;
	*)
		echo "ERROR: unrecognised argument '$1'" >&2
		exit 1
		;;
	esac
done


# Write to file
{
	echo "{"
	# FlashOptions
	echo "	\"baud_rate\": ${BAUD_RATE},"
	echo "	\"flash_size\": \"${FLASH_SIZE}\","
	echo "	\"flash_mode\": \"${FLASH_MODE}\","
	echo "	\"flash_freq\": \"${FLASH_FREQ}\","
	echo "	\"compress\": ${COMPRESS},"
	echo "	\"erase_all\": ${ERASE_ALL},"
	# Flash data
	echo "	\"data\": {"
	FLASH_FILE=""
	for p in "${FLASH_FILES[@]}"; do
		if [ -n "$FLASH_FILE" ]; then
			echo "		${FLASH_FILE},"
		fi
		FLASH_FILE=$p
	done
	if [ -n "$FLASH_FILE" ]; then
		echo "		${FLASH_FILE}"
	fi
	echo "	}"
	echo "}"
} > "$OUTPUT_FILE"

echo "Generated ${OUTPUT_FILE} with contents:"
cat "$OUTPUT_FILE"
