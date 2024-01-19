FROM php:8.2-fpm

# set main params
ARG BUILD_ARGUMENT_ENV=default
ENV ENV=$BUILD_ARGUMENT_ENV
ENV APP_HOME /var/www/html
ARG HOST_UID=1000
ARG HOST_GID=1000
ENV USERNAME=www-data
ARG XDEBUG_CONFIG=main
ENV XDEBUG_CONFIG=$XDEBUG_CONFIG


# check environment
RUN if [ "$BUILD_ARGUMENT_ENV" = "default" ]; then echo "Set BUILD_ARGUMENT_ENV in docker build-args like --build-arg BUILD_ARGUMENT_ENV=dev" && exit 2; \
    elif [ "$BUILD_ARGUMENT_ENV" = "dev" ]; then echo "Building development environment."; \
    elif [ "$BUILD_ARGUMENT_ENV" = "test" ]; then echo "Building test environment."; \
    elif [ "$BUILD_ARGUMENT_ENV" = "staging" ]; then echo "Building staging environment."; \
    elif [ "$BUILD_ARGUMENT_ENV" = "prod" ]; then echo "Building production environment."; \
    else echo "Set correct BUILD_ARGUMENT_ENV in docker build-args like --build-arg BUILD_ARGUMENT_ENV=dev. Available choices are dev,test,staging,prod." && exit 2; \
    fi

# change debian source
RUN sed -i 's#http://deb.debian.org#https://mirrors.aliyun.com#g' /etc/apt/sources.list.d/debian.sources

# redis
RUN mkdir -p /usr/src/php/ext/redis; \
      curl -fsSL https://pecl.php.net/get/redis --ipv4 | tar xvz -C "/usr/src/php/ext/redis" --strip 1;

# xdebug for dev and test env
COPY ./dev/xdebug-${XDEBUG_CONFIG}.ini /tmp/xdebug.ini
RUN if [ "$ENV" = "dev" ] || [ "$ENV" = "test" ]; then mkdir -p /usr/src/php/ext/xdebug; \
      curl -fsSL https://pecl.php.net/get/xdebug --ipv4 | tar xvz -C "/usr/src/php/ext/xdebug" --strip 1; \
      mv /tmp/xdebug.ini /usr/local/etc/php/conf.d/; \
    else rm /tmp/xdebug.ini; \
    fi

# install all the dependencies and enable PHP modules
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
      procps \
      nano \
      git \
      unzip \
      libicu-dev \
      zlib1g-dev \
      libxml2 \
      libxml2-dev \
      libreadline-dev \
      supervisor \
      cron \
      sudo \
      libzip-dev \
      libfreetype-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install \
      pdo_mysql \
      sockets \
      intl \
      opcache \
      zip \
      gd \
      redis \
      pcntl
RUN if [ "$ENV" = "dev" ] || [ "$ENV" = "test" ]; then docker-php-ext-install xdebug; \
    fi
RUN rm -rf /tmp/* \
    && rm -rf /var/list/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# create document root, fix permissions for www-data user and change owner to www-data
RUN mkdir -p $APP_HOME/public && \
    mkdir -p /home/$USERNAME && chown $USERNAME:$USERNAME /home/$USERNAME \
    && usermod -o -u $HOST_UID $USERNAME -d /home/$USERNAME \
    && groupmod -o -g $HOST_GID $USERNAME \
    && chown -R ${USERNAME}:${USERNAME} $APP_HOME

# put php config for Laravel
COPY ./$ENV/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./$ENV/php.ini /usr/local/etc/php/php.ini

# install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# add supervisor
RUN mkdir -p /var/log/supervisor
COPY --chown=root:root ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chown=root:crontab ./cron /var/spool/cron/crontabs/root
RUN chmod 0600 /var/spool/cron/crontabs/root

# # set working directory
WORKDIR $APP_HOME

# USER ${USERNAME}

# # copy source files and config file
# COPY --chown=${USERNAME}:${USERNAME} ./laravel/ $APP_HOME/

# # change permission
RUN chown -R ${USERNAME}:${USERNAME} $APP_HOME

# # install all PHP dependencies
# RUN if [ "$BUILD_ARGUMENT_ENV" = "dev" ] || [ "$BUILD_ARGUMENT_ENV" = "test" ]; then COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader --no-interaction --no-progress; \
#     else COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader --no-interaction --no-progress --no-dev; \
#     fi

# USER root
