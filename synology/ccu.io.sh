#!/bin/sh

NODE=/usr/bin/node
CCUIO_PATH=/volume1/data/ccu.io-master/
CCUIO=ccu.io-server.js

if [ "$*" = 'start' ] ; then
	echo "Starting ccu.io"
	cd $CCUIO_PATH
	$NODE $CCUIO start
fi
