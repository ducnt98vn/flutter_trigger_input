#!/bin/bash
set -e

echo "================================================"
echo "Starting test suite for flutter_trigger_input"
echo "================================================"

# Run package unit tests
echo "1. Running package unit tests..."
fvm flutter test

# Run example tests
echo ""
echo "2. Running example project tests..."
if [ -f "../example/run_tests.sh" ]; then
    chmod +x ../example/run_tests.sh
    cd ../example
    ./run_tests.sh
    cd ..
else
    echo "Warning: example/run_tests.sh not found."
fi

echo ""
echo "================================================"
echo "All test suites completed successfully!"
echo "================================================"
