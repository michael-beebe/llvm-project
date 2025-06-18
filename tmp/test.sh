#------------------------------------------------------------------------------------
#!/bin/bash

# Simple OpenSHMEM MLIR Dialect Test
set -e

BUILD_DIR="build"
TEST_FILE="mlir/test/Dialect/OpenSHMEM/openshmemops.mlir"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"

# Default test mode
TEST_MODE="full"

# Parse arguments
while [ $# -gt 0 ]; do
	case $1 in
	--mlir-only)
		TEST_MODE="mlir"
		;;
	--llvm-only)
		TEST_MODE="llvm"
		;;
	--full)
		TEST_MODE="full"
		;;
	--help | -h)
		echo "Usage: $0 [OPTIONS]"
		echo "Options:"
		echo "  --mlir-only   Show MLIR after lowering OpenSHMEM dialect to MLIR LLVM dialect (no LLVM IR)"
		echo "  --llvm-only   Show final LLVM IR after translating MLIR LLVM dialect to LLVM IR (no OpenSHMEM dialect remains)"
		echo "  --full        Same as --llvm-only (default)"
		echo "  --help        Show this help"
		echo
		echo "Pipeline:"
		echo "  1. Input: MLIR file using the OpenSHMEM dialect (not C code)"
		echo "  2. --convert-openshmem-to-llvm: Lowers OpenSHMEM ops to MLIR's llvm dialect ops"
		echo "  3. --convert-func-to-llvm: Lowers func ops to MLIR's llvm dialect ops"
		echo "  4. --reconcile-unrealized-casts: Resolves type casts in MLIR"
		echo "  5. mlir-translate --mlir-to-llvmir: Converts MLIR llvm dialect to LLVM IR"
		echo
		echo "Examples:"
		echo "  $0 --mlir-only   # See MLIR after OpenSHMEM lowering (no LLVM IR)"
		echo "  $0 --llvm-only   # See final LLVM IR (no OpenSHMEM dialect remains)"
		echo "  $0               # Default: show final LLVM IR"
		exit 0
		;;
	*)
		echo "Unknown option: $1"
		echo "Use --help for usage information"
		exit 1
		;;
	esac
	shift
done

echo "🧪 Testing OpenSHMEM MLIR Dialect"
echo "=================================="

# Check if tools exist
if [ ! -f "$MLIR_OPT" ]; then
	echo "❌ mlir-opt not found. Build MLIR first: ./tmp/build.sh --mlir"
	exit 1
fi

if [ ! -f "$MLIR_TRANSLATE" ]; then
	echo "❌ mlir-translate not found. Build MLIR first: ./tmp/build.sh --mlir"
	exit 1
fi

echo "✅ Tools found"

echo "📝 Running OpenSHMEM test (mode: $TEST_MODE)..."
echo

INTERMEDIATE_MLIR="/tmp/openshmem-lowered.mlir"

case $TEST_MODE in
"mlir")
	echo "Generated MLIR after lowering OpenSHMEM dialect to MLIR LLVM dialect (no LLVM IR):"
	echo "-----------------------------------------------------------------------------------"
	if "$MLIR_OPT" "$TEST_FILE" --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts > "$INTERMEDIATE_MLIR" 2>&1; then
		cat "$INTERMEDIATE_MLIR"
		if grep -q "llvm.func\|func.func" "$INTERMEDIATE_MLIR"; then
			echo
			echo "✅ Test PASSED - Successfully lowered OpenSHMEM to MLIR LLVM dialect"
			exit 0
		else
			echo
			echo "❌ Test FAILED - Conversion produced empty output (no functions found)"
			exit 1
		fi
	else
		echo
		echo "❌ Test FAILED - OpenSHMEM to MLIR LLVM dialect conversion failed"
		cat "$INTERMEDIATE_MLIR"
		exit 1
	fi
	;;
"llvm"|"full")
	echo "Generated LLVM IR (no OpenSHMEM dialect remains):"
	echo "--------------------------------------------------"
	if "$MLIR_OPT" "$TEST_FILE" --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts > "$INTERMEDIATE_MLIR" 2>&1; then
		if grep -q "llvm.func\|func.func" "$INTERMEDIATE_MLIR"; then
			if "$MLIR_TRANSLATE" "$INTERMEDIATE_MLIR" --mlir-to-llvmir > /tmp/openshmem.ll 2>&1; then
				cat /tmp/openshmem.ll
				if grep -q "define\|declare" /tmp/openshmem.ll; then
					echo
					echo "✅ Test PASSED - Successfully generated final LLVM IR"
					exit 0
				else
					echo
					echo "❌ Test FAILED - Conversion produced empty output (no functions found)"
					exit 1
				fi
			else
				echo
				echo "❌ Test FAILED - LLVM IR generation failed"
				cat /tmp/openshmem.ll
				exit 1
			fi
		else
			echo
			echo "❌ Test FAILED - Lowered MLIR does not contain any functions."
			cat "$INTERMEDIATE_MLIR"
			exit 1
		fi
	else
		echo
		echo "❌ Test FAILED - OpenSHMEM to MLIR LLVM dialect conversion failed"
		cat "$INTERMEDIATE_MLIR"
		exit 1
	fi
	;;
esac
