#!/bin/sh


VALID_DONGLES="0bda:2838"                 # Realtek RTL2838 DVB-T
VALID_DONGLES="$VALID_DONGLES 1d50:604b"  # HackRF Jawbreaker
VALID_DONGLES="$VALID_DONGLES 1d50:6089"  # Great Scott Gadgets HackRF One
VALID_DONGLES="$VALID_DONGLES 1fc9:000c"  # HackRF One


# Is an SDR dongle attached?
DEV_FLAGS=""
for dongle in $VALID_DONGLES; do
    dev_id=$(lsusb -d $dongle | sed -n 's#Bus \([0-9]*\) Device \([0-9]*\).*#\1/\2#p')
    if [ -n "$dev_id" ]; then
        DEV_FLAGS="$DEV_FLAGS --device=/dev/bus/usb/$dev_id"
    fi
done
if [ -z "$DEV_FLAGS" ]; then
    echo "ERROR: no SDR devices attached"
    exit 1
fi


# Already started?
if [ -n "$(docker ps -qaf 'name=gqrx-src')" ]; then
    echo "ERROR: gqrx container already started"
    exit 1
fi


# Allow docker to connect to current X session
xhost +local:docker


# Build
docker build -t local/gqrx-src $(realpath $(dirname $0))


# Run
docker run --rm -i -t \
       ${DEV_FLAGS} \
       --device=/dev/dri:/dev/dri \
       --volume ${HOME}/.config/gqrx:/root/.config/gqrx \
       --volume /dev/shm:/dev/shm \
       --volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
       --volume /run/user/$(id -u)/pulse:/run/pulse:ro \
       --volume /var/lib/dbus:/var/lib/dbus \
       --volume /dev/snd:/dev/snd \
       --env USER_UID=$(id -u) \
       --env USER_GID=$(id -g) \
       --env DISPLAY=unix$DISPLAY \
       --name gqrx-src \
       local/gqrx-src $@
