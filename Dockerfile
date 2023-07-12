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

# RUN opam install -y core async ctypes ctypes-foreign ocurl
RUN opam install -y core=0.14.1 async=0.14.0 ctypes=0.18.0 ctypes-foreign=0.18.0 ocurl=0.9.1

ADD https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.22.1-Source.tar.gz?api=v2 /root/eccodes-2.22.1-Source.tar.gz
RUN tar -C /root/ -x -z -f /root/eccodes-2.22.1-Source.tar.gz && \
  mkdir -p /root/eccodes-2.22.1-Source/build && \
  cd /root/eccodes-2.22.1-Source/build && \
  cmake ../ && \
  make && \
  make install && \
  DESTDIR=/root/target make install

ADD https://github.com/cuspaceflight/tawhiri-downloader/archive/master.zip /root/tawhiri-downloader-master.zip
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
  tzdata \
  python3 \
  py3-boto3

COPY --from=build /root/target /

COPY scripts/download.py /

RUN chmod a+x /download.py

RUN mkdir -p /srv/tawhiri-datasets

WORKDIR /root

ENTRYPOINT ["/download.py"]
