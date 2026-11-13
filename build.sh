#!/bin/bash
# Builds Pousse.app (universal) and Pousse.dmg with the Command Line Tools only. No Xcode needed.
set -euo pipefail
cd "$(dirname "$0")"
APP=build/Pousse.app
mkdir -p build "$APP/Contents/MacOS" "$APP/Contents/Resources"

swiftc -swift-version 5 -O -target arm64-apple-macos13.0 Sources/main.swift -o build/arm64
swiftc -swift-version 5 -O -target x86_64-apple-macos13.0 Sources/main.swift -o build/x86_64
lipo -create build/arm64 build/x86_64 -output "$APP/Contents/MacOS/Pousse"

# The app draws its own icon.
build/arm64 --icon build/icon-1024.png
mkdir -p build/Pousse.iconset
for s in 16 32 128 256 512; do
  sips -z $s $s build/icon-1024.png --out build/Pousse.iconset/icon_${s}x${s}.png >/dev/null
  sips -z $((s*2)) $((s*2)) build/icon-1024.png --out build/Pousse.iconset/icon_${s}x${s}@2x.png >/dev/null
done
iconutil -c icns build/Pousse.iconset -o "$APP/Contents/Resources/Pousse.icns"
cp Sources/Info.plist "$APP/Contents/Info.plist"
codesign --force --deep -s - "$APP"

STAGE=$(mktemp -d)
cp -R "$APP" "$STAGE/Pousse.app"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname Pousse -srcfolder "$STAGE" -ov -format UDZO Pousse.dmg >/dev/null
echo "Built Pousse.dmg"
