# NVIDIA/CUDA enabled FFmpeg Dockerfile for Anaconda
# Copyright (C) 2020-2022  Chelsea E. Manning
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

FROM xychelsea/anaconda3:v0.5.1-gpu
LABEL description="FFmpeg GPU Container"

# $ docker build --network=host -t xychelsea/ffmpeg-nvidia:latest -f Dockerfile .
# $ docker run --gpus all --rm -it xychelsea/ffmpeg-nvidia:latest /bin/bash
# $ docker push xychelsea/ffmpeg-nvidia:latest

ARG FFMPEG_VERSION="5.0.1"
ENV FFMPEG_VERSION="${FFMPEG_VERSION}"

# Start as root
USER root

# Update packages
RUN apt-get update --fix-missing \
    && apt-get -y upgrade \
    && apt-get -y dist-upgrade

# Install dependencies
RUN apt-get -y install \
    cleancss \
    doxygen \
    debhelper-compat \
    flite1-dev \
    frei0r-plugins-dev \
    ladspa-sdk libaom-dev \
    libaribb24-dev \
    libass-dev \
    libbluray-dev \
    libbs2b-dev \
    libbz2-dev \
    libcaca-dev \
    libcdio-paranoia-dev \
    libchromaprint-dev \
    libcodec2-dev \
    libdc1394-22-dev \
    libdrm-dev \
    libfdk-aac-dev \
    libffmpeg-nvenc-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libgl1-mesa-dev \
    libgme-dev \
    libgnutls28-dev \
    libgsm1-dev \
    libiec61883-dev \
    libavc1394-dev \
    libjack-jackd2-dev \
    liblensfun-dev \
    liblilv-dev \
    liblzma-dev \
    libmp3lame-dev \
    libmysofa-dev \
    libnvidia-compute-470-server \
    libnvidia-decode-470-server \
    libnvidia-encode-470-server \
    libopenal-dev \
    libomxil-bellagio-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libopenjp2-7-dev \
    libopenmpt-dev \
    libopus-dev \
    libpulse-dev \
    librubberband-dev \
    librsvg2-dev \
    libsctp-dev \
    libsdl2-dev \
    libshine-dev \
    libsnappy-dev \
    libsoxr-dev \
    libspeex-dev \
    libssh-gcrypt-dev \
    libtesseract-dev \
    libtheora-dev \
    libtwolame-dev \
    libva-dev \
    libvdpau-dev \
    libvidstab-dev \
    libvo-amrwbenc-dev \
    libvorbis-dev \
    libvpx-dev \
    libwavpack-dev \
    libwebp-dev \
    libx264-dev \
    libx265-dev \
    libxcb-shape0-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    libxml2-dev \
    libxv-dev \
    libxvidcore-dev \
    libxvmc-dev \
    libzmq3-dev \
    libzvbi-dev \
    nasm \
    node-less \
    ocl-icd-opencl-dev \
    pkg-config \
    texinfo \
    tree \
    wget \
    zlib1g-dev

# Switch to user "anaconda"
USER ${ANACONDA_UID}
WORKDIR ${HOME}

# Build ffmpeg
RUN wget -O ${HOME}/ffmpeg-${FFMPEG_VERSION}.tar.gz https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz \
    && tar -xvf ${HOME}/ffmpeg-${FFMPEG_VERSION}.tar.gz \
    && cd ${HOME}/ffmpeg-${FFMPEG_VERSION} \
    && ./configure --prefix=/usr/local/ffmpeg-nvidia \
        --extra-cflags=-I/usr/local/cuda/include \
        --extra-ldflags=-L/usr/local/cuda/lib64 \
        --toolchain=hardened \
        --enable-gpl \
        --disable-stripping \
        --disable-filter=resample \
        --enable-cuvid \
        --enable-gnutls \
        --enable-ladspa \
        --enable-libaom \
        --enable-libass \
        --enable-libbluray \
        --enable-libbs2b \
        --enable-libcaca \
        --enable-libcdio \
        --enable-libcodec2 \
        --enable-libfdk-aac \
        --enable-libflite \
        --enable-libfontconfig \
        --enable-libfreetype \
        --enable-libfribidi \
        --enable-libgme \
        --enable-libgsm \
        --enable-libjack \
        --enable-libmp3lame \
        --enable-libmysofa \
        --enable-libnpp \
        --enable-libopenjpeg \
        --enable-libopenmpt \
        --enable-libopus \
        --enable-libpulse \
        --enable-librsvg \
        --enable-librubberband \
        --enable-libshine \
        --enable-libsnappy \
        --enable-libsoxr \
        --enable-libspeex \
        --enable-libssh \
        --enable-libtheora \
        --enable-libtwolame \
        --enable-libvorbis \
        --enable-libvidstab \
        --enable-libvpx \
        --enable-libwebp \
        --enable-libx265 \
        --enable-libxml2 \
        --enable-libxvid \
        --enable-libzmq \
        --enable-libzvbi \
        --enable-lv2 \
        --enable-nvenc \
        --enable-nonfree \
        --enable-omx \
        --enable-openal \
        --enable-opencl \
        --enable-opengl \
        --enable-sdl2 \
    && make -j 8

USER root

RUN cd ${HOME}/ffmpeg-${FFMPEG_VERSION} \
    && make install

USER $ANACONDA_UID

# Clean build files
RUN cd ${HOME} \
    && rm -rvf ${HOME}/ffmpeg-${FFMPEG_VERSION}.tar.gz ${HOME}/ffmpeg-${FFMPEG_VERSION}

RUN echo 'PATH="/usr/local/ffmpeg-nvidia/bin:$PATH"' >> ${HOME}/.bashrc

# Switch back to root
USER root

# Clean Anaconda
RUN conda clean -afy

# Clean packages and caches
RUN apt-get --purge -y autoremove \
        wget \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* ${HOME}/FFmpeg* \
    && rm -rvf /home/${ANACONDA_PATH}/.cache/yarn \
    && fix-permissions ${HOME} \
    && fix-permissions ${ANACONDA_PATH}
# ============================================================================
# CUSTOMIZAÇÕES PARA SISTEMA DE VÍDEO IA - jannargyrou
# ============================================================================

# Instalar Nginx + PHP (já estamos como root)
RUN apt-get update && apt-get install -y \
    nginx \
    php8.1-fpm \
    php8.1-cli \
    php8.1-curl \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Voltar para anaconda user e instalar Jupyter Lab
USER $ANACONDA_UID
RUN pip install jupyterlab

# Configurar comando para manter container rodando
USER root
COPY <<EOF /usr/local/bin/start.sh
#!/bin/bash
echo "🚀 Sistema de Vídeo IA iniciando..."
echo "✅ FFmpeg + NVENC disponível"
echo "✅ Nginx + PHP instalados"
echo "✅ Jupyter Lab disponível"
sleep infinity
EOF
RUN chmod +x /usr/local/bin/start.sh

# ============================================================================

# Re-activate user "anaconda"
USER $ANACONDA_UID
WORKDIR $HOME
CMD ["/usr/local/bin/start.sh"]
