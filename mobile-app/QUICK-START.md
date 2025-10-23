# Quick Start Guide - Testing Your Native Module (WSL)

## ✅ What Was Fixed

Your native module was returning `null` because of **package name mismatches**. All issues have been fixed:

1. ✅ Fixed package declarations in `WasmModule.kt`, `WasmPackage.kt`, and `WasmManager.kt`
2. ✅ Added missing imports in `MainApplication.kt`
3. ✅ Created stub implementation (returns `a + b` for testing)
4. ✅ Fixed React Native import in `App.tsx`
5. ✅ Configured Android environment variables

## 🚀 How to Test NOW

You have **3 easy options**:

### Option 1: Interactive Helper Script (EASIEST)
```bash
./test-android.sh
```
This will give you a menu with options to:
- Start emulator and run app
- Run on connected device
- Build APK only
- View logs

### Option 2: Direct Commands

**If you want to use the emulator you have:**
```bash
# Start your emulator (you have: Medium_Phone_API_36.1)
emulator -avd Medium_Phone_API_36.1 &

# Wait 30 seconds for it to boot, then:
npm run android
```

**If you have a physical phone with USB debugging:**
```bash
# Connect phone via USB, enable USB debugging, then:
adb devices  # Should show your device

npm run android
```

### Option 3: Build APK and Install Manually
```bash
cd android
./gradlew assembleDebug

# APK will be at: android/app/build/outputs/apk/debug/app-debug.apk
# Copy to phone and install
```

## 📱 What You'll See

When the app runs successfully:

1. The app should open on your device/emulator
2. You'll see a number on screen (the result of the add function)
3. A button labeled "Sumar Random" (Add Random)

In the logs (`adb logcat`), you should see:
```
D/WasmManager: WasmManager initialized (stub mode)
D/WasmManager: callAdd(1, 999) = 1000 (stub mode)
```

## 🔍 Verify It Works

```bash
# In one terminal, watch logs:
adb logcat | grep -i wasm

# In another terminal, run the app:
npm run android
```

Look for successful initialization messages!

## ⚠️ Common Issues

### "No devices found"
```bash
adb kill-server
adb start-server
emulator -avd Medium_Phone_API_36.1 &
adb wait-for-device
```

### "Module already exists"
```bash
adb uninstall com.anonymous.rnapp
npm run android
```

### Metro bundler not starting
```bash
# Kill any existing Metro instance
pkill -f metro
# Start fresh
npm start
```

## 📋 Helpful Commands

```bash
# List emulators
emulator -list-avds

# Check connected devices
adb devices -l

# View all logs
adb logcat

# Clear logs
adb logcat -c

# Install APK manually
adb install -r android/app/build/outputs/apk/debug/app-debug.apk

# Uninstall app
adb uninstall com.anonymous.rnapp

# Clean build
cd android && ./gradlew clean
```

## 🎯 Next Steps After Successful Test

Once the stub works, you can add **real WASM support**:

1. **Choose a WASM runtime library:**
   - WasmEdge (most features)
   - WASM3 (lightweight, easier)
   - Wasmer

2. **Add the library to `android/app/build.gradle`:**
   ```gradle
   dependencies {
       // Add your WASM runtime
       implementation 'io.github.wasm3:wasm3-android:x.x.x'
   }
   ```

3. **Update `WasmManager.kt`** to use the real runtime

4. **Place your WASM file:**
   ```bash
   cp your-module.wasm android/app/src/main/assets/main.wasm
   ```

## 🆘 Need Help?

Check the detailed guide:
```bash
cat WSL-ANDROID-SETUP.md
```

Or verify your setup:
```bash
./verify-native-module.sh
```

---

## TL;DR - Run This Now:

```bash
# Start emulator in background
emulator -avd Medium_Phone_API_36.1 &

# Wait 30 seconds, then run:
npm run android
```

That's it! Your native module should now work! 🎉
