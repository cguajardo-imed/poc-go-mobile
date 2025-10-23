# Android Development in WSL - Setup Guide

## Your Current Setup ✅
- WSL2 on Windows
- Android Studio installed in: `/opt/android-studio-2025.1.4/android-studio/`
- Android SDK in: `~/Android/Sdk`
- Platform tools available (adb)

## Step 1: Fix Environment Variables

Add this to your `~/.zshrc` (after the existing Android lines):

```bash
# Android Home (required by React Native)
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk

# Path additions
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# Android NDK
export ANDROID_NDK_HOME=$HOME/Android/Ndk/
```

Then reload:
```bash
source ~/.zshrc
```

## Step 2: Testing Options

### Option A: Using Android Emulator (Recommended)

#### 1. Check available emulators:
```bash
emulator -list-avds
```

#### 2. If no emulator exists, create one:
```bash
# List available system images
sdkmanager --list | grep system-images

# Install a system image (example for API 34)
sdkmanager "system-images;android-34;google_apis;x86_64"

# Create AVD
avdmanager create avd -n Pixel_7_API_34 -k "system-images;android-34;google_apis;x86_64" -d pixel_7
```

#### 3. Start the emulator:
```bash
# Start in background
emulator -avd Pixel_7_API_34 -no-snapshot-load &

# Wait a few seconds, then check
adb devices
```

#### 4. Run your app:
```bash
npm run android
```

### Option B: Using Physical Device via USB

#### 1. Enable USB debugging on your Android phone
- Settings → About Phone → Tap "Build Number" 7 times
- Settings → Developer Options → Enable "USB Debugging"

#### 2. Connect via USB and bridge to WSL

On **Windows PowerShell** (as Administrator):
```powershell
# Find the device
adb devices

# Forward the ADB server port to WSL
adb kill-server
adb -a nodaemon server start
```

On **WSL**:
```bash
# Connect to Windows ADB server
export ADB_SERVER_SOCKET=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):5037

# Or simpler - connect directly
adb connect $(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):5555
```

#### 3. Run your app:
```bash
npm run android
```

### Option C: Using Windows ADB with WSL Bridge

#### 1. Install ADB on Windows side
Download platform-tools from: https://developer.android.com/tools/releases/platform-tools

#### 2. Create a helper script in your project:

Save as `wsl-adb.sh`:
```bash
#!/bin/bash
# Bridge to Windows ADB
WINDOWS_ADB="/mnt/c/platform-tools/adb.exe"
"$WINDOWS_ADB" "$@"
```

Make it executable:
```bash
chmod +x wsl-adb.sh
```

### Option D: Build APK Manually

Build the APK in WSL and install it manually:

```bash
# Clean build
cd android
./gradlew clean

# Build debug APK
./gradlew assembleDebug

# APK location:
# android/app/build/outputs/apk/debug/app-debug.apk

# Copy to Windows
cp android/app/build/outputs/apk/debug/app-debug.apk /mnt/c/Users/<YourWindowsUsername>/Desktop/

# Then on your Android device:
# - Transfer the APK via USB, email, or cloud
# - Install it (allow unknown sources if needed)
```

## Step 3: Verify Native Module Works

Once the app runs, check the logs:

```bash
# Clear and monitor logs
adb logcat -c && adb logcat | grep -i "wasm"
```

Look for:
- `WasmManager initialized (stub mode)`
- `callAdd(x, y) = result (stub mode)`

## Common Issues & Solutions

### Issue: `emulator: ERROR: Unknown AVD name`
**Solution:** Create an AVD first (see Option A, step 2)

### Issue: `adb: no devices/emulators found`
**Solution:** 
```bash
adb kill-server
adb start-server
adb devices
```

### Issue: `INSTALL_FAILED_UPDATE_INCOMPATIBLE`
**Solution:** Uninstall the old app first
```bash
adb uninstall com.anonymous.rnapp
npm run android
```

### Issue: Metro bundler can't connect
**Solution:** Make sure Metro is running on 0.0.0.0
```bash
npm start -- --host 0.0.0.0
```

### Issue: Gradle build fails with "SDK location not found"
**Solution:** Make sure `ANDROID_HOME` is set and SDK exists

## Quick Start Command Sequence

```bash
# 1. Set up environment (one time)
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator

# 2. Start emulator (if using emulator)
emulator -list-avds
emulator -avd <avd-name> &

# 3. Wait for device
adb wait-for-device

# 4. Run the app
cd /home/cgc/projects/poc/wasm-poc/rn-app
npm run android
```

## Verifying Your Fixes

Your native module issues have been fixed:
✅ Package names corrected
✅ Imports added
✅ Stub implementation created

The module will now be accessible as `NativeModules.WasmModule` in React Native!

## Next Steps for Real WASM Support

Once the app runs with the stub, you can add real WASM support:

1. Choose a WASM runtime:
   - WasmEdge Android bindings
   - WASM3 (lightweight)
   - Wasmer Android

2. Add the native library to your project

3. Update `WasmManager.kt` to use the actual runtime

4. Place your `main.wasm` file in `android/app/src/main/assets/`
