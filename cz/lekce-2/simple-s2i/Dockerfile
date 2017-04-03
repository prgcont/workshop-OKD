FROM openshift/base-centos7

MAINTAINER Miloslav Vlach <miloslav.vlach@gmail.com>

LABEL io.k8s.description="S2I for static html content" \
      io.k8s.display-name="rohlik-httpd-24" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="static html"

RUN 	yum -y install epel-release httpd.x86_64  \
	mc htop dstat telnet net-tools && \
	mkdir -p /run/httpd && chown 777 -R /run/httpd/ && \
	yum clean all


COPY ./.s2i/bin/ /usr/libexec/s2i
ADD ./httpd.conf /etc/httpd/conf
RUN chown -R 1001:1001 /opt/app-root
USER 1001
EXPOSE 8080

CMD ["usage"]

