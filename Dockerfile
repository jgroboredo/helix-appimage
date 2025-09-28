FROM rockylinux:8.9

ARG UUID="1000"
ARG UGID="1000"

RUN dnf upgrade -y
RUN dnf groupinstall -y 'Development Tools'
RUN dnf install -y curl git wget fuse desktop-file-utils

RUN groupadd -g ${UGID} builder && \
    useradd -u ${UUID} -g ${UGID} -ms /bin/bash builder
USER builder

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/home/builder/.cargo/bin:${PATH}"
