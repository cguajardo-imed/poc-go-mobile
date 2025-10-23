# Complete Architecture Diagram

## 📱 Full Stack Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     React Native App (App.tsx)                   │
│                         JavaScript Layer                         │
│                                                                   │
│  const { WasmModule } = NativeModules;                          │
│  const result = await WasmModule.add(5, 3);                     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    React Native Bridge
                              ↓
┌──────────────────────────────┬──────────────────────────────────┐
│         iOS Stack            │        Android Stack             │
│                              │                                  │
│  ┌────────────────────────┐ │  ┌────────────────────────────┐ │
│  │   WasmModule.m         │ │  │   WasmPackage.kt           │ │
│  │   (Objective-C)        │ │  │   (Package Registration)   │ │
│  │                        │ │  │                            │ │
│  │ RCT_EXTERN_MODULE      │ │  │ createNativeModules()      │ │
│  └───────────┬────────────┘ │  └─────────────┬──────────────┘ │
│              ↓               │                ↓                │
│  ┌────────────────────────┐ │  ┌────────────────────────────┐ │
│  │   WasmModule.swift     │ │  │   WasmModule.kt            │ │
│  │   (Swift Bridge)       │ │  │   (Kotlin Bridge)          │ │
│  │                        │ │  │                            │ │
│  │ @objc(WasmModule)      │ │  │ @ReactMethod               │ │
│  │ func add(...)          │ │  │ fun add(...)               │ │
│  └───────────┬────────────┘ │  └─────────────┬──────────────┘ │
│              ↓               │                ↓                │
│  ┌────────────────────────┐ │  ┌────────────────────────────┐ │
│  │   WasmManager.swift    │ │  │   WasmManager.kt           │ │
│  │   (Runtime Manager)    │ │  │   (Runtime Manager)        │ │
│  │                        │ │  │                            │ │
│  │ static let shared      │ │  │ object WasmManager         │ │
│  │ func callAdd(...)      │ │  │ fun callAdd(...)           │ │
│  └───────────┬────────────┘ │  └─────────────┬──────────────┘ │
│              ↓               │                ↓                │
│  ┌────────────────────────┐ │  ┌────────────────────────────┐ │
│  │   WASM Runtime         │ │  │   WASM Runtime             │ │
│  │   (Future: Wasmer/     │ │  │   (Future: WasmEdge/       │ │
│  │    WAMR)               │ │  │    Wasmer)                 │ │
│  │                        │ │  │                            │ │
│  │ Current: Stub (a + b)  │ │  │ Current: Stub (a + b)      │ │
│  └────────────────────────┘ │  └────────────────────────────┘ │
│                              │                                  │
└──────────────────────────────┴──────────────────────────────────┘
```

## 🔄 Data Flow Example

### Calling `WasmModule.add(5, 3)` from JavaScript

```
┌─────────────────────────────────────────────────────────────────┐
│ Step 1: JavaScript Call                                          │
│ ────────────────────────                                        │
│ const result = await WasmModule.add(5, 3);                      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Step 2: React Native Bridge                                      │
│ ───────────────────────────                                     │
│ Serializes call and routes to native module                     │
│ Platform: iOS or Android                                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────┬──────────────────────────────────┐
│ Step 3a: iOS                 │ Step 3b: Android                 │
│ ────────────                 │ ────────────                     │
│                              │                                  │
│ WasmModule.m receives call   │ WasmModule.kt receives call      │
│   ↓                          │   ↓                              │
│ Routes to Swift              │ Directly executes                │
│   ↓                          │   ↓                              │
│ WasmModule.swift             │ Calls WasmManager.callAdd()      │
│ func add(5, 3, resolver,     │ fun add(5, 3, promise)           │
│          rejecter)           │   ↓                              │
│   ↓                          │ WasmManager.callAdd(5, 3)        │
│ WasmManager.shared           │   ↓                              │
│   .callAdd(a: 5, b: 3)       │ result = 5 + 3 = 8               │
│   ↓                          │   ↓                              │
│ result = 5 + 3 = 8           │ promise.resolve(8)               │
│   ↓                          │                                  │
│ resolver(8)                  │                                  │
│                              │                                  │
└──────────────────────────────┴──────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Step 4: Bridge Returns Result                                    │
│ ─────────────────────────────                                   │
│ Serializes result (8) back to JavaScript                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Step 5: JavaScript Receives                                      │
│ ───────────────────────────                                     │
│ result = 8                                                       │
│ console.log(result); // 8                                       │
└─────────────────────────────────────────────────────────────────┘
```

## 🏗️ File Structure Tree

```
rn-app/
│
├── 📄 App.tsx                          # React Native UI
├── 📄 package.json                     # Dependencies
│
├── 📁 ios/                             # iOS Native Code
│   ├── 📄 Podfile                      # CocoaPods dependencies
│   └── 📁 rnapp/
│       ├── 🔷 WasmModule.swift         # Bridge (Swift)
│       ├── 🔶 WasmModule.m             # Export (Objective-C)
│       ├── 🔷 WasmManager.swift        # Runtime (Swift)
│       ├── 🔷 AppDelegate.swift        # App entry point
│       └── 📄 rnapp-Bridging-Header.h  # Swift-ObjC bridge
│
├── 📁 android/                         # Android Native Code
│   └── 📁 app/src/main/java/com/anonymous/rnapp/
│       ├── 📁 wasmbridge/
│       │   ├── 🟩 WasmModule.kt        # Bridge (Kotlin)
│       │   └── 🟩 WasmPackage.kt       # Package registration
│       └── 📁 wasmmanager/
│           └── 🟩 WasmManager.kt       # Runtime (Kotlin)
│
├── 🔧 Scripts & Tools
│   ├── 📜 test-ios.sh                  # iOS interactive test
│   ├── 📜 test-android.sh              # Android interactive test
│   ├── 📜 verify-ios-module.sh         # iOS verification
│   └── 📜 verify-native-module.sh      # Android verification
│
└── 📚 Documentation
    ├── 📖 README-WASM-MODULE.md        # Main README
    ├── 📖 IOS-WASM-SETUP.md            # iOS setup guide
    ├── 📖 WSL-ANDROID-SETUP.md         # Android setup guide
    ├── 📖 PLATFORM-COMPARISON.md       # iOS vs Android
    ├── 📖 IOS-IMPLEMENTATION-SUMMARY.md # iOS summary
    ├── 📖 QUICK-START.md               # Quick start
    └── 📖 ARCHITECTURE-DIAGRAM.md      # This file
