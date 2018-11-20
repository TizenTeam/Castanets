#!/bin/echo docker build . -f
# -*- coding: utf-8 -*-
# Copyright: 2018-present Samsung Electronics France SAS, and other contributors

FROM ubuntu:16.04
MAINTAINER Philippe Coval (p.coval@samsung.com)

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG ${LC_ALL}

RUN echo "#log: Configuring locales" \
  && set -x \
  && apt-get update -y \
  && apt-get install -y locales \
  && echo "${LC_ALL} UTF-8" | tee /etc/locale.gen \
  && locale-gen ${LC_ALL} \
  && dpkg-reconfigure locales \
  && sync

RUN echo "#log: Setup system" \
  && set -x \
  && apt-get update -y \
  && apt-get install -y \
     sudo apt-transport-https make curl \
          git \
  && apt-get clean \
  && sync

ENV project castanets
ADD . /usr/local/opt/${project}/src/${project}
WORKDIR /usr/local/opt/${project}/src/${project}
RUN echo "#log: ${project}: Preparing sources" \
  && set -x \
  && git clone https://chromium.googlesource.com/chromium/tools/depot_tools \
  && sync

WORKDIR /usr/local/opt/${project}/src/${project}
RUN echo "#log: ${project}: Preparing sources" \
  && set -x \
  && mkdir -p src && cd src \
  && git clone -b castanets_63 --recursive --depth 1 \
     https://github.com/Samsung/castanets . \
  && sync

RUN echo "#log: Setup system" \
  && set -x \
  && apt-get update -y \
  && apt-get install -y \
     lsb-release \
  && apt-get clean \
  && sync

WORKDIR /usr/local/opt/${project}/src/${project}/src
RUN echo "#log: ${project}: Preparing sources" \
  && set -x \
  && export PATH="${PATH}:${PWD}/depot_tools" \
  && ls \
  && yes | build/install-build-deps.sh \
  && sync

RUN echo "#log: ${project}: Preparing sources" \
  && set -x \
  && build/create_gclient.sh \
  && sync

RUN echo "#log: ${project}: Preparing sources" \
  && set -x \
  && gclient sync --with_branch_head \
  && sync
