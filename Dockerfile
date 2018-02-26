FROM debian:testing


# Supporting packages
RUN echo "keyboard-configuration keyboard-configuration/layoutcode string en" | debconf-set-selections && \
    apt-get update && \
    apt-get install -y git \
                       pulseaudio \
                       xserver-xorg-video-all \
                       libgl1-mesa-glx \
                       libgl1-mesa-dri


# Get build dependencies
RUN apt-get update && \
    apt-get install -y gnuradio-dev \
                       cmake \
                       qtdeclarative5-dev \
                       libpulse-dev \
                       libqt5svg5-dev \
                       gr-osmosdr


# Clone gqrx source
RUN mkdir -p /opt/gqrx && \
    cd /opt/gqrx && \
    git clone https://github.com/csete/gqrx.git src && \
    mkdir /opt/gqrx/src/build


# Build and install
RUN cd /opt/gqrx/src/build && \
    cmake .. && \
    make && \
    make install


ENV PULSE_SERVER /run/pulse/native
CMD ["/usr/local/bin/gqrx"]
