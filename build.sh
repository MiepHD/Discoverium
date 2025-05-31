#!/bin/bash
# Convenience script

CURR_DIR="$(pwd)"
trap "cd "$CURR_DIR"" EXIT

if [ -z "$1" ]; then
    git fetch && git merge origin/main && git push # Typically run after a PR to main, so bring dev up to date
fi
cd .flutter
git fetch
git checkout "$(flutter --version | head -2 | tail -1 | awk '{print $4}')" # Ensure included Flutter submodule version equals my environment
cd ..
rm ./build/app/outputs/flutter-apk/* 2>/dev/null                                       # Get rid of older builds if any
flutter build apk --flavor normal
