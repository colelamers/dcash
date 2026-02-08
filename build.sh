#!/bin/bash

set -e  # Exit on error

# --- Arg modifiable ---
BUILD_TYPE="debug"      # default to DUB debug
EXECUTE_APP=0
CLEANUP=0
EXEC_VALGRIND=0
PERFORM_BUILD=0
EXEC_GDB=0
ERROR_CHECK=0
COMPILER="dmd"          # default compiler, can be ldc or gdc

# --- Hardcoded ---
EXEC_NAME="dcash"
SRC_DIR="${PWD}"
BUILD_DIR="${SRC_DIR}/build"
BIN_DIR="${SRC_DIR}/bin/${BUILD_TYPE}"
EXEC_BIN_FILE_PATH="${BIN_DIR}/${EXEC_NAME}"

# --- Functions ---

error() {
    echo "::Error Checking not implemented for D yet."
    echo "You can implement dscanner/dcd or dub lint checks if needed."
}

usage() {
    echo "::Usage: $0 [-b|-c|-d|-e|-h|-r|-v|-x]"
    echo "    -b   Run debug version with gdb"
    echo "    -c   Cleanup build/bin directories"
    echo "    -d   Build debug version"
    echo "    -e   Execute built binary"
    echo "    -h   Show help"
    echo "    -r   Build release version"
    echo "    -v   Run Valgrind"
    echo "    -x   Use LDC compiler instead of DMD"
}

cleanup() {
    echo "::Cleaning build/bin directories..."
    rm -rf "$BUILD_DIR"
    rm -rf "$BIN_DIR"
}

build() {
    echo "::Building ${BUILD_TYPE} binary with ${COMPILER}..."
    mkdir -p "$BIN_DIR"

    # Build with DUB
    if [[ "$BUILD_TYPE" == "release" ]]; then
        dub build --compiler="$COMPILER" --build=release
        # Copy binary to bin/release
        mkdir -p "$BIN_DIR"
        cp "${SRC_DIR}/build/${EXEC_NAME}" "$EXEC_BIN_FILE_PATH"
    else
        dub build --compiler="$COMPILER" --build=debug
        mkdir -p "$BIN_DIR"
        cp "${SRC_DIR}/build/${EXEC_NAME}" "$EXEC_BIN_FILE_PATH"
    fi
    mv "$EXEC_BIN_FILE_PATH" "${EXEC_BIN_FILE_PATH}_${BUILD_TYPE}"
    echo "::Build complete: $EXEC_BIN_FILE_PATH"
}

execute() {
    echo "::Executing App..."
    if [[ -x "$EXEC_BIN_FILE_PATH" ]]; then
        "$EXEC_BIN_FILE_PATH"
    else
        echo "::Error: Binary does not exist $EXEC_BIN_FILE_PATH"
        exit 1
    fi
}

debug() {
    echo "::Debugging App..."
    local DEBUG_EXEC="${EXEC_BIN_FILE_PATH}_debug"
    if [[ -x "$DEBUG_EXEC" ]]; then
        gdb "$DEBUG_EXEC"
    else
        echo "::Error: Debug binary not found at $DEBUG_EXEC"
        exit 1
    fi
}

run_valgrind() {
    # todo; still test this. never tried it yet.
    if [[ -x "$EXEC_BIN_FILE_PATH" ]]; then
        echo "::Running $EXEC_NAME with valgrind..."
        valgrind -s \
                 --leak-check=full \
                 --track-origins=yes \
                 --show-leak-kinds=all \
                 "$EXEC_BIN_FILE_PATH"
    else
        echo "::Error: Binary not found at ${EXEC_BIN_FILE_PATH}"
        exit 1
    fi
}

# --- Parse options ---
while getopts "bcdehrvx" opt; do
    case $opt in
        b) EXEC_GDB=1 ;;
        c) CLEANUP=1 ;;
        d) BUILD_TYPE="debug"; PERFORM_BUILD=1 ;;
        e) EXECUTE_APP=1 ;;
        h) usage; exit 0 ;;
        r) BUILD_TYPE="release"; PERFORM_BUILD=1 ;;
        v) EXEC_VALGRIND=1 ;;
        x) COMPILER="ldc" ;;
        *) usage; exit 1 ;;
    esac
done

# --- Update paths ---
BIN_DIR="${SRC_DIR}/bin/${BUILD_TYPE}"
EXEC_BIN_FILE_PATH="${BIN_DIR}/${EXEC_NAME}"

# --- Main flow ---
if [[ $CLEANUP == 1 ]]; then
    clear;
    cleanup
fi

if [[ $PERFORM_BUILD == 1 ]]; then
    clear;
    build
fi

if [[ $EXEC_GDB == 1 ]]; then
    clear;
    debug
fi

if [[ $EXEC_VALGRIND == 1 ]]; then
    clear;
    run_valgrind
fi

if [[ $EXECUTE_APP == 1 ]]; then
    clear;
    execute
fi
