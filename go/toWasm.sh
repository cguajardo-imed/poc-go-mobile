#!/bin/sh

# TinyGo install
# wget https://github.com/tinygo-org/tinygo/releases/download/v0.39.0/tinygo_0.39.0_amd64.deb
# sudo dpkg -i tinygo_0.39.0_amd64.deb

# Build go app to wasm
tinygo build -o main.wasm -target wasm ./main.go

# Copy to ../rn-app/android/app/src/main/assets/
cp main.wasm ../rn-app/android/app/src/main/assets/
