#!/bin/bash
# Comprehensive test script for Meson build system
# Tests all major build configurations

set -e  # Exit on error

echo "========================================"
echo "Testing nats.c Meson Build System"
echo "========================================"
echo ""

# Function to run a build test
test_build() {
    local test_name="$1"
    shift
    local build_dir="build_test_${test_name}"

    echo "[TEST] ${test_name}"
    echo "Build directory: ${build_dir}"
    echo "Options: $@"

    # Setup
    if meson setup "${build_dir}" "$@" > /dev/null 2>&1; then
        echo "  [OK] Configuration successful"
    else
        echo "  [FAIL] Configuration failed"
        return 1
    fi

    # Compile
    if meson compile -C "${build_dir}" > /dev/null 2>&1; then
        echo "  [OK] Build successful"
    else
        echo "  [FAIL] Build failed"
        return 1
    fi

    # Clean up
    rm -rf "${build_dir}"
    echo ""
}

# Clean any existing test builds
rm -rf build_test_*

echo "=== Basic Build Tests ==="
echo ""

# Test 1: Default build
test_build "default" \
    --wipe

# Test 2: Static library only
test_build "static_only" \
    --wipe \
    -Ddefault_library=static

# Test 3: Shared library only
test_build "shared_only" \
    --wipe \
    -Ddefault_library=shared

# Test 4: Both libraries
test_build "both_libs" \
    --wipe \
    -Ddefault_library=both

echo "=== TLS Options ==="
echo ""

# Test 5: Without TLS
test_build "no_tls" \
    --wipe \
    -Dtls=false

# Test 6: TLS without forced host verify
test_build "tls_no_force_verify" \
    --wipe \
    -Dtls=true \
    -Dtls_force_host_verify=false

echo "=== Examples Tests ==="
echo ""

# Test 7: With examples
test_build "with_examples" \
    --wipe \
    -Dexamples=true

# Test 8: Static examples (requires both libs)
test_build "static_examples" \
    --wipe \
    -Ddefault_library=both \
    -Dexamples=true \
    -Dstatic_examples=true

echo "=== Optional Dependencies ==="
echo ""

# Test 9: With libsodium (if available)
if pkg-config --exists libsodium 2>/dev/null; then
    test_build "with_sodium" \
        --wipe \
        -Duse_sodium=true
else
    echo "[SKIP] libsodium not available, skipping test"
    echo ""
fi

# Test 10: With streaming (if protobuf-c available)
if pkg-config --exists libprotobuf-c 2>/dev/null; then
    test_build "with_streaming" \
        --wipe \
        -Dstreaming=true
else
    echo "[SKIP] libprotobuf-c not available, skipping streaming test"
    echo ""
fi

echo "=== Platform-Specific Options ==="
echo ""

# Test 11: No spin (for architectures without spin support)
test_build "no_spin" \
    --wipe \
    -Dno_spin=true

# Test 12: No prefix for connection status
test_build "no_prefix_connsts" \
    --wipe \
    -Dno_prefix_connsts=true

# Test 13: Experimental API
test_build "experimental" \
    --wipe \
    -Dexperimental=true

# Test 14: Compiler hardening
test_build "hardening" \
    --wipe \
    -Dcompiler_hardening=true

echo "=== Build Types ==="
echo ""

# Test 15: Debug build
test_build "debug" \
    --wipe \
    --buildtype=debug

# Test 16: Release build
test_build "release" \
    --wipe \
    --buildtype=release

# Test 17: MinSize build
test_build "minsize" \
    --wipe \
    --buildtype=minsize

echo "=== Combined Tests ==="
echo ""

# Test 18: Full featured build
test_build "full_featured" \
    --wipe \
    -Ddefault_library=both \
    -Dtls=true \
    -Dexamples=true \
    -Dexperimental=true \
    --buildtype=release

# Test 19: Minimal build
test_build "minimal" \
    --wipe \
    -Ddefault_library=static \
    -Dtls=false \
    -Dexamples=false \
    --buildtype=minsize

echo "=== Coverage Build ==="
echo ""

# Test 20: Coverage build
test_build "coverage" \
    --wipe \
    -Db_coverage=true \
    --buildtype=debug

echo "========================================"
echo "All tests completed successfully!"
echo "========================================"
