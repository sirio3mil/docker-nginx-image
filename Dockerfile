FROM centos:latest
ENV container docker
MAINTAINER "Reynier de la Rosa" <reynier.delarosa@overon.es>

RUN yum -y update
RUN yum -y groupinstall 'Development Tools'
RUN yum -y install epel-release \
                   wget \
		   openssl \
		   openssl-devel \
		   zlib-devel \
		   pcre-devel
RUN yum clean all 
RUN useradd builder 
RUN mkdir -p /opt/lib
RUN wget https://www.openssl.org/source/openssl-1.1.0c.tar.gz -O /opt/lib/openssl-1.1.0c.tar.gz
RUN tar -zxvf /opt/lib/open* -C /opt/lib
RUN rpm -ivh http://nginx.org/packages/mainline/centos/7/SRPMS/nginx-1.11.8-1.el7.ngx.src.rpm
RUN sed -i "s|--with-http_ssl_module|--with-http_ssl_module --with-openssl=/opt/lib/openssl-1.1.0c|g" /root/rpmbuild/SPECS/nginx.spec
RUN rpmbuild -ba --clean /root/rpmbuild/SPECS/nginx.spec
RUN rpm -Uvh --force /root/rpmbuild/RPMS/x86_64/nginx-1.11.8-1.el7.centos.ngx.x86_64.rpm

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
 
EXPOSE 80 443

ADD container-files/script/* /tmp/script/

# put customized config and code files to /data

ENTRYPOINT ["/tmp/script/bootstrap.sh"]