```

## 🔀 Module Registration Flow

### iOS Registration

```
Xcode Build System
      ↓
Compiles WasmModule.swift
      ↓
WasmModule.m macros processed
      ↓
React Native automatically discovers
RCT_EXTERN_MODULE(WasmModule, ...)
      ↓
Module registered in NativeModules
      ↓
Available as NativeModules.WasmModule
```

### Android Registration

```
Gradle Build System
      ↓
Compiles WasmModule.kt & WasmPackage.kt
      ↓
MainApplication.kt imports WasmPackage
      ↓
packages.add(WasmPackage())
      ↓
ReactPackage.createNativeModules() called
      ↓
Module registered in NativeModules
      ↓
Available as NativeModules.WasmModule
```

## 🧵 Threading Model

### iOS Threading

```
JavaScript Thread (React Native)
        ↓
    [Bridge Call]
        ↓
requiresMainQueueSetup() = false
        ↓
Background Thread (Native Module Queue)
        ↓
WasmModule.add() executes
        ↓
WasmManager.callAdd() executes
        ↓
    [Result]
        ↓
Back to JavaScript Thread
```

### Android Threading

```
JavaScript Thread (React Native)
        ↓
    [Bridge Call]
        ↓
React Native Module Thread
        ↓
WasmModule.add() executes
        ↓
