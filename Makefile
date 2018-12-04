#! /usr/bin/make -f
# -*- makefile -*-
# ex: set tabstop=4 noexpandtab:

default: help

project=castanets
dir=${CURDIR}/out/Default/
exe=${dir}chrome
url?=https://github.com/Samsung/castanets
debian_requires?= \
 libasound2, \
 libgconf-2-4, \
 libgtk-3-0, \
 libnss3, \
 libxss1, \
 libgl1 \
#EOL
maintainer?=p.coval@samsung.com
pkglicense?=BSD-3-clause and others
pkgversion?=$(shell git describe --tag | tr '-' '+' || echo 0.0.0)
pkgrelease?=0~${USER}0
pkgsummary?=Web engine distributed among multiple devices

help:
	echo "TODO"

%: help

install: ${exe}
	install -d ${DESTDIR}/usr/lib/${project}
	install $< ${DESTDIR}/usr/lib/${project}
	ldd ${exe} | grep -o "${CURDIR}/[^ ]*" | \
 while read file; do \
  install $${file} ${DESTDIR}/usr/lib/${project}; \
 done
	install ${<D}/*.bin ${DESTDIR}/usr/lib/${project}
	install ${<D}/*.dat ${DESTDIR}/usr/lib/${project}
	install ${<D}/*.pak ${DESTDIR}/usr/lib/${project}
	cp -rfa ${<D}/locales ${DESTDIR}/usr/lib/${project}

${exe}:
	@mkdir -p ${@D}
	touch ${exe}

checkinstall/debian: ${exe}
	@echo "${pkgsummary}" > description-pak
	checkinstall --version
	checkinstall \
 --backup="no" \
 --conflicts="${project}" \
 --default \
 --install=no \
 --maintainer="${maintainer}" \
 --nodoc \
 --pkglicense="${pkglicense}" \
 --pkgname="${project}-snapshot" \
 --pkgrelease="${pkgrelease}" \
 --pkgsource="${url}" \
 --pkgversion="${pkgversion}" \
 --requires="${debian_requires}" \
 --type ${@F} \
 #EOL
