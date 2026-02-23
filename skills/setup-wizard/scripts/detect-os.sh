#!/bin/bash
# detect-os.sh — Detect the current operating system
# Outputs one of: macos, windows, unsupported

case "$(uname -s)" in
    Darwin)
        echo "macos"
        ;;
    MINGW64*|MINGW32*|MSYS*|CYGWIN*)
        echo "windows"
        ;;
    *)
        echo "unsupported"
        ;;
esac
