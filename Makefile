#!/usr/bin/make -f

SHELL := /bin/bash


debs:
	mkdir -p build
	chmod -R 777 build
	cd build \
		&& git clone -b 6.2.3.114-COPR https://github.com/rhawalsh/kvdo/ \
		&& cp -a ../debian kvdo
	docker run -ti -v $$(pwd)/build:/home/bob phlax/debian-build bash -c "\
		sudo apt-get update \
		&& sudo apt-get install -y -qq libblkid-dev libdevmapper-dev libz-dev uuid-dev libudev-dev linux-headers-5.7.0-0.bpo.2-amd64 -t buster-backports \
		&& cd ~/kvdo/ \
		&& echo 'y' | sudo mk-build-deps -i \
		&& export DEBFULLNAME='Bob the builder' \
		&& ls \
		&& dpkg-buildpackage -us -uc"