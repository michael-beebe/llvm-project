#!/bin/bash

# OpenSHMEM MLIR Dialect Test Runner
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
BUILD_DIR="build"
TEST_DIR="mlir/test/Dialect/OpenSHMEM"
MLIR_OPT="$BUILD_DIR/bin/mlir-opt"
MLIR_TRANSLATE="$BUILD_DIR/bin/mlir-translate"

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}OpenSHMEM MLIR Dialect Test Suite${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"

    if [[ ! -f "$MLIR_OPT" ]]; then
        echo -e "${RED}❌ mlir-opt not found at $MLIR_OPT${NC}"
        echo "Please build MLIR first with: ./tmp/build.sh --mlir"
        exit 1
    fi

    if [[ ! -f "$MLIR_TRANSLATE" ]]; then
        echo -e "${RED}❌ mlir-translate not found at $MLIR_TRANSLATE${NC}"
        echo "Please build MLIR first with: ./tmp/build.sh --mlir"
        exit 1
    fi

    if [[ ! -d "$TEST_DIR" ]]; then
        echo -e "${RED}❌ Test directory not found: $TEST_DIR${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Prerequisites OK${NC}"
    echo
}

run_test() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .mlir)

    echo -n "Testing $test_name: "
    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    # Run mlir-opt on the test file
    if "$MLIR_OPT" "$test_file" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))

        # If MLIR_TO_LLVM is set, translate to LLVM IR
        if [[ "${MLIR_TO_LLVM:-}" == "1" ]]; then
            echo -e "${BLUE}Translating $test_name to LLVM IR:${NC}"

            # Create temporary file for intermediate LLVM dialect
            local temp_llvm=$(mktemp --suffix=.mlir)

            # Step 1: Convert OpenSHMEM and func dialects to LLVM dialect
            if "$MLIR_OPT" --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts "$test_file" >"$temp_llvm" 2>/dev/null; then
                # Step 2: Translate LLVM dialect to LLVM IR
                if "$MLIR_TRANSLATE" --mlir-to-llvmir "$temp_llvm" 2>/dev/null | sed 's/^/  /'; then
                    echo
                else
                    echo -e "${RED}  ❌ Failed to translate to LLVM IR${NC}"
                fi
            else
                echo -e "${RED}  ❌ Failed to convert to LLVM dialect${NC}"
                if [[ "${VERBOSE:-}" == "1" ]]; then
                    echo -e "${RED}Conversion error details:${NC}"
                    "$MLIR_OPT" --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts "$test_file" 2>&1 | sed 's/^/  /'
                fi
            fi

            # Clean up temporary file
            rm -f "$temp_llvm"
        fi

        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))

        # Show the error if requested
        if [[ "${VERBOSE:-}" == "1" ]]; then
            echo -e "${RED}Error details:${NC}"
            "$MLIR_OPT" "$test_file" 2>&1 | sed 's/^/  /'
            echo
        fi
        return 1
    fi
}

run_all_tests() {
    echo -e "${YELLOW}Running OpenSHMEM dialect tests...${NC}"
    echo

    # Find all .mlir test files
    local test_files=($(find "$TEST_DIR" -name "*.mlir" | sort))

    if [[ ${#test_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No test files found in $TEST_DIR${NC}"
        return
    fi

    # Run each test
    for test_file in "${test_files[@]}"; do
        run_test "$test_file"
    done
}

test_dialect_registration() {
    echo -e "${YELLOW}Testing dialect registration...${NC}"

    if "$MLIR_OPT" --help | grep -q "openshmem"; then
        echo -e "${GREEN}✅ OpenSHMEM dialect is registered${NC}"

        # Show available passes
        echo -e "${BLUE}Available OpenSHMEM passes:${NC}"
        "$MLIR_OPT" --help | grep openshmem | sed 's/^/  /'
    else
        echo -e "${RED}❌ OpenSHMEM dialect not found${NC}"
        return 1
    fi
    echo
}

run_basic_functionality_test() {
    echo -e "${YELLOW}Testing basic functionality...${NC}"

    # Create a simple test
    local temp_test=$(mktemp --suffix=.mlir)
    cat >"$temp_test" <<'EOF'
module {
  func.func @simple_test() {
    openshmem.init
    %pe = openshmem.my_pe : i32
    %npes = openshmem.n_pes : i32
    openshmem.finalize
    return
  }
}
EOF

    if run_test "$temp_test"; then
        echo -e "${GREEN}✅ Basic functionality works${NC}"
    else
        echo -e "${RED}❌ Basic functionality failed${NC}"
    fi

    rm -f "$temp_test"
    echo
}

print_summary() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}Test Summary${NC}"
    echo -e "${BLUE}================================${NC}"
    echo -e "Total tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"

    if [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    else
        echo -e "Failed: $FAILED_TESTS"
    fi

    echo
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
    else
        echo -e "${RED}💥 Some tests failed${NC}"
        echo -e "${YELLOW}Run with VERBOSE=1 for error details${NC}"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    --verbose | -v)
        VERBOSE=1
        shift
        ;;
    --mlir-to-llvmir)
        MLIR_TO_LLVM=1
        shift
        ;;
    --help | -h)
        echo "OpenSHMEM MLIR Dialect Test Runner"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --verbose, -v    Show detailed error messages"
        echo "  --mlir-to-llvmir   Run mlir-translate --mlir-to-llvmir on the test files"
        echo "  --help, -h       Show this help message"
        echo
        echo "Environment variables:"
        echo "  VERBOSE=1        Same as --verbose"
        echo "  MLIR_TO_LLVM=1   Same as --mlir-to-llvmir"
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
    esac
done

# Main execution
main() {
    print_header
    check_prerequisites
    test_dialect_registration
    run_basic_functionality_test
    run_all_tests
    print_summary

    # Exit with error code if any tests failed
    exit $FAILED_TESTS
}

# Run main function
main "$@"



