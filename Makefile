#! /usr/bin/make -f
# -*- makefile -*-
# ex: set tabstop=4 noexpandtab:

default: help

project=castanets
url?=https://github.com/Samsung/castanets
dir=${CURDIR}/out/Default
exe_basename=chrome
exe=${dir}/${exe_basename}
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
src_dir=${CURDIR}/tmp/src


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

${dir}:
	gn gen out/Default

${dir}/args.gn: ${dir}
	echo 'enable_castanets=true' | tee $@
	echo 'enable_nacl=false' | tee -a $@
	gn args --list ${@D}

${exe}: ${dir}/args.gn
	ninja -C ${@D} ${@F}

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

#{ TODO: extra
deploy_tools_url?=https://chromium.googlesource.com/chromium/tools/depot_tools.git
PATH:=${PATH}:${CURDIR}/tmp/depot_tools
export PATH

tmp/depot_tools/gclient: build/create_gclient.sh
	ls $@

${HOME}/.gclient: tmp/depot_tools/gclient
	build/create_gclient.sh

${src_dir}: ${CURDIR}
	mkdir -p ${@D}
	ln -fs $< $@

tmp/install-build-deps.sh.done: build/install-build-deps.sh
	mkdir -p ${@D}
	yes | $<
	touch $@

${srcdir}/../.gclient: 	build/create_gclient.sh
	$<

rule/setup/debian: ${src_dir} tmp/depot_tools/gclient tmp/install-build-deps.sh.done
	sync
	which gclient
	cd $< && gclient sync --with_branch_head
#	gclient config

tmp/depot_tools: 
	@mkdir -p ${@D}
	git clone --recursive --depth 1 ${deploy_tools_url} ${@}

tmp/depot_tools/gclient: tmp/depot_tools

rule/build: 
#	which gclient ||
#	make rule/setup/debian
	make ${exe}
	ls $<


#} TODO: extra
