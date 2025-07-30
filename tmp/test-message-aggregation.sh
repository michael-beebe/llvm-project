#!/bin/bash

set -e

BUILD_DIR="build"
MSG_AGG_TEST_FILE="mlir/test/Dialect/OpenSHMEM/message-aggregation.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
FILECHECK="$BUILD_DIR/bin/FileCheck"
OUTPUT_DIR="tmp/test_outputs"
MSG_AGG_OUT="$OUTPUT_DIR/message-aggregation.mlir"
MSG_AGG_DEBUG_OUT="$OUTPUT_DIR/message-aggregation-debug.mlir"

if command -v bat &> /dev/null; then
  CAT="bat --paging=never"
else
  CAT="cat"
fi

mkdir -p "$OUTPUT_DIR"

# Check if tools exist
if [ ! -f "$MLIR_OPT" ]; then
    echo "ERROR: mlir-opt not found. Build MLIR first: ./tmp/build.sh --mlir"
    exit 1
fi
if [ ! -f "$FILECHECK" ]; then
    echo "ERROR: FileCheck not found. Build MLIR first: ./tmp/build.sh --mlir"
    exit 1
fi

echo "Testing OpenSHMEM Message Aggregation Pass"
echo "=========================================="

echo -e "\n===== [ Testing Message Aggregation Pass ] ====="
if "$MLIR_OPT" "$MSG_AGG_TEST_FILE" \
    --openshmem-message-aggregation \
    -o "$MSG_AGG_OUT" && \
   "$MLIR_OPT" "$MSG_AGG_TEST_FILE" \
    --openshmem-message-aggregation \
    | "$FILECHECK" "$MSG_AGG_TEST_FILE"; then
    echo "PASS: Message aggregation (FileCheck validated)"
    echo -e "\nOriginal MLIR:"
    $CAT "$MSG_AGG_TEST_FILE"
    echo -e "\nAfter message aggregation:"
    $CAT "$MSG_AGG_OUT"
else
    echo "FAIL: Message aggregation failed FileCheck validation"
    exit 1
fi

echo -e "\n===== [ Testing Message Aggregation with Debug ] ====="
echo "Configuration: debug=true (default options)"
echo "Running pass with debug output..."
if "$MLIR_OPT" "$MSG_AGG_TEST_FILE" \
    --openshmem-message-aggregation="debug=1" \
    -o "$MSG_AGG_DEBUG_OUT" 2>&1; then
    echo "PASS: Message aggregation with debug output"
else
    echo "FAIL: Message aggregation with debug output failed"
    exit 1
fi

echo -e "\nAfter message aggregation (with debug):"
$CAT "$MSG_AGG_DEBUG_OUT"

echo -e "\n===== [ Testing Message Aggregation with Options ] ====="
echo "Configuration: enable-put-coalescing=false, debug=true"
echo "Expected: PUT operations should NOT be coalesced"
if "$MLIR_OPT" "$MSG_AGG_TEST_FILE" \
    --openshmem-message-aggregation="enable-put-coalescing=false debug=true" \
    -o "$OUTPUT_DIR/message-aggregation-no-put.mlir" 2>/dev/null; then
    echo "PASS: Message aggregation with put coalescing disabled"
else
    echo "FAIL: Message aggregation with put coalescing disabled failed"
    exit 1
fi

echo -e "\nConfiguration: enable-get-coalescing=false, debug=true"
echo "Expected: GET operations should NOT be coalesced (PUT operations still coalesced)"
if "$MLIR_OPT" "$MSG_AGG_TEST_FILE" \
    --openshmem-message-aggregation="enable-get-coalescing=false debug=true" \
    -o "$OUTPUT_DIR/message-aggregation-no-get.mlir" 2>/dev/null; then
    echo "PASS: Message aggregation with get coalescing disabled"
else
    echo "FAIL: Message aggregation with get coalescing disabled failed"
    exit 1
fi

echo -e "\nConfiguration: min-message-size=128, max-distance=2048, debug=true"
echo "Expected: Higher thresholds, should still coalesce identical operations"
if "$MLIR_OPT" "$MSG_AGG_TEST_FILE" \
    --openshmem-message-aggregation="min-message-size=128 max-distance=2048 debug=true" \
    -o "$OUTPUT_DIR/message-aggregation-custom.mlir" 2>/dev/null; then
    echo "PASS: Message aggregation with custom thresholds"
else
    echo "FAIL: Message aggregation with custom thresholds failed"
    exit 1
fi

echo -e "\nMessage aggregation test completed successfully!"
echo "=============================================="
echo "PASS: Message aggregation tested with FileCheck validation"
echo "Output files saved in: $OUTPUT_DIR"
echo "- Basic aggregation: $MSG_AGG_OUT"
echo "- Debug output: $MSG_AGG_DEBUG_OUT"
echo "- No put coalescing: $OUTPUT_DIR/message-aggregation-no-put.mlir"
echo "- No get coalescing: $OUTPUT_DIR/message-aggregation-no-get.mlir"
echo "- Custom thresholds: $OUTPUT_DIR/message-aggregation-custom.mlir"

