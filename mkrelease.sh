#!/bin/bash
#

if [ -z "$1" ]; then
  echo "Usage: $0 version"
  exit
fi

xcodebuild
rm -rf build/Release/*.dSYM
cp LICENSE* build/Release/
cp README.md build/Release/
cp xibcolor build/Release/
cp namethatcolor* build/Release/
cd build/Release
zip -9r "../../ColorTools-$1.zip" *


