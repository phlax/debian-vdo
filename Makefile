
#!/usr/bin/make -f

SHELL := /bin/bash


debs:
	mkdir -p build
	chmod -R 777 build
	cd build \
		&& git clone -b 6.2.3.114-COPR https://github.com/rhawalsh/kvdo/ \
		&& git clone https://github.com/dm-vdo/vdo/ \
		&& cp -a ../vdo/debian vdo \
		&& cp -a ../kvdo/debian kvdo
	docker run -ti -e RUN_UID=$$(id -u) -v $$(pwd)/build:/home/bob phlax/debian-build bash -c "\
		sudo apt-get update \
		&& sudo apt-get install -y -qq libblkid-dev libdevmapper-dev libz-dev uuid-dev libudev-dev linux-headers-5.7.0-0.bpo.2-amd64 -t buster-backports \
		&& cd ~/kvdo/ \
		&& echo 'y' | sudo mk-build-deps -i \
		&& export DEBFULLNAME='Bob the builder' \
		&& dpkg-buildpackage -us -uc \
		&& cd ~/vdo/ \
		&& sudo apt-get install -y -qq libblkid-dev libdevmapper-dev python3-pip uuid-dev -t buster-backports \
		&& sudo pip3 install -U pip setuptools \
		&& sudo pip3 install -U pyyaml \
		&& cd ~/vdo/ \
		&& echo 'y' | sudo mk-build-deps -i \
		&& export DEBFULLNAME='Bob the builder' \
		&& mkdir build \
		&& dpkg-buildpackage -us -uc"

install-test:
	docker run -ti -v $$(pwd)/build:/tmp/build debian:buster-slim bash -c "\
		echo 'deb-src http://ftp.debian.org/debian testing main contrib non-free' >> /etc/apt/sources.list \
		&& apt-get update \
		&& ls /tmp/build \
		&& apt-get install -y -qq /tmp/build/kvdo_6.2.3-0_all.deb \
		&& dpkg -L kvdo"


publish:
	git clone https://github.com/phlax/debian
	cd debian && git remote set-url origin https://oauth2:$$GITHUB_ACCESS_TOKEN@github.com/phlax/debian \
	cd debian \
		&& reprepro includedeb buster ../build/*deb \
		&& git add pool \
		&& git commit . -m "vdo" \
		&& git push
