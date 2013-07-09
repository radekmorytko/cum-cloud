#!/bin/bash

PACKAGE_NAME=${PACKAGE_NAME:-vm_coordinator}
PACKAGE_TYPE=${PACKAGE_TYPE:-deb}
VENDOR=${VENDOR:-cum_cloud}
VERSION=${VERSION:-3.8.3}
MAINTAINER=${MAINTAINER:-cum_cloud <dariusz@chrzascik.com>}
NAME="${PACKAGE_NAME}_${VERSION}.${PACKAGE_TYPE}"

# cleanup
WORKDIR=$PWD
DESTDIR=$WORKDIR/'tmp'
rm -rf $DESTDIR
mkdir $DESTDIR

# copy files to reflect global directory structure
INST_DIR='/usr/lib/one/ruby/oneapps'

mkdir -p $DESTDIR/$INST_DIR
cp -r src/vm_coordinator $DESTDIR/$INST_DIR

# create package
cd $DESTDIR

fpm -n "$PACKAGE_NAME" -t "$PACKAGE_TYPE" -s dir --vendor "$VENDOR" \
    -m "$MAINTAINER" -v "$VERSION" \
    -f -a all -p $WORKDIR/$NAME *