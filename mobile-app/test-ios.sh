#!/bin/bash

# iOS Testing Script for WASM Module
# Similar to test-android.sh but for iOS

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🍎 iOS WASM Module Testing Script"
echo "=================================="
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script must be run on macOS"
    exit 1
fi

# Function to check if iOS Simulator is available
check_simulator() {
    if ! command -v xcrun &> /dev/null; then
        echo "❌ Xcode command line tools not found"
        exit 1
    fi
    
    echo "✅ Xcode command line tools found"
}

# Function to list available simulators
list_simulators() {
    echo "📱 Available iOS Simulators:"
    xcrun simctl list devices available | grep -E "iPhone|iPad"
}

# Function to start Metro bundler
start_metro() {
    echo "🚀 Starting Metro bundler..."
    npx expo start --clear &
    METRO_PID=$!
    echo "Metro PID: $METRO_PID"
    sleep 5
}

# Function to build iOS app
build_ios() {
    echo "🔨 Building iOS app..."
    npx expo run:ios --device
}

# Function to run on iOS simulator
run_ios() {
    echo "📱 Running on iOS Simulator..."
    npx expo run:ios
}

# Function to show iOS logs
show_logs() {
    echo "📋 Showing iOS logs..."
    echo "Filtering for: WasmModule, WasmManager, and ReactNativeJS"
    xcrun simctl spawn booted log stream --predicate 'processImagePath contains "rnapp"' | grep -E "(WasmModule|WasmManager|React)"
}

# Function to clean iOS build
clean_ios() {
    echo "🧹 Cleaning iOS build..."
    cd ios
    xcodebuild clean -workspace rnapp.xcworkspace -scheme rnapp 2>/dev/null || xcodebuild clean -project rnapp.xcodeproj -scheme rnapp
    cd ..
    rm -rf ios/build
    echo "✅ iOS build cleaned"
}

# Function to install pods
install_pods() {
    echo "📦 Installing CocoaPods dependencies..."
    cd ios
    pod install
    cd ..
    echo "✅ Pods installed"
}

# Main menu
show_menu() {
    echo ""
    echo "Choose an option:"
    echo "1) Check iOS setup"
    echo "2) List available simulators"
    echo "3) Install CocoaPods dependencies"
    echo "4) Build iOS app"
    echo "5) Run on iOS Simulator"
    echo "6) Start Metro bundler only"
    echo "7) View logs (WasmModule)"
    echo "8) Clean iOS build"
    echo "9) Full test (clean + install + build + run)"
    echo "0) Exit"
    echo ""
    read -p "Enter your choice: " choice
    
    case $choice in
        1)
            check_simulator
            ;;
        2)
            list_simulators
            ;;
        3)
            install_pods
            ;;
        4)
            build_ios
            ;;
        5)
            run_ios
            ;;
        6)
            start_metro
            echo "Metro is running. Press Ctrl+C to stop."
            wait $METRO_PID
            ;;
        7)
            show_logs
            ;;
        8)
            clean_ios
            ;;
        9)
            echo "🚀 Running full test sequence..."
            check_simulator
            clean_ios
            install_pods
            build_ios
            run_ios
            ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

# Run menu in loop
while true; do
    show_menu
done
