FROM rockylinux:9.3

ARG UUID="1000"
ARG UGID="1000"
ARG RUST_VERSION="1.91.1"

RUN dnf upgrade -y
RUN dnf groupinstall -y 'Development Tools'
RUN dnf install --allowerasing -y curl git wget fuse desktop-file-utils

RUN groupadd -g ${UGID} builder && \
    useradd -u ${UUID} -g ${UGID} -ms /bin/bash builder
USER builder

RUN curl -sSf https://sh.rustup.rs | \
    sh -s -- -y --default-toolchain $RUST_VERSION

ENV PATH="/home/builder/.cargo/bin:${PATH}"
