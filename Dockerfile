# -------------------
# The build container
# -------------------
FROM alpine:3.14 AS build

RUN apk add --no-cache \
  bash \
  build-base \
  cmake \
  coreutils \
  curl-dev \
  gfortran \
  libffi-dev \
  linux-headers \
  perl \
  pkgconf \
  opam \
  unzip

RUN opam init -y --disable-sandboxing

RUN opam install -y core async ctypes ctypes-foreign ocurl

ADD https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.22.1-Source.tar.gz?api=v2 /root/eccodes-2.22.1-Source.tar.gz
RUN tar -C /root/ -x -z -f /root/eccodes-2.22.1-Source.tar.gz && \
  mkdir -p /root/eccodes-2.22.1-Source/build && \
  cd /root/eccodes-2.22.1-Source/build && \
  cmake ../ && \
  make && \
  make install && \
  DESTDIR=/root/target make install

ADD https://github.com/projecthorus/tawhiri-downloader/archive/master.zip /root/tawhiri-downloader-master.zip
RUN unzip /root/tawhiri-downloader-master.zip -d /root && \
  rm /root/tawhiri-downloader-master.zip && \
  cd /root/tawhiri-downloader-master && \
  mkdir -p /root/target/root/tawhiri-downloader/ && \
  eval $(opam env) && \
  dune build --profile=release --build-dir=/root/target/root/tawhiri-downloader/ main.exe

# -------------------------
# The application container
# -------------------------
FROM alpine:3.14

RUN apk add --no-cache \
  libcurl \
  libffi \
  tzdata

COPY --from=build /root/target /

ENTRYPOINT ["/root/tawhiri-downloader/default/main.exe"]
