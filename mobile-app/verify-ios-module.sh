#!/bin/bash

# Verification script for iOS Native WASM Module

echo "🔍 Verifying iOS Native Module Setup..."
echo "========================================"
echo ""

# Array to store verification results
declare -a results

# File paths to check
files=(
  "ios/rnapp/WasmModule.swift"
  "ios/rnapp/WasmModule.m"
  "ios/rnapp/WasmManager.swift"
  "ios/rnapp.xcodeproj/project.pbxproj"
)

echo "📁 Checking required files..."
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✓ $file exists"
    results+=("✓")
  else
    echo "  ✗ $file is missing!"
    results+=("✗")
  fi
done

echo ""
echo "🔍 Checking file contents..."

# Check WasmModule.swift
if grep -q "@objc(WasmModule)" ios/rnapp/WasmModule.swift; then
  echo "  ✓ WasmModule.swift has correct @objc decorator"
  results+=("✓")
else
  echo "  ✗ WasmModule.swift missing @objc decorator!"
  results+=("✗")
fi

if grep -q "WasmManager.shared.callAdd" ios/rnapp/WasmModule.swift; then
  echo "  ✓ WasmModule.swift calls WasmManager"
  results+=("✓")
else
  echo "  ✗ WasmModule.swift doesn't call WasmManager!"
  results+=("✗")
fi

# Check WasmModule.m
if grep -q "RCT_EXTERN_MODULE(WasmModule" ios/rnapp/WasmModule.m; then
  echo "  ✓ WasmModule.m has correct RCT_EXTERN_MODULE"
  results+=("✓")
else
  echo "  ✗ WasmModule.m missing RCT_EXTERN_MODULE!"
  results+=("✗")
fi

# Check WasmManager.swift
if grep -q "class WasmManager" ios/rnapp/WasmManager.swift; then
  echo "  ✓ WasmManager.swift has WasmManager class"
  results+=("✓")
else
  echo "  ✗ WasmManager.swift missing WasmManager class!"
  results+=("✗")
fi

if grep -q "func callAdd" ios/rnapp/WasmManager.swift; then
  echo "  ✓ WasmManager.swift has callAdd function"
  results+=("✓")
else
  echo "  ✗ WasmManager.swift missing callAdd function!"
  results+=("✗")
fi

# Check Xcode project
if grep -q "WasmModule.swift" ios/rnapp.xcodeproj/project.pbxproj; then
  echo "  ✓ WasmModule.swift is registered in Xcode project"
  results+=("✓")
else
  echo "  ✗ WasmModule.swift not registered in Xcode project!"
  results+=("✗")
fi

if grep -q "WasmManager.swift" ios/rnapp.xcodeproj/project.pbxproj; then
  echo "  ✓ WasmManager.swift is registered in Xcode project"
  results+=("✓")
else
  echo "  ✗ WasmManager.swift not registered in Xcode project!"
  results+=("✗")
fi

echo ""
echo "📊 Summary"
echo "=========="

# Count successful checks
success_count=0
for result in "${results[@]}"; do
  if [ "$result" = "✓" ]; then
    ((success_count++))
  fi
done

total_checks=${#results[@]}
echo "Passed: $success_count/$total_checks checks"

if [ $success_count -eq $total_checks ]; then
  echo ""
  echo "🎉 All checks passed! iOS native module is properly configured."
  echo ""
  echo "Next steps:"
  echo "1. Run 'cd ios && pod install' to install CocoaPods dependencies"
  echo "2. Run './test-ios.sh' to build and test on iOS simulator"
  exit 0
else
  echo ""
  echo "❌ Some checks failed. Please review the errors above."
  exit 1
fi
