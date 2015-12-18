# multi/mongodb:3.0.7

# scons -j$(grep -c '^processor' /proc/cpuinfo) docker hub cpu cap? ld kill -9 ...

FROM alpine:edge

ENV MONGODB_VERSION=3.0.7 WIREDTIGER_VERSION=2.7.0

ADD mongodb-${MONGODB_VERSION}.patch wiredtiger-${WIREDTIGER_VERSION}.patch /tmp/

RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add libpcrecpp libstdc++ libgcc pcre libexecinfo@testing snappy libpcap libatomic_ops && \
    apk add libexecinfo-dev@testing && \
    apk add -t build-deps file autoconf automake libtool build-base linux-headers scons snappy-dev zlib-dev pcre-dev libpcap-dev openssl-dev libatomic_ops-dev && \
    cd /tmp && \
    wget http://source.wiredtiger.com/releases/wiredtiger-${WIREDTIGER_VERSION}.tar.bz2 && \
    tar jxf wiredtiger-${WIREDTIGER_VERSION}.tar.bz2 && \
    cd wiredtiger-${WIREDTIGER_VERSION} && \
    patch -p1 -i ../wiredtiger-${WIREDTIGER_VERSION}.patch && \
    sh autogen.sh && \
    ./configure --prefix=/usr --with-builtins=snappy,zlib && \
    echo "cpus count: $(grep -c '^processor' /proc/cpuinfo)" && \
    make -j$(grep -c '^processor' /proc/cpuinfo) && \
    make install && \
    cd /tmp && \
    wget http://downloads.mongodb.org/src/mongodb-src-r${MONGODB_VERSION}.tar.gz && \
    tar zxf mongodb-src-r${MONGODB_VERSION}.tar.gz && \
    cd mongodb-src-r${MONGODB_VERSION} && \
    patch -p1 -i ../mongodb-${MONGODB_VERSION}.patch && \
    scons --prefix=/usr \
        --disable-warnings-as-errors \
        --use-system-pcre \
        --use-system-snappy \
        --use-system-wiredtiger \
        --use-system-zlib \
        --ssl \
        --allocator=system \
        --variant-dir=build \
        --64 \
        --extralib=libexecinfo \
        install && \
    adduser -S -D -G daemon -h /var/lib/mongodb -s /sbin/nologin mongodb && \
    apk del --purge libexecinfo-dev && \
    apk del --purge build-deps && \
    rm -rf /usr/share/man /tmp/* /var/cache/apk/* /usr/include

VOLUME /var/lib/mongodb

USER mongodb

EXPOSE 27017

CMD ["mongod", "--dbpath", "/var/lib/mongodb", "--nounixsocket", "--journal", "--cpu", "--storageEngine", "wiredTiger"]
