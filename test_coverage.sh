#!/bin/bash

# Script to generate mock and run unit test coverage to LCOV report

echo "🔨 Generating report for unit tests..."

# Run the build_runner command
dart run build_runner build --delete-conflicting-outputs
flutter test --coverage test/ && genhtml coverage/lcov.info -o coverage/html

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Mock generation completed successfully!"
else
    echo ""
    echo "❌ report generation failed!"
    echo "Please check the error messages above and fix any issues."
    exit 1
fi