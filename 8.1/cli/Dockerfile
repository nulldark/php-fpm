FROM alpine:3.21

ARG PHP_VERSION=8.1.31
ARG PHP_URL="https://www.php.net/distributions/php-${PHP_VERSION}.tar.xz"

LABEL org.opencontainers.image.base.name="docker.io/library/alpine:3.21" \
      org.opencontainers.image.description="Application packaged by grmvoid" \
      org.opencontainers.image.documentation="https://github.com/grmvoid/docker-php/tree/master/README.md" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.ref.name="${PHP_VERSION}" \
      org.opencontainers.image.source="https://github.com/grmvoid/docker-php/tree/master/8.1/cli" \
      org.opencontainers.image.title="php" \
      org.opencontainers.image.vendor="grmvoid" \
      org.opencontainers.image.version="${PHP_VERSION}"

ENV PHPIZE_DEPS \
  autoconf \
  dpkg dpkg-dev \
  file \
  clang \
  llvm \
  libc-dev \
  make \
  pkgconf \
  re2c

ENV PHP_SHA256=""
ENV PHP_INI_DIR="/usr/local/etc/php"
ENV PHP_SCAN_DIR="$PHP_INI_DIR/conf.d"

ENV PHP_LDFLAGS="-Wl,-O3 -pie"
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O3 \
    -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 \
    -march=native \
    -funroll-loops \
    -ffast-math \
    -finline-functions \
"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"

COPY docker-entrypoint docker-php-* /usr/local/bin/

RUN set -eux; \
  \
  # install build tools
    apk add --no-cache --virtual .build-deps \
      $PHPIZE_DEPS \
      argon2-dev \
      coreutils \
      curl-dev \
      gnu-libiconv-dev \
      libsodium-dev \
      libxml2-dev \
      linux-headers \
      oniguruma-dev \
      openssl-dev \
      readline-dev \
      sqlite-dev \
      curl \
      make; \
  \
  # export required environment variables
    export \
      CFLAGS="$PHP_CFLAGS" \
      CPPFLAGS="$PHP_CPPFLAGS" \
      LDFLAGS="$PHP_LDFLAGS" \
      PHP_BUILD_PROVIDER='https://github.com/grmvoid/docker-php-cli' \
      PHP_UNAME='Linux - Docker' \
    ; \
  \
  # gets php sources \
    mkdir -p /usr/src; \
    cd /usr/src; \
    \
    # download sources
      curl -fsSL -o php.tar.xz "$PHP_URL"; \
    \
    # generate checksum if not exists
    if [-n "$PHP_SHA256"]; then \
      echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
    fi; \
    \
    # extract sources
      docker-php-source extract; \
      cd /usr/src/php; \
  \
  # configure the build
    ./configure CC=clang CXX=clang++ \
      --build="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
      --prefix="/usr/local/" \
      --sbin="/usr/local/sbin" \
      --sysconfdir="$PHP_INI_DIR" \
      --localstatedir=/var \
      --mandir=/usr/share/man \
      --with-layout=GNU \
      --with-config-file-path="$PHP_INI_DIR" \
      --with-config-file-scan-dir="$PHP_SCAN_DIR" \
      --config-cache \
      --enable-option-checking=fatal \
      --disable-gcc-global-regs \
      --disable-rpath \
      --enable-mbstring \
      --enable-mysqlnd \
      --without-sqlite3 \
      --without-cdb \
      --with-openssl \
      --with-zlib \
      # it's cli image so disable fpm & and cgi
      --disable-cgi \
      --disable-fpm \
      --disable-phpdbg; \
  \
  # compile and install php
    make -j $(nproc); \
    make install; \
    \
    find /usr/local \
      -type f \
      -perm '/0111' \
      -exec sh -euxc ' \
      strip --strip-all "$@" || : \
      ' -- '{}' + \
    ; \
  \
  # cleaning up after compilation
    make clean; \
    make distclean; \
    \
    # copy php.ini into $PHP_INIT_DIR \
      mkdir -p "$PHP_INI_DIR"; \
      cp php.ini-* "$PHP_INI_DIR/"; \
    \
    # remove sources
      cd /; \
      rm -rf /usr/src/php; \
  \
  # remove build deps, install runtime deps
    runDeps="$( \
      scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )";  \
    apk add --no-cache $runDeps; \
    apk del --no-network .build-deps; \
  \
  # smoke test
    php --version; \
  \
  # delete all *.default conf
    cd "$PHP_INI_DIR"; \
    find "$PHP_INI_DIR" \
    -type f \
    -name '*.default' \
    -exec rm {} + ; \
  \
  # clear apk cache
    rm -rf /var/cache/apk/*

ENTRYPOINT [ "docker-entrypoint" ]
CMD [ "php", "-a" ]