WasmManager.callAdd() executes
        ↓
(Can dispatch to background if needed)
        ↓
    [Result]
        ↓
Back to JavaScript Thread
```

## 📊 Error Flow

### Success Path
```
JavaScript
    ↓
Native Module
    ↓
Manager (success)
    ↓
promise.resolve(result)  /  resolver(result)
    ↓
JavaScript receives result
```

### Error Path
```
JavaScript
    ↓
Native Module
    ↓
Manager (throws error)
    ↓
try-catch block
    ↓
promise.reject(error)  /  rejecter(error)
    ↓
JavaScript catch block
```

## 🔍 Logging Architecture

### iOS Logging
```
WasmManager
    ↓
os_log("message", log: logger, type: .info)
    ↓
Unified Logging System
    ↓
Console.app / Xcode Console
    ↓
Filter: xcrun simctl spawn booted log stream
```

### Android Logging
```
WasmManager
    ↓
Log.d(TAG, "message")
    ↓
Android Logcat System
    ↓
Logcat Buffer
    ↓
Filter: adb logcat | grep TAG
```

## 🎯 Complete Development Workflow

```
1. Write JavaScript Code (App.tsx)
        ↓
2. Call NativeModules.WasmModule.add()
        ↓
3. Run Verification Script
   • iOS: ./verify-ios-module.sh
   • Android: ./verify-native-module.sh
        ↓
4. Start Development Server
   • npx expo start
        ↓
5. Run Platform-Specific Build
   • iOS: ./test-ios.sh or npx expo run:ios
   • Android: ./test-android.sh or npx expo run:android
        ↓
6. View Logs
   • iOS: test-ios.sh → Option 7
   • Android: test-android.sh → Option 7
        ↓
7. Debug Issues
   • Check native code
   • Review bridge configuration
   • Verify module registration
        ↓
8. Iterate and Test
   • Make changes
   • Rebuild
   • Test
        ↓
9. Deploy
   • iOS: Archive in Xcode
   • Android: Generate APK/Bundle
```

## 🚀 Future WASM Integration

```
Current State:
JavaScript → Bridge → Manager → Stub (a + b)

Future State:
JavaScript → Bridge → Manager → WASM Runtime → .wasm file
                                       ↓
                              ┌────────┴─────────┐
                              ↓                  ↓
                         Wasmer/WAMR       main.wasm
                              ↓                  ↓
                         Execute              Exports:
                              ↓                - add()
                         Return Result        - multiply()
                                              - etc.
```

## 📦 Build System Integration

### iOS (Xcode + CocoaPods)
```
Podfile
    ↓
pod install
    ↓
rnapp.xcworkspace
    ↓
Build Phases:
  • Compile Sources (Swift/ObjC)
  • Copy Bundle Resources
  • Link Frameworks
    ↓
rnapp.app
```

### Android (Gradle)
```
build.gradle
    ↓
Gradle Sync
    ↓
Android Build System
    ↓
Build Steps:
  • Compile Kotlin
  • Process Resources
  • Package APK
    ↓
app-debug.apk
```

## ✅ Verification Points

```
Pre-Build Verification:
    ├── Files exist
    ├── Correct syntax
    ├── Proper registration
    └── Dependencies installed

Build-Time Verification:
    ├── Compilation succeeds
    ├── No linking errors
    └── Module exports correct

Runtime Verification:
    ├── Module loads
    ├── Methods callable from JS
    ├── Results correct
    └── No crashes

Post-Integration Verification:
    ├── Logs appear
    ├── Errors handled
    └── Performance acceptable
```

---

This architecture provides:
- ✅ Clear separation of concerns
- ✅ Platform-specific optimizations
- ✅ Identical JavaScript API
- ✅ Easy debugging and logging
- ✅ Ready for WASM runtime integration
- ✅ Scalable for additional methods
