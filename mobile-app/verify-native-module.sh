#!/bin/bash

echo "🔍 Verifying Native Module Setup..."
echo ""

# Check if Kotlin files exist
echo "✓ Checking Kotlin files..."
FILES=(
  "android/app/src/main/java/com/anonymous/rnapp/wasmbridge/WasmModule.kt"
  "android/app/src/main/java/com/anonymous/rnapp/wasmbridge/WasmPackage.kt"
  "android/app/src/main/java/com/anonymous/rnapp/wasmmanager/WasmManager.kt"
  "android/app/src/main/java/com/anonymous/rnapp/MainApplication.kt"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✓ $file exists"
  else
    echo "  ✗ $file missing!"
    exit 1
  fi
done

echo ""
echo "✓ Checking package declarations..."

# Check WasmModule.kt
if grep -q "package com.anonymous.rnapp.wasmbridge" android/app/src/main/java/com/anonymous/rnapp/wasmbridge/WasmModule.kt; then
  echo "  ✓ WasmModule.kt has correct package"
else
  echo "  ✗ WasmModule.kt has wrong package!"
  exit 1
fi

# Check WasmPackage.kt
if grep -q "package com.anonymous.rnapp.wasmbridge" android/app/src/main/java/com/anonymous/rnapp/wasmbridge/WasmPackage.kt; then
  echo "  ✓ WasmPackage.kt has correct package"
else
  echo "  ✗ WasmPackage.kt has wrong package!"
  exit 1
fi

# Check WasmManager.kt
if grep -q "package com.anonymous.rnapp.wasmmanager" android/app/src/main/java/com/anonymous/rnapp/wasmmanager/WasmManager.kt; then
  echo "  ✓ WasmManager.kt has correct package"
else
  echo "  ✗ WasmManager.kt has wrong package!"
  exit 1
fi

echo ""
echo "✓ Checking imports in MainApplication.kt..."

if grep -q "import com.anonymous.rnapp.wasmbridge.WasmPackage" android/app/src/main/java/com/anonymous/rnapp/MainApplication.kt; then
  echo "  ✓ WasmPackage import correct"
else
  echo "  ✗ WasmPackage import missing or wrong!"
  exit 1
fi

if grep -q "import com.anonymous.rnapp.wasmmanager.WasmManager" android/app/src/main/java/com/anonymous/rnapp/MainApplication.kt; then
  echo "  ✓ WasmManager import correct"
else
  echo "  ✗ WasmManager import missing or wrong!"
  exit 1
fi

# Check if package is registered
if grep -q "packages.add(WasmPackage())" android/app/src/main/java/com/anonymous/rnapp/MainApplication.kt; then
  echo "  ✓ WasmPackage is registered"
else
  echo "  ✗ WasmPackage not registered!"
  exit 1
fi

echo ""
echo "🎉 All checks passed! Native module setup looks correct."
echo ""
echo "📝 Summary of fixes applied:"
echo "  1. Fixed package names to match directory structure"
echo "  2. Added missing WasmManager import"
echo "  3. Created stub implementation to avoid crashes"
echo "  4. Optimized React Native imports in App.tsx"
echo ""
echo "🚀 Next steps:"
echo "  1. If you have an Android device with USB debugging:"
echo "     npm run android"
echo ""
echo "  2. Or build an APK manually:"
echo "     cd android && ./gradlew assembleDebug"
echo "     # APK will be in: android/app/build/outputs/apk/debug/app-debug.apk"
echo ""
echo "  3. Test compilation only:"
echo "     cd android && ./gradlew :app:compileDebugKotlin"
