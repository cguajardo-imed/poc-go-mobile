#!/bin/bash

# WSL Android Testing Helper Script
# This script helps you test the React Native app with native modules in WSL

set -e

echo "🚀 React Native Android Testing Helper (WSL)"
echo "============================================="
echo ""

# Set Android environment
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator

# Check if ANDROID_HOME is set
if [ -z "$ANDROID_HOME" ]; then
    echo "❌ ANDROID_HOME not set!"
    echo "   Please add to ~/.zshrc:"
    echo "   export ANDROID_HOME=\$HOME/Android/Sdk"
    exit 1
fi

echo "✓ ANDROID_HOME: $ANDROID_HOME"
echo ""

# Function to check if emulator is running
is_emulator_running() {
    adb devices | grep -q "emulator"
}

# Function to wait for device
wait_for_device() {
    echo "⏳ Waiting for device to be ready..."
    adb wait-for-device
    sleep 5
    echo "✓ Device is ready!"
}

# Main menu
echo "Select testing option:"
echo ""
echo "1) Start emulator and run app"
echo "2) Run app on connected device"
echo "3) Build APK only (for manual installation)"
echo "4) View logs (WasmModule)"
echo "5) Clean build"
echo ""
read -p "Enter option (1-5): " option

case $option in
    1)
        echo ""
        echo "📱 Available emulators:"
        emulator -list-avds
        echo ""
        read -p "Enter emulator name (or press Enter for default): " avd_name
        
        if [ -z "$avd_name" ]; then
            avd_name=$(emulator -list-avds | head -1)
        fi
        
        if [ -z "$avd_name" ]; then
            echo "❌ No emulator found!"
            echo "   Create one using Android Studio or:"
            echo "   avdmanager create avd -n MyEmulator -k 'system-images;android-34;google_apis;x86_64'"
            exit 1
        fi
        
        echo ""
        echo "🚀 Starting emulator: $avd_name"
        echo "   (This may take 1-2 minutes...)"
        emulator -avd "$avd_name" -no-snapshot-load > /dev/null 2>&1 &
        
        wait_for_device
        
        echo ""
        echo "🏗️  Building and running app..."
        npm run android
        ;;
        
    2)
        echo ""
        echo "📱 Checking for connected devices..."
        adb devices -l
        echo ""
        
        if ! adb devices | grep -q "device$"; then
            echo "❌ No device found!"
            echo ""
            echo "Options:"
            echo "  1. Connect physical device via USB"
            echo "  2. Start emulator first (option 1)"
            exit 1
        fi
        
        echo "✓ Device found!"
        echo ""
        echo "🏗️  Building and running app..."
        npm run android
        ;;
        
    3)
        echo ""
        echo "🏗️  Building APK..."
        cd android
        ./gradlew assembleDebug
        
        APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
        if [ -f "$APK_PATH" ]; then
            echo ""
            echo "✅ APK built successfully!"
            echo "   Location: android/$APK_PATH"
            echo ""
            echo "📦 Copying to Desktop..."
            WINDOWS_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
            DESKTOP_PATH="/mnt/c/Users/$WINDOWS_USER/Desktop/app-debug.apk"
            
            if [ -d "/mnt/c/Users/$WINDOWS_USER/Desktop" ]; then
                cp "$APK_PATH" "$DESKTOP_PATH"
                echo "   ✓ Copied to: C:\\Users\\$WINDOWS_USER\\Desktop\\app-debug.apk"
            else
                echo "   ℹ️  Copy manually from: $(pwd)/$APK_PATH"
            fi
            
            echo ""
            echo "📱 To install on device:"
            echo "   adb install -r $APK_PATH"
        else
            echo "❌ Build failed!"
            exit 1
        fi
        ;;
        
    4)
        echo ""
        echo "📋 Showing logs for WasmModule..."
        echo "   (Press Ctrl+C to stop)"
        echo ""
        
        if ! adb devices | grep -q "device$"; then
            echo "❌ No device found!"
            exit 1
        fi
        
        adb logcat -c
        adb logcat | grep --line-buffered -i -E "(WasmModule|WasmManager|WasmPackage|ReactNativeJS)"
        ;;
        
    5)
        echo ""
        echo "🧹 Cleaning build..."
        cd android
        ./gradlew clean
        cd ..
        rm -rf android/app/build
        
        echo "✓ Clean complete!"
        echo ""
        read -p "Rebuild now? (y/n): " rebuild
        
        if [ "$rebuild" = "y" ]; then
            cd android
            ./gradlew assembleDebug
            echo "✓ Rebuild complete!"
        fi
        ;;
        
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "✅ Done!"
