#!/bin/bash

# docker build -t .
docker run --rm -v .:/build --device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined -it legacy-builder /build/hx-ai-build.sh
