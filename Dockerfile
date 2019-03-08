FROM centos:latest
ENV container docker
MAINTAINER "Reynier de la Rosa" <reynier.delarosa@outlook.es>

RUN yum -y update
RUN yum -y groupinstall 'Development Tools'
RUN yum -y install epel-release \
                   wget \
                   openssl \
                   openssl-devel \
                   zlib-devel \
                   pcre-devel \
                   redhat-lsb-core
RUN yum clean all 
RUN useradd builder 
RUN mkdir -p /opt/lib
RUN wget https://www.openssl.org/source/openssl-1.1.1b.tar.gz -O /opt/lib/openssl-1.1.1b.tar.gz
RUN tar -zxvf /opt/lib/open* -C /opt/lib
RUN rpm -ivh http://nginx.org/packages/mainline/centos/7/SRPMS/nginx-1.15.9-1.el7_4.ngx.src.rpm
RUN sed -i "s|--with-http_ssl_module|--with-http_ssl_module --with-openssl=/opt/lib/openssl-1.1.1b|g" /root/rpmbuild/SPECS/nginx.spec
RUN rpmbuild -ba --clean /root/rpmbuild/SPECS/nginx.spec
RUN rpm -Uvh --force /root/rpmbuild/RPMS/x86_64/nginx-1.15.9-1.el7_4.ngx.x86_64.rpm

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
 
EXPOSE 80 443

ADD container-files/script/* /tmp/script/
RUN chmod +x /tmp/script/bootstrap.sh

# put customized config and code files to /data

ENTRYPOINT ["/tmp/script/bootstrap.sh"]
