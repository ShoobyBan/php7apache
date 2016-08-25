FROM php:7.0-apache
MAINTAINER Sam Ban <sam.ban@wizguild.com>

ADD https://raw.githubusercontent.com/colinmollenhour/credis/master/Client.php /credis.php
ADD opcache.ini /usr/local/etc/php/conf.d/999-opcache.ini
ADD register-host-on-redis.php /register-host-on-redis.php
ADD unregister-host-on-redis.php /unregister-host-on-redis.php
ADD crontab /crontab.www-data
ADD start.sh /start.sh
ADD https://raw.githubusercontent.com/nexcess/magento-turpentine/master/app/code/community/Nexcessnet/Turpentine/Model/Varnish/Admin/Socket.php /varnish.php
ADD updatenodes.php /updatenodes.php

RUN \
    apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libxslt1-dev \
    curl \
    libcurl4-gnutls-dev \
    git \
    vim \
    wget \
    psmisc \
    cachefilesd \
    cron \
    rsyslog && \
    apt-get clean && \
    crontab -u www-data /crontab.www-data && \
    chmod +x /start.sh && \
    chmod +r /varnish.php && \
    touch /var/log/syslog && \
    touch /var/log/cron.log && \
    rm /register-host-on-redis.php && \
    rm /unregister-host-on-redis.php

RUN docker-php-ext-configure \
    gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; \
    docker-php-ext-install \
    gd \
    intl \
    mbstring \
    mcrypt \
    pdo_mysql \
    xsl \
    zip \
    opcache \
    curl \
    mysqli \
    json \
    bcmath
    
RUN \
#    echo "date.timezone = Europe/London" >> /etc/php/7.0/cli/php.ini && \
    echo -e "RUN=yes" | tee -a /etc/default/cachefilesd && \
    git config --global core.preloadindex true && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm && \
    npm install -g grunt-cli && \
    npm install -g bower && \
    echo "Host is ready"

RUN usermod -u 1000 www-data; \
  a2enmod rewrite; \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
  curl -o n98-magerun2.phar http://files.magerun.net/n98-magerun2-latest.phar; \
  chmod +x ./n98-magerun2.phar; \
  chmod +x /start.sh; \
  chmod +r /credis.php; \
  mv n98-magerun2.phar /usr/local/bin/; \
  mkdir -p /root/.composer

VOLUME /var/www/html

CMD ["/start.sh"]
