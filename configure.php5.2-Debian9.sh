#!/bin/sh
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2020 SIP-Online (http://www.sip-online.fr/)
#
##############

LP_X86_64="x86_64-linux-gnu"
MYSQL_SOCK_PATH="/run/mysqld/mysqld.sock"

BASEDIR=$(pwd)
X86_64_PATH="lib/x86_64-linux-gnu"
PROJECT_PATH="${BASEDIR}/php-libssl-1.0"
PHP_PATH="php-5.2.17"
OPENSSL_PATH="/usr/local/openssl-1.0"
CURL_PATH="/usr/local/curlssl-1.0"
IMAP_2007_PATH="/usr/local/uw-imapssl-1.0"
PHP_PREFIX="/opt/rh/php52"

OPENSSL_VERSION="1.0.2u"
CURL_VERSION="7.69.1"
IMAP_2007_VERSION="2007f"
IMAP_2007_REVISION="7"

cd "/usr/lib"
if [ ! -L "libjpeg.so" ] && [ -f "${LP_X86_64}/libjpeg.so" ]; then
	echo "Add the symbolic link \"${LP_X86_64}/libjpeg.so\" => \"libjpeg.so\""
	ln -s "${LP_X86_64}/libjpeg.so" "libjpeg.so"

	sleep 1
fi

if [ ! -L "libpng.so" ] && [ -f "${LP_X86_64}/libpng.so" ]; then
	echo "Add the symbolic link \"${LP_X86_64}/libpng.so\" => \"libpng.so\""
	ln -s "${LP_X86_64}/libpng.so" "libpng.so"

	sleep 1
fi

if [ ! -L "libXpm.so" ] && [ -f "${LP_X86_64}/libXpm.so" ]; then
	echo "Add the symbolic link \"${LP_X86_64}/libXpm.so\" => \"libXpm.so\""
	ln -s "${LP_X86_64}/libXpm.so" "libXpm.so"

	sleep 1
fi

if [ ! -L "libkrb5.so" ] && [ -f "${LP_X86_64}/libkrb5.so" ]; then
	echo "Add the symbolic link \"${LP_X86_64}/libkrb5.so\" => \"libkrb5.so\""
	ln -s "${LP_X86_64}/libkrb5.so" "libkrb5.so"

	sleep 1
fi

if [ "${1}" = "force" ]; then
	if [ -d "${PROJECT_PATH}" ]; then
		rm -r "${PROJECT_PATH}"
	fi

	if [ -d "${OPENSSL_PATH}" ]; then
		rm -r "${OPENSSL_PATH}"
	fi

	if [ -d "${CURL_PATH}" ]; then
		rm -r "${CURL_PATH}"
	fi

	if [ -d "${IMAP_2007_PATH}" ]; then
		rm -r "${IMAP_2007_PATH}"
	fi
fi

if [ ! -d "${PROJECT_PATH}" ]; then
	mkdir -p -m 0755 "${PROJECT_PATH}"
fi

cd "${PROJECT_PATH}"

if [ ! -d "${OPENSSL_PATH}" ]; then
	if [ -d "openssl-${OPENSSL_VERSION}" ]; then
		rm -r "openssl-${OPENSSL_VERSION}"
	fi

	wget "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
	tar -xzf "openssl-${OPENSSL_VERSION}.tar.gz"
	cd "openssl-${OPENSSL_VERSION}"
	./config shared \
		--prefix=${OPENSSL_PATH} \
		--openssldir=${OPENSSL_PATH} \
		no-idea \
		no-mdc2 \
		no-rc5 no-zlib \
		enable-tlsext \
		no-ssl2 \
		no-ssl3 \
		enable-ec_nistp_64_gcc_128

	make depend
	make
	make install

	ln -s "${OPENSSL_PATH}/lib" "${OPENSSL_PATH}/${X86_64_PATH}"
fi

if [ ! -d "${CURL_PATH}" ]; then
	cd "${PROJECT_PATH}"

	if [ -d "curl-${CURL_VERSION}" ]; then
		rm -r "curl-${CURL_VERSION}"
	fi

	wget "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz"
	tar -xzf "curl-${CURL_VERSION}.tar.gz"
	cd "curl-${CURL_VERSION}"
	env PKG_CONFIG_PATH=${OPENSSL_PATH}/lib/pkgconfig \
	LDFLAGS=-Wl,-rpath=${OPENSSL_PATH}/lib \
	./configure \
		--prefix=${CURL_PATH} \
		--with-zlib \
		--with-ssl=${OPENSSL_PATH} \
		--disable-dependency-tracking \
		--disable-symbol-hiding --enable-versioned-symbols \
		--enable-threaded-resolver --with-lber-lib=lber \
		--with-gssapi=/usr --with-nghttp2 \
		--with-zsh-functions-dir=/usr/share/zsh/vendor-completions \
		--with-ca-path=/etc/ssl/certs

	make
	make install

	ln -s "${CURL_PATH}/lib" "${CURL_PATH}/${X86_64_PATH}"
fi

if [ ! -d "${IMAP_2007_PATH}" ]; then
	cd "${PROJECT_PATH}"

	if [ -d "uw-imap_${IMAP_2007_VERSION}" ]; then
		rm -r "uw-imap_${IMAP_2007_VERSION}"
	fi

	mkdir -p -m 0755 "uw-imap_${IMAP_2007_VERSION}"
	cd "uw-imap_${IMAP_2007_VERSION}"

	wget "http://http.debian.net/debian/pool/main/u/uw-imap/uw-imap_${IMAP_2007_VERSION}~dfsg-${IMAP_2007_REVISION}.dsc"
	wget "http://http.debian.net/debian/pool/main/u/uw-imap/uw-imap_${IMAP_2007_VERSION}~dfsg.orig.tar.gz"
	wget "http://http.debian.net/debian/pool/main/u/uw-imap/uw-imap_${IMAP_2007_VERSION}~dfsg-${IMAP_2007_REVISION}.debian.tar.xz"
	dpkg-source -x "uw-imap_${IMAP_2007_VERSION}~dfsg-${IMAP_2007_REVISION}.dsc" "imap-${IMAP_2007_VERSION}"

	if [ -d "imap-${IMAP_2007_VERSION}" ]; then
		cd "imap-${IMAP_2007_VERSION}"

		touch {ipv6,lnxok}

		yes "y" | make \
			lnp \
			EXTRAAUTHENTICATORS=gss \
			PASSWDTYPE=pam SPECIALAUTHENTICATORS=ssl \
			SSLINCLUDE=${OPENSSL_PATH}/include/ \
			SSLLIB=${OPENSSL_PATH}/lib \
			SSLTYPE=unix \
			EXTRACFLAGS="${CFLAGS} -fPIC -lgssapi_krb5 -lkrb5 -lk5crypto -lcom_err -lpam" \
			EXTRALDFLAGS="${LDFLAGS}"

		mkdir -p -m 0755 "${IMAP_2007_PATH}/lib" "${IMAP_2007_PATH}/include"
		cp c-client/*.c "${IMAP_2007_PATH}/lib"
		cp c-client/*.h "${IMAP_2007_PATH}/include"
		cp c-client/c-client.a "${IMAP_2007_PATH}/lib/libc-client.a"

		ln -s "${IMAP_2007_PATH}/lib" "${IMAP_2007_PATH}/${X86_64_PATH}"
	fi
fi

cd "${PROJECT_PATH}"

if [ -d "${PHP_PATH}" ]; then
	rm -r "${PHP_PATH}"
fi

if [ ! -f "${PHP_PATH}.tar.bz2" ]; then
	wget -O "${PHP_PATH}.tar.bz2" "http://museum.php.net/php5/${PHP_PATH}.tar.bz2"
fi

tar -xjf "${PHP_PATH}.tar.bz2"
cd "${PHP_PATH}"

patch -p 1 -i "../../php-5.2.17-mysqlnd.patch"
patch -p 1 -i "../../${PHP_PATH}-mail-header.patch"
patch -p 1 -i "../../suhosin-patch-5.2.16-0.9.7.patch"
patch -p 1 -i "../../debian_patches_disable_SSLv2_for_openssl_1_0_0.patch"
patch -p 1 -i "../../php-libxml.patch"
patch -p 1 -i "../../php-5.2.17-fpm-0.5.14.patch"

./configure \
	--prefix=${PHP_PREFIX} \
	--with-config-file-path=${PHP_PREFIX}/etc/cgi \
	--with-curl=${CURL_PATH} \
	--with-gd \
	--with-gettext \
	--with-jpeg-dir \
	--with-freetype-dir \
	--with-kerberos \
	--with-openssl=${OPENSSL_PATH} \
	--with-mcrypt \
	--with-mhash \
	--with-imap=${IMAP_2007_PATH} \
	--with-imap-ssl=${IMAP_2007_PATH} \
	--with-mysql=mysqlnd \
	--with-mysql-sock=${MYSQL_SOCK_PATH} \
	--with-mysqli=mysqlnd \
	--with-pdo-mysql=mysqlnd \
	--with-pcre-regex \
	--with-pear \
	--with-png-dir \
	--with-xsl \
	--with-zlib \
	--with-zlib-dir \
	--with-iconv \
	--enable-force-cgi-redirect \
	--enable-fastcgi \
	--enable-fpm \
	--enable-zip \
	--enable-gd-native-ttf \
	--enable-bcmath \
	--enable-calendar \
	--enable-ftp \
	--enable-magic-quotes \
	--enable-sockets \
	--enable-mbstring \
	--enable-exif \
	--enable-soap

make
make install
