#!/bin/bash

# ADB Quick Connect Helper
# Handles common connection scenarios

echo "🔌 ADB Connection Helper"
echo "========================"
echo ""

# Make sure ADB server is running
adb start-server > /dev/null 2>&1

# Check current devices
DEVICE_COUNT=$(adb devices | grep -v "List of" | grep -v "^$" | wc -l)

echo "📱 Current devices connected: $DEVICE_COUNT"
adb devices
echo ""

if [ $DEVICE_COUNT -eq 0 ]; then
    echo "No devices connected."
    echo ""
    echo "What would you like to do?"
    echo ""
    echo "1) Start emulator (Medium_Phone_API_36.1)"
    echo "2) Connect physical device via WiFi"
    echo "3) Check for USB device (physical phone)"
    echo "4) Troubleshoot unauthorized device"
    echo "5) Exit"
    echo ""
    read -p "Choose option (1-5): " choice
    
    case $choice in
        1)
            echo ""
            echo "🚀 Starting emulator..."
            emulator -avd Medium_Phone_API_36.1 -no-snapshot-load > /dev/null 2>&1 &
            EMULATOR_PID=$!
            
            echo "⏳ Waiting for emulator to boot (this takes 30-60 seconds)..."
            echo "   Process ID: $EMULATOR_PID"
            
            # Wait for device
            timeout=60
            elapsed=0
            while [ $elapsed -lt $timeout ]; do
                sleep 5
                elapsed=$((elapsed + 5))
                
                if adb devices | grep -q "emulator.*device$"; then
                    echo ""
                    echo "✅ Emulator is ready!"
                    adb devices
                    echo ""
                    echo "If you see 'unauthorized', look for a dialog on the emulator"
                    echo "asking to allow USB debugging, and click 'Allow'."
                    exit 0
                fi
                
                echo "   Still booting... ($elapsed seconds)"
            done
            
            echo ""
            echo "⚠️  Emulator is taking longer than expected."
            echo "   Check the emulator window or run: adb devices"
            ;;
            
        2)
            echo ""
            echo "📱 WiFi ADB Connection"
            echo "======================"
            echo ""
            echo "First, you need to enable WiFi debugging:"
            echo ""
            echo "Option A - Via USB (recommended):"
            echo "  1. Connect your phone via USB"
            echo "  2. Make sure USB debugging is enabled"
            echo "  3. Run: adb tcpip 5555"
            echo "  4. Find your phone's IP: Settings → About → Status → IP"
            echo "  5. Disconnect USB cable"
            echo "  6. Run: adb connect <phone-ip>:5555"
            echo ""
            echo "Option B - Android 11+ (Wireless Debugging):"
            echo "  1. Settings → Developer Options → Wireless Debugging"
            echo "  2. Enable it and note the IP and port"
            echo "  3. Run: adb connect <ip>:<port>"
            echo ""
            read -p "Enter phone IP address (or press Enter to cancel): " phone_ip
            
            if [ ! -z "$phone_ip" ]; then
                echo ""
                echo "Connecting to $phone_ip:5555..."
                adb connect $phone_ip:5555
                sleep 2
                adb devices
            fi
            ;;
            
        3)
            echo ""
            echo "🔍 Checking for USB devices..."
            echo ""
            echo "Make sure:"
            echo "  ✓ USB debugging is enabled on phone"
            echo "  ✓ Phone is connected via USB"
            echo "  ✓ You unlocked the phone screen"
            echo ""
            
            adb kill-server
            sleep 2
            adb start-server
            sleep 2
            
            echo "Devices found:"
            adb devices -l
            echo ""
            
            if adb devices | grep -q "unauthorized"; then
                echo "⚠️  Device is unauthorized!"
                echo "   → Check your phone for an authorization dialog"
                echo "   → Click 'Allow' and check 'Always allow'"
            elif adb devices | grep -q "device$"; then
                echo "✅ Device connected and authorized!"
            else
                echo "❌ No USB device found."
                echo ""
                echo "Troubleshooting:"
                echo "  - Try a different USB cable"
                echo "  - Try a different USB port"
                echo "  - On phone: Settings → Developer Options → Revoke USB debugging authorizations"
                echo "  - Then disconnect/reconnect and allow again"
            fi
            ;;
            
        4)
            echo ""
            echo "🔧 Troubleshooting Unauthorized Device"
            echo "======================================"
            echo ""
            
            if adb devices | grep -q "unauthorized"; then
                echo "Found unauthorized device. Trying to fix..."
                echo ""
                
                # Method 1: Clear keys and restart
                echo "1. Clearing ADB keys..."
                rm -f ~/.android/adbkey ~/.android/adbkey.pub 2>/dev/null
                
                echo "2. Restarting ADB server..."
                adb kill-server
                sleep 2
                adb start-server
                sleep 2
                
                echo "3. Checking devices..."
                adb devices
                echo ""
                
                if adb devices | grep -q "unauthorized"; then
                    echo "Still unauthorized. Please:"
                    echo "  1. Check your device screen for authorization dialog"
                    echo "  2. Click 'Allow' and enable 'Always allow from this computer'"
                    echo "  3. If no dialog appears:"
                    echo "     - Disconnect and reconnect USB"
                    echo "     - Or on device: Settings → Developer Options → Revoke USB debugging authorizations"
                    echo "     - Then try again"
                else
                    echo "✅ Fixed! Device should be authorized now."
                fi
            else
                echo "No unauthorized devices found."
                echo ""
                echo "Current status:"
                adb devices
            fi
            ;;
            
        5)
            echo "Goodbye!"
            exit 0
            ;;
            
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
else
    # Devices are connected
    echo "✅ You have device(s) connected!"
    echo ""
    
    # Check for unauthorized devices
    if adb devices | grep -q "unauthorized"; then
        echo "⚠️  Warning: Some devices are unauthorized"
        echo ""
        read -p "Fix unauthorized devices? (y/n): " fix_choice
        
        if [ "$fix_choice" = "y" ]; then
            echo ""
            echo "Clearing keys and restarting ADB..."
            rm -f ~/.android/adbkey ~/.android/adbkey.pub 2>/dev/null
            adb kill-server
            sleep 2
            adb start-server
            sleep 2
            
            echo ""
            echo "Updated device list:"
            adb devices
            echo ""
            echo "Check your device(s) for authorization dialogs and click 'Allow'."
        fi
    else
        echo "All devices are authorized and ready!"
        echo ""
        read -p "Run React Native app now? (y/n): " run_choice
        
        if [ "$run_choice" = "y" ]; then
            echo ""
            echo "🚀 Running: npm run android"
            npm run android
        fi
    fi
fi

echo ""
echo "Done! 🎉"
