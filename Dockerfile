FROM ubuntu:20.04

USER root
ENV LANG=C.UTF-8

COPY common.sh fullbak.sh incrbak.sh install.sh /root/

RUN sh /root/install.sh && rm -rf /root/install.sh && chmod a+x /root/*.sh

COPY init.sh /root/
RUN chmod a+x /root/*.sh

VOLUME /data
ENTRYPOINT ["/root/init.sh"]

CMD [ "init" ]
