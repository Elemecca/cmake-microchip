
FROM ubuntu:20.04

ENV xc_installer_url=https://ww1.microchip.com/downloads/en/DeviceDoc/xc8-v2.31-full-install-linux-x64-installer.run
ENV xc_installer_sha256=9c400e45fb75be097cee80d5bc993a765c3efc1e5b4f425e0732615110a2ce87

ENV mplabx_installer_url=https://ww1.microchip.com/downloads/en/DeviceDoc/mplabx-v5.45-linux-installer.tar
ENV mplabx_installer_sha256=146b3eaac5bcad82a26805de5f4fc946b28135e2e3f48dd546f13b42e076fb8f
ENV mplabx_8bitmcu=1
ENV mplabx_16bitmcu=0
ENV mplabx_32bitmcu=0

# install dependencies from APT
RUN set -eux pipefail; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        cmake \
        curl \
        make

# install XC compiler
RUN set -eux pipefail; \
    curl -fL "${xc_installer_url}" -o installer.run; \
    echo "${xc_installer_sha256} *installer.run" | sha256sum --strict --check; \
    chmod +x installer.run; \
    ./installer.run \
        --mode unattended --unattendedmodeui none \
        --LicenseType FreeMode --netservername none \
        ; \
    rm -f installer.run

# install the MPLAB X tools
RUN set -eux pipefail; \
    curl -fL "${mplabx_installer_url}" -o installer.tar; \
    echo "${mplabx_installer_sha256} *installer.tar" | sha256sum --strict --check; \
    mkdir installer; \
    tar -xf installer.tar -C installer; \
    USER=root installer/*-installer.sh --nox11 --target installer/extracted -- \
        --mode unattended --unattendedmodeui none \
        --ide 0 \
        --ipe 0 \
        --8bitmcu "${mplabx_8bitmcu}" \
        --16bitmcu "${mplabx_16bitmcu}" \
        --32bitmcu "${mplabx_32bitmcu}" \
        --othermcu 0 \
        --collectInfo 0 \
        ; \
    rm -rf installer.tar installer
