# ADB Connection Guide for WSL

## Current Status
You have:
- ✅ ADB installed in WSL (`/home/cgc/Android/Sdk/platform-tools/adb`)
- ⚠️ An emulator running but showing as "unauthorized" (`emulator-5554`)

## Method 1: Fix "Unauthorized" Device (YOUR CURRENT ISSUE)

When you see `unauthorized`, the device needs to authorize the connection.

### On Emulator:
```bash
# 1. Kill and restart ADB server
adb kill-server
adb start-server

# 2. Wait a few seconds
sleep 3

# 3. Check devices again
adb devices
```

A popup should appear on the emulator asking "Allow USB debugging?" - **Click "Allow"** (and optionally check "Always allow from this computer")

### If popup doesn't appear:
```bash
# Restart the emulator
adb -s emulator-5554 emu kill

# Wait a moment, then start fresh
emulator -avd Medium_Phone_API_36.1 &
sleep 30
adb devices
```

---

## Method 2: Connect Physical Android Phone via USB

### Step 1: Enable Developer Options on Phone
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times
3. Go back to **Settings** → **Developer Options**
4. Enable **USB Debugging**

### Step 2: Connect USB Cable

### Step 3: Choose Connection Method

#### Option A: Using WSL ADB Directly (Simplest - if it works)

```bash
# Just plug in and check
adb devices
```

If you see your device, you're done! Skip to "Authorize Device" below.

#### Option B: Bridge Windows ADB to WSL (Recommended for WSL)

Since you're in WSL, USB devices are managed by Windows. You need to bridge:

**On Windows PowerShell (Run as Administrator):**
```powershell
# 1. Navigate to your Windows platform-tools (install if needed)
cd C:\Users\<YourUsername>\AppData\Local\Android\Sdk\platform-tools

# 2. Check device is visible on Windows
.\adb.exe devices

# 3. Start ADB server that listens on all interfaces
.\adb.exe kill-server
.\adb.exe -a -P 5037 nodaemon server start
```

**On WSL (in another terminal):**
```bash
# Get Windows host IP
WINDOWS_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
echo "Windows IP: $WINDOWS_IP"

# Connect to Windows ADB server
export ADB_SERVER_SOCKET=tcp:$WINDOWS_IP:5037

# Verify connection
adb devices
```

#### Option C: USB/IP - Expose USB to WSL (Advanced)

This makes USB devices directly accessible in WSL2.

**On Windows (PowerShell as Admin):**
```powershell
# Install USB/IP
winget install --interactive --exact dorssel.usbipd-win

# List USB devices
usbipd list

# Find your Android device (look for something like "Android Device" or your phone model)
# Note the BUSID (e.g., 2-4)

# Attach device to WSL
usbipd bind --busid 2-4
usbipd attach --wsl --busid 2-4
```

**On WSL:**
```bash
# Install USB/IP client
sudo apt update
sudo apt install linux-tools-generic hwdata -y
sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/*-generic/usbip 20

# Verify device
lsusb

# Now ADB should see it
adb devices
```

### Step 4: Authorize Device

On your phone, you should see a popup:
- **"Allow USB debugging?"**
- Check **"Always allow from this computer"**
- Tap **"Allow"**

Then verify:
```bash
adb devices
# Should now show:
# List of devices attached
# ABC123456789    device
```

---

## Method 3: Connect via WiFi (Wireless ADB)

This is great for testing without cables!

### Prerequisites:
- Phone and computer on same WiFi network
- USB connection initially (for setup)

### Step 1: Initial Setup via USB

```bash
# Connect phone via USB first
adb devices

# Enable TCP/IP mode on port 5555
adb tcpip 5555

# Disconnect USB cable now
```

### Step 2: Find Phone's IP Address

On your phone:
- Go to **Settings** → **About Phone** → **Status** → **IP Address**
- Or: **Settings** → **WiFi** → Tap connected network → IP Address

Example: `192.168.1.100`

### Step 3: Connect Wirelessly

```bash
# Connect to phone's IP
adb connect 192.168.1.100:5555

# Verify
adb devices
# Should show:
# 192.168.1.100:5555    device
```

### Step 4: Use Normally

```bash
# Run your app
npm run android

# View logs
adb logcat

# Install APK
adb install -r app.apk
```

### To Disconnect:
```bash
adb disconnect 192.168.1.100:5555

# Or disconnect all
adb disconnect
```

### To Go Back to USB:
```bash
adb usb
```

---

## Method 4: Use Android Emulator (What You Have)

You already have `Medium_Phone_API_36.1` emulator!

### Fix Your Current "Unauthorized" Issue:

```bash
# 1. Kill current emulator
adb -s emulator-5554 emu kill

# 2. Wait a moment
sleep 5

# 3. Start fresh
emulator -avd Medium_Phone_API_36.1 -no-snapshot-load &

# 4. Wait for boot (30-60 seconds)
sleep 30

# 5. Check status
adb devices
```

When the emulator starts, you should see a dialog asking to authorize. Click "Allow".

### If Still Unauthorized:

```bash
# Remove old keys
rm ~/.android/adbkey*

# Restart ADB
adb kill-server
adb start-server

# Restart emulator
emulator -avd Medium_Phone_API_36.1 &
```

---

## Quick Commands Reference

```bash
# List all devices
adb devices -l

# Kill ADB server
adb kill-server

# Start ADB server
adb start-server

# Check which device is which
adb devices -l

# Target specific device (if multiple)
adb -s emulator-5554 shell
adb -s 192.168.1.100:5555 shell

# Check emulator status
adb -s emulator-5554 emu avd name

# Kill emulator
adb -s emulator-5554 emu kill

# Forward/reverse ports
adb reverse tcp:8081 tcp:8081  # For React Native Metro

# Install APK
adb install -r app-debug.apk

# Uninstall app
adb uninstall com.anonymous.rnapp

# View logs
adb logcat

# Clear logs
adb logcat -c

# Get phone info
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
```

---

## Troubleshooting

### "adb: device unauthorized"
- Check phone screen for authorization dialog
- Click "Always allow from this computer"
- Try: `adb kill-server && adb start-server`

### "no devices/emulators found"
- Restart ADB: `adb kill-server && adb start-server`
- Check USB cable (try different cable/port)
- Verify USB debugging is enabled on phone
- Try: `adb reconnect`

### "device offline"
```bash
adb kill-server
adb start-server
# Unplug and replug USB cable
```

### "more than one device/emulator"
```bash
# List all
adb devices

# Target specific device
adb -s emulator-5554 shell
adb -s <device-serial> shell
```

### WSL Can't See USB Device
- Use USB/IP method (see Option C above)
- Or use Windows ADB and bridge to WSL (see Option B above)

---

## Recommended Setup for WSL

For the best experience in WSL, I recommend:

1. **For Emulator:** Use WSL ADB directly (what you have now)
2. **For Physical Device:** Use WiFi ADB (Method 3) - no USB hassle!

---

## Quick Test Right Now

Let's fix your unauthorized emulator:

```bash
# Kill and restart everything
adb kill-server
adb -s emulator-5554 emu kill
sleep 5

# Start fresh
adb start-server
emulator -avd Medium_Phone_API_36.1 &

# Wait for boot
echo "Waiting for emulator to boot (30 seconds)..."
sleep 30

# Check status
adb devices

# Should show as "device" not "unauthorized"
# If still unauthorized, click "Allow" on the emulator screen
```

Then run your app:
```bash
npm run android
```

---

Need help with any specific method? Just ask!
