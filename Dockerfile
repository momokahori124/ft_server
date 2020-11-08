FROM debian:buster

# autoindexを切り替えるための環境変数
ENV AUTOINDEX=on

# 必要なもののインストール
RUN apt-get update && apt-get install -y \
	wget \
	curl \
	nginx \
	php-fpm php-mbstring php-mysql php-gd php-xml \
	default-mysql-server default-mysql-client \
	supervisor \
#apt-getのcache削除
	&& rm -rf /var/lib/apt/lists/*

# nginx
COPY srcs/default /etc/nginx/sites-available/default
COPY srcs/autoindex.sh /tmp/
# オレオレ証明書
RUN mkdir /etc/nginx/ssl && cd /etc/nginx/ssl \
	&& openssl genrsa -out server.key 2048 \
	&& openssl req -new -key server.key -out server.csr \
	-subj '/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/OU=42Tokyo/CN=example.com' \
	&& openssl x509 -in server.csr -days 3650 -req -signkey server.key > server.crt

# mysql
COPY srcs/mysql_setup /tmp/
RUN service mysql start \
	&& mysql -u root < /tmp/mysql_setup \
	&& rm -f /tmp/mysql_setup

# wordpress
RUN curl https://ja.wordpress.org/latest-ja.tar.gz > /tmp/latest-ja.tar.gz \
	&& tar -xzf /tmp/latest-ja.tar.gz -C /var/www/html/ \
	&& rm -f /tmp/latest-ja.tar.gz
COPY srcs/wp-config.php /var/www/html/wordpress/

# phpmyadmin
RUN curl https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz > /tmp/phpmyadmin.tar.gz \
	&& tar -xzf /tmp/phpmyadmin.tar.gz -C /var/www/html/ \
	&& mv var/www/html/phpMyAdmin* /var/www/html/phpmyadmin \
	&& rm /tmp/phpmyadmin.tar.gz

# supervisord
COPY srcs/supervisord.conf /etc/supervisor/conf.d/

EXPOSE 80 443
ENTRYPOINT bash /tmp/autoindex.sh && supervisord