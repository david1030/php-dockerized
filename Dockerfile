################################################################################
# Base image
# ׼����������ΪӦ�ó����ṩ������ 10M+ Nginx
################################################################################

FROM nginx

################################################################################
# Build instructions
# �����ܹ�
################################################################################

# Remove default nginx configs.
# Install packages
# Ϊ����װ�����
RUN rm -f /etc/nginx/conf.d/* \
# ��վ���Nginx����Ŀ¼
  && mkdir -p /run/php /run/hhvm \
  # �������½�����PHPĿ¼
  && apt-get update && apt-get upgrade -y && apt-get install -my \
    supervisor \
    # Linux supervisor��������ػ�
    curl \
    # Linux curl���ģ��post/get����
    wget \
    # Linux wget��������ļ��Ĺ���
    php-curl \
    php-fpm \
    php-gd \
    php-memcached \
    php-mysql \
    php-mcrypt \
    php-sqlite3 \
    php-xdebug \
    php-apcu
# �������ھ����а�װPHP��չ��

# Install HHVM
# �ھ����а�װPHP HHVM �����������л���
RUN echo "deb http://deb.debian.org/debian sid main" >> /etc/apt/sources.list \
# �� deb ����apt-get ��Դ��
    && apt-get update && apt-get install -y hhvm

# Ensure that PHP5 FPM is run as root.
# Pass all docker environment
# Get access to FPM-ping page /ping
# Get access to FPM_Status page /status
# Prevent PHP Warning: 'xdebug' already loaded.
# XDebug loaded with the core	# php7.0
# ����չ���������ã�Linux sed ���������ýű��������ı��ļ���������
RUN sed -i "s/user = www-data/user = root/" /etc/php/7.0/fpm/pool.d/www.conf \
    && sed -i "s/group = www-data/group = root/" /etc/php/7.0/fpm/pool.d/www.conf \
    && sed -i '/^;clear_env = no/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf \
    && sed -i '/^;ping\.path/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf \
    && sed -i '/^;pm\.status_path/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf \
    && sed -i '/.*xdebug.so$/s/^/;/' /etc/php/7.0/mods-available/xdebug.ini

# Add configuration files
# ���Ʊ����ļ� �� ����Ŀ¼��
COPY conf/nginx.conf /etc/nginx/
COPY conf/supervisord.conf /etc/supervisor/conf.d/
COPY conf/php.ini /etc/php/7.0/fpm/conf.d/40-custom.ini

################################################################################
# Volumes
# ����־û�Ŀ¼��1.����������֮�乲���ļ���2.����������һ��������Volume��
################################################################################

VOLUME ["/var/www", "/etc/nginx/conf.d"]

################################################################################
# Ports
# �򿪶˿ڣ�80/443/9000
# ��������鿴��netstat -antlp|grep LISTEN
################################################################################

EXPOSE 80 443 9000

################################################################################
# Entrypoint
# ����Supervisord��supervisord.conf�ļ�������Nginx
################################################################################

ENTRYPOINT ["/usr/bin/supervisord"]
