FROM ubuntu:20.04 AS BUILD

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential curl git libssl-dev ruby-dev qttools5-dev qttools5-dev-tools libqt5svg5-dev libqt5opengl5-dev supercollider-server sc3-plugins-server alsa-utils jackd2 libjack-jackd2-dev libjack-jackd2-0 libasound2-dev pulseaudio-module-jack cmake ninja-build wget

RUN wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && dpkg -i erlang-solutions_2.0_all.deb && apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y esl-erlang elixir

RUN git clone --branch v4.3.0 --depth 1 https://github.com/sonic-pi-net/sonic-pi.git ~/Development/sonic-pi

WORKDIR /root/Development/sonic-pi/app
SHELL ["/bin/bash", "-c"]

#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y automake autoconf libncurses5-dev unzip && ./pi-install-elixir.sh
RUN ./linux-prebuild.sh
RUN ./linux-config.sh
RUN ./linux-build-gui.sh
RUN ./linux-post-tau-prod-release.sh
RUN ./linux-release.sh

FROM ubuntu:20.04 AS BUILD_APPIMAGE

COPY --from=BUILD /root/Development/sonic-pi/app/build/linux_dist /opt/sonic-pi

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget file

RUN cd /opt/sonic-pi && ln -s app/build/gui/qt/sonic-pi AppRun && wget -O myapp.png https://raw.githubusercontent.com/sonic-pi-net/sonic-pi/dev/app/gui/qt/images/icon-smaller.png

COPY myapp.desktop /opt/sonic-pi/

RUN cd /opt && wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage && chmod +x appimagetool-x86_64.AppImage

RUN cd /opt && ARCH=x86_64 ./appimagetool-x86_64.AppImage --appimage-extract-and-run sonic-pi

FROM ubuntu:20.04

COPY --from=BUILD /root/Development/sonic-pi /opt/sonic-pi
COPY --from=BUILD_APPIMAGE /opt/Sonic_Pi-x86_64.AppImage /opt
