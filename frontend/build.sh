#!/bin/bash
git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter-sdk
export PATH="$PATH:$(pwd)/flutter-sdk/bin"
flutter doctor
flutter pub get
flutter build web --release
