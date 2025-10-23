# React Native WASM Module - Complete Setup

This repository contains a complete implementation of a WebAssembly (WASM) native module for React Native, supporting both **iOS** and **Android** platforms.

## 📋 Overview

The project demonstrates how to create a native module that can execute WASM code from React Native JavaScript. Currently implemented with a stub that performs addition, but ready to integrate with real WASM runtimes.

## 🏗️ Architecture

```
React Native JavaScript Layer
           ↓
    NativeModules Bridge
           ↓
    ┌─────────────────────┬─────────────────────┐
    ↓                     ↓                     ↓
iOS (Swift)         Android (Kotlin)      Future Web
WasmModule          WasmModule                  
    ↓                     ↓                     
WasmManager         WasmManager                 
    ↓                     ↓                     
WASM Runtime        WASM Runtime                
```

## 📁 Project Structure

```
rn-app/
├── App.tsx                      # React Native app with WASM integration
├── package.json                 # Dependencies
│
├── ios/                         # iOS implementation
│   └── rnapp/
│       ├── WasmModule.swift     # iOS bridge module
│       ├── WasmModule.m         # Objective-C export
│       ├── WasmManager.swift    # iOS runtime manager
│       └── AppDelegate.swift
│
├── android/                     # Android implementation
│   └── app/src/main/java/com/anonymous/rnapp/
│       ├── wasmbridge/
│       │   ├── WasmModule.kt    # Android bridge module
│       │   └── WasmPackage.kt   # Package registration
│       └── wasmmanager/
│           └── WasmManager.kt   # Android runtime manager
│
├── test-ios.sh                  # iOS testing script
├── test-android.sh              # Android testing script
├── verify-ios-module.sh         # iOS verification script
├── verify-native-module.sh      # Android verification script
│
└── Documentation/
    ├── IOS-WASM-SETUP.md        # iOS setup guide
    ├── WSL-ANDROID-SETUP.md     # Android setup guide
    ├── PLATFORM-COMPARISON.md   # iOS vs Android comparison
    └── QUICK-START.md           # Quick start guide
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm
- For iOS: macOS with Xcode and CocoaPods
- For Android: Android SDK, Java 17+
- Expo CLI: `npm install -g expo-cli`

### Installation

```bash
# Clone and install dependencies
cd rn-app
npm install

# iOS setup (macOS only)
cd ios && pod install && cd ..

# Android setup
# Ensure Android SDK is configured
```

### Verification

```bash
# Verify iOS setup
./verify-ios-module.sh

# Verify Android setup
./verify-native-module.sh
```

### Running the App

```bash
# iOS
npx expo run:ios
# or use the interactive script
./test-ios.sh

# Android
npx expo run:android
# or use the interactive script
./test-android.sh
```

## 📱 Platform-Specific Guides

- **[iOS Setup Guide](IOS-WASM-SETUP.md)** - Complete iOS implementation details
- **[Android Setup Guide](WSL-ANDROID-SETUP.md)** - Complete Android implementation details
- **[Platform Comparison](PLATFORM-COMPARISON.md)** - Side-by-side iOS vs Android comparison

## 💻 Using the WASM Module

In your React Native code:

```typescript
import { NativeModules } from 'react-native';

const { WasmModule } = NativeModules;

// Call the add function
async function testWasm() {
  try {
    const result = await WasmModule.add(5, 3);
    console.log('WASM add result:', result); // 8
  } catch (error) {
    console.error('WASM error:', error);
  }
}
```

## 🔧 Development Scripts

### iOS Scripts

```bash
./test-ios.sh           # Interactive iOS testing menu
./verify-ios-module.sh  # Verify iOS module setup
```

Options in `test-ios.sh`:
1. Check iOS setup
2. List available simulators
3. Install CocoaPods dependencies
4. Build iOS app
5. Run on iOS Simulator
6. Start Metro bundler
7. View logs (filtered for WasmModule)
8. Clean iOS build
9. Run full test sequence

### Android Scripts

```bash
./test-android.sh            # Interactive Android testing menu
./verify-native-module.sh    # Verify Android module setup
```

Options in `test-android.sh`:
1. Check Android setup (WSL)
2. List connected devices
3. Install npm dependencies
4. Build Android app
5. Run on device/emulator
6. Start Metro bundler
7. View logs (filtered for WasmModule)
8. Clean Android build
9. Run full test sequence

## 📊 Module Implementation Status

| Feature | iOS | Android | Status |
|---------|-----|---------|--------|
| Native Bridge | ✅ Swift | ✅ Kotlin | Complete |
| Runtime Manager | ✅ WasmManager | ✅ WasmManager | Complete |
| Stub Implementation | ✅ Add function | ✅ Add function | Complete |
| Logging | ✅ os_log | ✅ Log.d | Complete |
| Error Handling | ✅ Promises | ✅ Promises | Complete |
| WASM Runtime | ⏳ Pending | ⏳ Pending | TODO |
| Asset Loading | ⏳ Pending | ⏳ Pending | TODO |

## 🔍 Verification Checks

Both verification scripts check:

✅ All required native files exist  
✅ Correct package/module declarations  
✅ Method implementations present  
✅ Proper registration in build system  
✅ Bridging/export mechanisms configured  

## 📝 Logging & Debugging

### iOS Logs
```bash
# Using test script
./test-ios.sh  # Choose option 7

