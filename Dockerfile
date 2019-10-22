################################################################################
# Base image
# 准备基础镜像：为应用程序提供依赖包 10M+ Nginx
################################################################################

FROM nginx

################################################################################
# Build instructions
# 构建架构
################################################################################

# Remove default nginx configs.
# Install packages
# 为镜像安装软件包
RUN rm -f /etc/nginx/conf.d/* \
# 清空镜像Nginx配置目录
  && mkdir -p /run/php /run/hhvm \
  # 镜像中新建两个PHP目录
  && apt-get update && apt-get upgrade -y && apt-get install -my \
    supervisor \
    # Linux supervisor命令：进程守护
    curl \
    # Linux curl命令：模拟post/get请求
    wget \
    # Linux wget命令：下载文件的工具
    php-curl \
    php-fpm \
    php-gd \
    php-memcached \
    php-mysql \
    php-mcrypt \
    php-sqlite3 \
    php-xdebug \
    php-apcu
# 以上是在镜像中安装PHP扩展包

# Install HHVM
# 在镜像中安装PHP HHVM 公共语言运行环境
RUN echo "deb http://deb.debian.org/debian sid main" >> /etc/apt/sources.list \
# 将 deb 加入apt-get 资源组
    && apt-get update && apt-get install -y hhvm

# Ensure that PHP5 FPM is run as root.
# Pass all docker environment
# Get access to FPM-ping page /ping
# Get access to FPM_Status page /status
# Prevent PHP Warning: 'xdebug' already loaded.
# XDebug loaded with the core	# php7.0
# 各扩展包参数配置：Linux sed 命令是利用脚本来处理文本文件，镜像中
RUN sed -i "s/user = www-data/user = root/" /etc/php/7.0/fpm/pool.d/www.conf \
    && sed -i "s/group = www-data/group = root/" /etc/php/7.0/fpm/pool.d/www.conf \
    && sed -i '/^;clear_env = no/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf \
    && sed -i '/^;ping\.path/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf \
    && sed -i '/^;pm\.status_path/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf \
    && sed -i '/.*xdebug.so$/s/^/;/' /etc/php/7.0/mods-available/xdebug.ini

# Add configuration files
# 复制本地文件 到 镜像目录中
COPY conf/nginx.conf /etc/nginx/
COPY conf/supervisord.conf /etc/supervisor/conf.d/
COPY conf/php.ini /etc/php/7.0/fpm/conf.d/40-custom.ini

################################################################################
# Volumes
# 镜像持久化目录：1.主机和容器之间共享文件；2.容器访问另一个容器的Volume；
################################################################################

VOLUME ["/var/www", "/etc/nginx/conf.d"]

################################################################################
# Ports
# 打开端口：80/443/9000
# 主机命令查看：netstat -antlp|grep LISTEN
################################################################################

EXPOSE 80 443 9000

################################################################################
# Entrypoint
# 开启Supervisord：supervisord.conf文件中启动Nginx
################################################################################

ENTRYPOINT ["/usr/bin/supervisord"]
