#!/bin/bash

# This script adds missing Android environment variables to ~/.zshrc

ZSHRC="$HOME/.zshrc"

echo "🔧 Fixing Android environment variables in ~/.zshrc"
echo ""

# Check if ANDROID_HOME is already set
if grep -q "export ANDROID_HOME=" "$ZSHRC"; then
    echo "✓ ANDROID_HOME already configured in ~/.zshrc"
else
    echo "📝 Adding ANDROID_HOME to ~/.zshrc"
    echo "" >> "$ZSHRC"
    echo "# Android Home (required by React Native)" >> "$ZSHRC"
    echo "export ANDROID_HOME=\$HOME/Android/Sdk" >> "$ZSHRC"
    echo "✓ Added ANDROID_HOME"
fi

# Check if emulator path is set
if grep -q "ANDROID_HOME/emulator" "$ZSHRC" || grep -q "ANDROID_SDK_ROOT/emulator" "$ZSHRC"; then
    echo "✓ Emulator path already configured"
else
    echo "📝 Adding emulator to PATH"
    echo "export PATH=\$PATH:\$ANDROID_HOME/emulator" >> "$ZSHRC"
    echo "✓ Added emulator path"
fi

echo ""
echo "✅ Configuration complete!"
echo ""
echo "To apply changes, run:"
echo "  source ~/.zshrc"
echo ""
echo "Or restart your terminal."