# Manual
xcrun simctl spawn booted log stream \
  --predicate 'processImagePath contains "rnapp"' \
  | grep -E "(WasmModule|WasmManager)"
```

### Android Logs
```bash
# Using test script
./test-android.sh  # Choose option 7

# Manual
adb logcat | grep -E "(WasmModule|WasmManager|ReactNativeJS)"
```

## 🔮 Next Steps

### 1. Integrate Real WASM Runtime

Choose and integrate a WASM runtime:

**iOS Options:**
- Wasmer (recommended)
- WAMR (WebAssembly Micro Runtime)
- Custom C-based runtime

**Android Options:**
- WasmEdge (recommended)
- Wasmer
- WAMR

### 2. Load WASM Files

**iOS:**
```swift
// Add main.wasm to Xcode project
guard let wasmPath = Bundle.main.path(forResource: "main", ofType: "wasm"),
      let wasmData = try? Data(contentsOf: URL(fileURLWithPath: wasmPath)) else {
    return
}
```

**Android:**
```kotlin
// Place main.wasm in android/app/src/main/assets/
val wasmBytes = context.assets.open("main.wasm").readBytes()
```

### 3. Add More Methods

Follow the established pattern:

**iOS:**
1. Add method to `WasmManager.swift`
2. Add bridge method to `WasmModule.swift`
3. Export in `WasmModule.m`

**Android:**
1. Add method to `WasmManager.kt`
2. Add `@ReactMethod` in `WasmModule.kt`

### 4. Performance Optimization

- Profile with Xcode Instruments (iOS)
- Profile with Android Profiler (Android)
- Consider threading for heavy operations
- Optimize WASM memory management

## 🐛 Troubleshooting

### Module Not Found

**iOS:**
```bash
./verify-ios-module.sh
./test-ios.sh  # Option 8 (clean) then 4 (build)
cd ios && pod install && cd ..
```

**Android:**
```bash
./verify-native-module.sh
./test-android.sh  # Option 8 (clean) then 4 (build)
```

### Build Errors

**iOS:**
- Check Swift version is 5.0+
- Verify bridging header: `rnapp/rnapp-Bridging-Header.h`
- Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

**Android:**
- Check Kotlin version compatibility
- Verify package declarations match folder structure
- Sync Gradle: `cd android && ./gradlew --refresh-dependencies`

### Logs Not Appearing

**iOS:**
- Ensure correct simulator is selected
- Check log levels in code

**Android:**
- Verify device is connected: `adb devices`
- Check USB debugging is enabled

## 📚 Documentation

Comprehensive documentation available:

- **[IOS-WASM-SETUP.md](IOS-WASM-SETUP.md)** - iOS implementation guide
- **[WSL-ANDROID-SETUP.md](WSL-ANDROID-SETUP.md)** - Android implementation guide
- **[PLATFORM-COMPARISON.md](PLATFORM-COMPARISON.md)** - Platform comparison
- **[QUICK-START.md](QUICK-START.md)** - Quick start guide
- **[ADB-CONNECTION-GUIDE.md](ADB-CONNECTION-GUIDE.md)** - ADB setup for WSL

## 🤝 Contributing

When adding new features:

1. Implement on both platforms for consistency
2. Update verification scripts
3. Add tests
4. Update documentation
5. Follow existing code patterns

## 📄 License

[Your License Here]

## 🎯 Key Achievements

✅ Complete iOS native module with Swift  
✅ Complete Android native module with Kotlin  
✅ Identical JavaScript API on both platforms  
✅ Comprehensive testing scripts  
✅ Verification scripts for both platforms  
✅ Detailed documentation and comparisons  
✅ Ready for WASM runtime integration  

---

**Status:** Production-ready structure, stub implementation. Ready for WASM runtime integration.

For questions or issues, please refer to the platform-specific guides or create an issue.
