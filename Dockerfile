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
                   
RUN yum -y install freedts \
                   freetds-devel \
                   spawn-fcgi \
                   fcgi-devel \
                   perl \
                   perl-SOAP-Lite \
                   perl-Switch \
                   perl-DBI \
                   perl-Env \
                   perl-CGI-Session \
                   perl-Tie-IxHash \
                   perl-Crypt-CBC \
                   perl-Spreadsheet-WriteExcel \
                   perl-Excel-Writer-XLSX \
                   perl-Crypt-RC4
RUN yum clean all 
RUN useradd builder 
RUN mkdir -p /opt/lib
RUN wget https://www.openssl.org/source/openssl-1.1.1-pre3.tar.gz -O /opt/lib/openssl-1.1.1-pre3.tar.gz
RUN tar -zxvf /opt/lib/open* -C /opt/lib
RUN rpm -ivh http://nginx.org/packages/mainline/centos/7/SRPMS/nginx-1.13.10-1.el7_4.ngx.src.rpm
RUN sed -i "s|--with-http_ssl_module|--with-http_ssl_module --with-openssl=/opt/lib/openssl-1.1.1-pre3|g" /root/rpmbuild/SPECS/nginx.spec
RUN rpmbuild -ba --clean /root/rpmbuild/SPECS/nginx.spec
RUN rpm -Uvh --force /root/rpmbuild/RPMS/x86_64/nginx-1.13.10-1.el7_4.ngx.x86_64.rpm

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN wget https://driesrpms.eu/redhat/el7/en/x86_64/dries.all/RPMS/perl-Class-Multimethods-1.70-1.2.el7.rf.noarch.rpm
RUN wget https://driesrpms.eu/redhat/el7/en/x86_64/dries.all/RPMS/perl-Quantum-Superpositions-2.02-1.2.el7.rf.noarch.rpm
RUN wget https://www.dropbox.com/s/v0rsimkkuykik9l/perl-DBD-Sybase-1.16-1.el7.centos.x86_64.rpm 
RUN rpm -Uvh perl-Class-Multimethods-1.70-1.2.el7.rf.noarch.rpm
RUN rpm -Uvh perl-Quantum-Superpositions-2.02-1.2.el7.rf.noarch.rpm
RUN rpm -Uvh perl-DBD-Sybase-1.16-1.el7.centos.x86_64.rpm

RUN wget http://github.com/gnosek/fcgiwrap/tarball/master -O fcgiwrap.tar.gz
RUN tar zxvf fcgiwrap.tar.gz
RUN cd gnosek-fcgiwrap-99c942c && autoreconf -i && ./configure && make && make install 

RUN echo -e 'OPTIONS="-u nginx -g nginx -a 127.0.0.1 -p 9090 -P /var/run/spawn-fcgi.pid -- /usr/local/sbin/fcgiwrap"' >> /etc/sysconfig/spawn-fcgi
 
EXPOSE 80 443

ADD container-files/script/* /tmp/script/
RUN chmod +x /tmp/script/bootstrap.sh

# put customized config and code files to /data

ENTRYPOINT ["/tmp/script/bootstrap.sh"]
