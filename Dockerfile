FROM centos:7
MAINTAINER yodaaut
ARG http_proxy
ENV container docker
ENV https_proxy ${https_proxy:-$http_proxy}
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
								systemd-tmpfiles-setup.service ] || rm -f $i; done);			\
		rm -f /lib/systemd/system/multi-user.target.wants/*;									\
		rm -f /etc/systemd/system/*.wants/*;																	\
		rm -f /lib/systemd/system/local-fs.target.wants/*;										\
		rm -f /lib/systemd/system/sockets.target.wants/*udev*;								\
		rm -f /lib/systemd/system/sockets.target.wants/*initctl*;							\
		rm -f /lib/systemd/system/basic.target.wants/*;												\
		rm -f /lib/systemd/system/anaconda.target.wants/*;

COPY etc/ /etc/
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7;	\
		update-ca-trust; \
		yum -y update	ca-certificates; \
		yum -y install \
			epel-release; \
		rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7; \
		yum -y install --enablerepo=epel \
			nginx \
			vim \
		; \
		yum clean all; \
		systemctl enable nginx.service
COPY app.conf /etc/nginx/sites-available/
RUN mkdir /etc/nginx/sites-enabled; \
		ln -s /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/app.conf
EXPOSE 80
CMD [ "/usr/sbin/init" ]

#BUILD-NOTE: 
#	docker build --rm --no-cache --build-arg http_proxy="http://USERNAME:PASSWORD@PROXYURL:PORT/" -t TAG .
#RUN-NOTE:
# docker run -d --privileged -v /PATH/TO/HTML:/var/www/app -p 80:80 TAG
