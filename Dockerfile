# docker build -t patrikx3/openwrt-insomnia .
# docker container ls
# docker exec -it <containerIdOrName> bash
# docker attach <id>
# docker run -t -i patrikx3/openwrt-insomnia bash
FROM patrikx3/openwrt-insomnia:base
MAINTAINER patrikx3/openwrt-insomnia - Patrik Laszlo - alabard@gmail.com

ARG OPENWRT_VERSION_TOTAL=SNAPSHOT
#ARG OPENWRT_BRANCH=openwrt-17.01
ENV OPENWRT_VERSION_TOTAL=${OPENWRT_VERSION_TOTAL}
#ENV OPENWRT_BRANCH=${OPENWRT_BRANCH}

#RUN git clone -b ${OPENWRT_BRANCH} git://git.openwrt.org/source.git
RUN git clone git://git.openwrt.org/openwrt/openwrt.git source
WORKDIR /build/source

# once OPENWRT_VERSION_TOTAL != SNAPSHOT checkout the verions

#RUN git checkout tags/v${OPENWRT_VERSION_TOTAL}
RUN git checkout master

RUN cp feeds.conf.default feeds.conf
RUN echo 'src-git node https://github.com/nxhack/openwrt-node-packages.git' >> feeds.conf
RUN echo 'src-git redis https://github.com/patrikx3/openwrt-redis.git' >> feeds.conf
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
RUN ./scripts/feeds update node
RUN rm -rf ./package/feeds/packages/node*
#RUN rm ./package/feeds/packages/node-arduino-firmata
#RUN rm ./package/feeds/packages/node-cylon
#RUN rm ./package/feeds/packages/node-hid
#RUN rm ./package/feeds/packages/node-serialport
RUN ./scripts/feeds install -a -p node
RUN ./scripts/feeds update redis
RUN ./scripts/feeds install -a -p  redis

COPY make-scripts /build/source
RUN sudo find /build -user root -exec chown docker:docker {} \;

CMD /bin/bash
