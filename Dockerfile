FROM rockylinux:8.9

RUN dnf upgrade -y
RUN dnf groupinstall -y 'Development Tools'
RUN dnf install -y curl git wget fuse desktop-file-utils

RUN useradd -ms /bin/bash builder
USER 1000:1000

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/home/builder/.cargo/bin:${PATH}"
