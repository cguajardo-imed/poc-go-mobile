# iOS WASM Module Setup Guide

This guide walks you through setting up the WASM native module for iOS.

## Prerequisites

- macOS (required for iOS development)
- Xcode installed (with command line tools)
- CocoaPods installed (`sudo gem install cocoapods`)
- Node.js and npm installed

## Project Structure

The iOS WASM module consists of the following components:

```
ios/rnapp/
├── WasmModule.swift      # React Native bridge module (Swift)
├── WasmModule.m          # Objective-C bridge (exports module to RN)
├── WasmManager.swift     # WASM runtime manager
└── AppDelegate.swift     # Main app delegate
```

## Architecture Overview

```
React Native App (JavaScript)
         ↓
    WasmModule.m (Objective-C Bridge)
         ↓
    WasmModule.swift (Swift Bridge)
         ↓
    WasmManager.swift (WASM Runtime)
         ↓
    WASM Binary (future implementation)
```

## Step-by-Step Setup

### 1. Verify Module Files

Run the verification script to ensure all files are properly configured:

```bash
./verify-ios-module.sh
```

This will check:
- ✅ All required Swift/Objective-C files exist
- ✅ Files have correct class definitions
- ✅ Files are registered in Xcode project
- ✅ Proper bridging headers are configured

### 2. Install CocoaPods Dependencies

```bash
cd ios
pod install
cd ..
```

### 3. Test the Module

You can use the interactive testing script:

```bash
./test-ios.sh
```

The script provides options to:
1. Check iOS setup
2. List available simulators
3. Install CocoaPods dependencies
4. Build iOS app
5. Run on iOS Simulator
6. Start Metro bundler
7. View logs (filtered for WasmModule)
8. Clean iOS build
9. Run full test sequence

### 4. Manual Testing

Alternatively, you can test manually:

```bash
# Start Metro bundler
npx expo start

# In another terminal, run iOS
npx expo run:ios
```

## Module Components Explained

### WasmModule.swift

The main React Native bridge module written in Swift:

```swift
@objc(WasmModule)
class WasmModule: NSObject {
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  @objc
  func add(_ a: Int, b: Int, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    do {
      let result = WasmManager.shared.callAdd(a: a, b: b)
      resolver(result)
    } catch {
      rejecter("WASM_ERROR", "Failed to execute WASM add function", error)
    }
  }
}
```

Key features:
- `@objc(WasmModule)` - Makes the class accessible from Objective-C/React Native
- `requiresMainQueueSetup()` - Returns false since WASM operations don't need main thread
- `add()` method - Exposed to JavaScript with promise-based async API

### WasmModule.m

Objective-C bridge that exports the Swift module to React Native:

```objective-c
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(WasmModule, NSObject)

RCT_EXTERN_METHOD(add:(NSInteger)a
                  b:(NSInteger)b
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter)

@end
```

This file:
- Uses React Native's macro system to export Swift to JavaScript
- Declares method signatures that will be available in JS
- Connects Swift implementation to React Native bridge

### WasmManager.swift

Manages the WASM runtime (currently stub implementation):

```swift
class WasmManager {
  static let shared = WasmManager()
  private var isInitialized = false
  
  func callAdd(a: Int, b: Int) -> Int {
    // TODO: Integrate actual WASM runtime
    let result = a + b
    return result
  }
}
```

Features:
- Singleton pattern (`shared` instance)
- Stub implementation for testing
- Ready to integrate actual WASM runtime (WasmEdge, Wasmer, etc.)

## Using the Module in React Native

In your React Native app:

```typescript
import { NativeModules } from 'react-native';
const { WasmModule } = NativeModules;

// Call the add function
const result = await WasmModule.add(5, 3);
console.log(result); // 8
```

## Viewing Logs

### Using the test script:
```bash
./test-ios.sh
# Choose option 7 to view logs
```

### Manual log viewing:
```bash
# View simulator logs
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "rnapp"' | grep -E "(WasmModule|WasmManager)"

# View all app logs
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "rnapp"'
```

## Troubleshooting

### Module not found in JavaScript

**Problem:** `Cannot read property 'add' of undefined` or `WasmModule is undefined`

**Solutions:**
1. Verify Xcode project includes all Swift files:
   ```bash
   ./verify-ios-module.sh
   ```

2. Clean and rebuild:
   ```bash
   ./test-ios.sh
   # Choose option 8 (clean) then 4 (build)
   ```

3. Ensure CocoaPods are up to date:
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```

### Build errors in Xcode

**Problem:** Compilation errors or linking errors

**Solutions:**
1. Ensure Swift version is set correctly (Swift 5.0+)
2. Check bridging header is configured:
   - Open `ios/rnapp.xcworkspace` in Xcode
   - Select rnapp target → Build Settings
   - Search for "Bridging Header"
   - Should be set to: `rnapp/rnapp-Bridging-Header.h`

3. Clean derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

### Simulator not starting

**Problem:** Simulator fails to launch

**Solutions:**
1. List available simulators:
   ```bash
   xcrun simctl list devices available
   ```

2. Boot a simulator manually:
   ```bash
   xcrun simctl boot "iPhone 15 Pro"
   ```

3. Reset simulator:
   ```bash
   xcrun simctl erase all
   ```

## Next Steps

### Integrating Real WASM Runtime

To integrate an actual WASM runtime, you'll need to:

1. **Choose a WASM runtime for iOS:**
   - Wasmer (supports iOS)
   - WAMR (WebAssembly Micro Runtime)
   - Custom C-based runtime wrapped in Swift

2. **Add runtime as dependency:**
   ```ruby
   # In ios/Podfile
   pod 'Wasmer', '~> 1.0'
   ```

3. **Update WasmManager.swift:**
   ```swift
   import Wasmer
   
   class WasmManager {
     private var instance: Instance?
     
     func initialize() {
       // Load WASM bytes from bundle
       guard let wasmPath = Bundle.main.path(forResource: "main", ofType: "wasm"),
             let wasmData = try? Data(contentsOf: URL(fileURLWithPath: wasmPath)) else {
         return
       }
       
       // Create WASM instance
       let module = try! Module(wasmData)
       instance = try! Instance(module: module)
     }
     
     func callAdd(a: Int, b: Int) -> Int {
       let result = try! instance?.exports.add(a, b)
       return result as! Int
     }
   }
   ```

4. **Add WASM file to Xcode project:**
   - Drag `main.wasm` into Xcode
   - Ensure "Copy items if needed" is checked
   - Add to target membership

## Comparison with Android

| Feature | iOS (Swift) | Android (Kotlin) |
|---------|-------------|------------------|
| Bridge Language | Swift + Objective-C | Kotlin |
| Module Declaration | `@objc(WasmModule)` | `@ReactMethod` |
| Export Mechanism | RCT_EXTERN_MODULE | ReactPackage registration |
| Threading | `requiresMainQueueSetup()` | No special config needed |
| Logging | `os_log` | `Log.d()` |
| Bundle Assets | Xcode resources | `assets/` folder |

## Resources

- [React Native iOS Native Modules](https://reactnative.dev/docs/native-modules-ios)
- [Swift and Objective-C Interoperability](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis)
- [Wasmer iOS](https://github.com/wasmerio/wasmer)
- [CocoaPods Guide](https://guides.cocoapods.org/)

## Summary

Your iOS WASM module is now set up with:
- ✅ Swift-based WasmModule for React Native bridge
- ✅ Objective-C bridge file for RN integration
- ✅ WasmManager for WASM runtime management
- ✅ Proper Xcode project configuration
- ✅ Testing and verification scripts

The module will be accessible as `NativeModules.WasmModule` in React Native!
