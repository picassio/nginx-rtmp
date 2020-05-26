FROM centos:7 as builder

RUN yum install -y git wget make cmake pcre-devel gcc gcc++ openssl-devel unzip

FROM builder as builder-nginx

ENV NGINX_VERSION nginx-1.18.0
RUN     mkdir -p /opt/123host/builder \
	/opt/123host/livestream

WORKDIR /opt/123host/builder

RUN	 wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
	tar zxvf ${NGINX_VERSION}.tar.gz

WORKDIR /opt/123host/builder/${NGINX_VERSION}

RUN 	wget https://github.com/arut/nginx-rtmp-module/archive/master.zip &&\
	unzip master.zip &&\
	./configure --prefix=/opt/123host/livestream --with-http_ssl_module --add-module=./nginx-rtmp-module-master &&\
	make && make install

FROM centos:7

RUN 	mkdir -p /opt/123host/livestream /home/HLS/live /home/HLS/mobile /home/video_recordings &&\
	groupadd -g 1000 nginx && useradd -M -u 1000 -g nginx -s /sbin/nologin nginx

COPY --from=builder-nginx /opt/123host/livestream /opt/123host/livestream

RUN ln -s /opt/123host/livestream/sbin/nginx /usr/local/bin/nginx

WORKDIR /opt/123host/livestream/conf

ADD ./nginx.conf nginx.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]






