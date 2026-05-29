#!/bin/bash
set -e

echo "------------------------------------------------"
echo "Running tests in example project..."
echo "------------------------------------------------"

# Run unit/widget tests
echo "1. Running unit/widget tests..."
fvm flutter test

# Run integration tests
# Note: This requires a device/emulator to be running.
echo ""
echo "2. Running integration tests..."
fvm flutter test integration_test/app_test.dart

echo ""
echo "Example project tests completed successfully!"
