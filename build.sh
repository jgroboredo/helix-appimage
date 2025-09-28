#!/bin/bash

docker run --rm -v .:/build --device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined -it helix-appimage:latest /build/hx-ai-build.sh
