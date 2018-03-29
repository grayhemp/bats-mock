#!/usr/bin/env bash
#
# Install Bats

set -ex

: ${BATS_VERSION:='0.4.0'}
: ${BATS_VERSION_MD5SUM:='aeeddc0b36b8321930bf96fce6ec41ee'}
: ${PREFIX:=/usr/local}

mkdir bats && cd bats
wget -O bats.tar.gz \
     "https://github.com/sstephenson/bats/archive/v${BATS_VERSION}.tar.gz"
echo "${BATS_VERSION_MD5SUM}  bats.tar.gz" | md5sum -c -
tar -xf bats.tar.gz --strip-components 1
./install.sh "${PREFIX}"
