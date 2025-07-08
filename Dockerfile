ARG s6_ver=3.2.1.0

FROM archlinux:base-devel AS build
RUN pacman -Syu --noconfirm git && \ 
    useradd builder
USER builder
WORKDIR /build
RUN git clone https://aur.archlinux.org/paru-bin.git && \
    cd paru-bin && \
    makepkg

FROM archlinux:base AS runtime
ARG s6_ver
ENV S6_VERBOSITY=1
ENV PUID=9393
COPY --from=build /build/paru-bin/paru-bin-*.pkg.* .
RUN pacman -Syu --noconfirm git sudo && \
    # https://github.com/docker/for-mac/issues/7331
    # pacman -U --noconfirm https://archive.archlinux.org/packages/f/fakeroot/fakeroot-1.34-1-x86_64.pkg.tar.zst && \
    pacman -U --noconfirm ./paru-bin-*.pkg.* && \
    rm -rf ./paru-bin-*.pkg.* /var/lib/pacman/sync && \
    useradd -r -G wheel admin && \
    echo "%wheel ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    groupadd -g "$PUID" user && \
    useradd -u "$PUID" -g user -s /bin/bash -m user && \
    mkdir /app && \
    chown user:user /app
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_ver}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_ver}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz
COPY fs/ /
WORKDIR /app
ENTRYPOINT ["/init", "entrypoint.sh"]
CMD ["bash"]
