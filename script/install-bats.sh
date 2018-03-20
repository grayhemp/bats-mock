#!/usr/bin/env sh
#
# Install Bats

set -ex

: ${BATS_VERSION:='0.4.0'}
: ${BATS_MD5SUM:='aeeddc0b36b8321930bf96fce6ec41ee'}

mkdir bats && cd bats
wget "https://github.com/sstephenson/bats/archive/v${BATS_VERSION}.tar.gz"
echo "${BATS_MD5SUM}  v${BATS_VERSION}.tar.gz" | md5sum -c -
tar -xf v${BATS_VERSION}.tar.gz --strip-components 1
sudo ./install.sh /usr/local
