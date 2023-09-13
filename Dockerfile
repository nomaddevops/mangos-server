ARG MANGOS_VERSION
FROM --platform=linux/amd64 joffreydupire/mangos-base:$MANGOS_VERSION as build-mangos
WORKDIR /home/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/mangos -DBUILD_MANGOSD=1 -DBUILD_REALMD=0 -DBUILD_TOOLS=0
RUN make -j4
RUN make install

FROM --platform=linux/amd64 ubuntu:18.04 as mangos
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install libmysqlclient20 openssl

COPY --from=build-mangos /mangos/bin/mangosd /usr/local/bin/mangosd
COPY --from=build-mangos /etc/mangosd.conf.dist /etc/mangos/mangosd.conf.dist
COPY --from=build-mangos /etc/mangosd.conf.dist /etc/mangos/mangosd.conf
COPY --from=build-mangos /mangos /etc/mangos

RUN chmod +x /usr/local/bin/mangosd
VOLUME ["/etc/mangos"]
EXPOSE 8085
CMD [ "/usr/local/bin/mangosd","-c","/etc/mangos/mangosd.conf" ]