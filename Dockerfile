FROM php:8.3-apache

ENV COMPOSER_ALLOW_SUPERUSER=1

SHELL ["/bin/bash", "-eux", "-o", "pipefail", "-c"]

# ----------------------------------------------
# Dependencies
# ----------------------------------------------
RUN apt-get update && apt-get upgrade -y 


RUN apt-get install -y \
  libicu-dev \
  libpq-dev \
  libzip-dev \
  zip \
  gnupg \
  unzip \
  git \
  curl \
  vim \
  && docker-php-ext-install \
  intl \
  pdo \
  pdo_pgsql \
  pdo_mysql \
  pgsql \
  zip \
  && docker-php-ext-enable \
  pdo_pgsql \
  pdo_mysql \
  && a2enmod rewrite \
  && service apache2 restart

# ----------------------------------------------
# Composer
# ----------------------------------------------
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

# ----------------------------------------------
# Opache
# ----------------------------------------------
RUN docker-php-ext-install -j$(nproc) opcache pdo_mysql

#--------------------------------------------------------------------------------
# Node.js with nvm
#--------------------------------------------------------------------------------
ENV NVM_DIR /usr/local/nvm
RUN mkdir -p /usr/local/nvm
ENV NODE_VERSION 18.17.1

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash \
  && source $NVM_DIR/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN command -v node
RUN command -v npm


#--------------------------------------------------------------------------------
# Creating non root user
# @see http://www.projectatomic.io/docs/docker-image-author-guidance/
#--------------------------------------------------------------------------------
# RUN useradd -ms /bin/bash php83
# RUN usermod -aG sudo php83
RUN chmod 777 -R /var/log
RUN chmod 777 -R /var/run

ARG UID
ARG GID

# Créer le groupe avec le GID
RUN groupadd -g ${GID} phpgroup

# Créer l'utilisateur avec le bon UID et GID
RUN useradd -u ${UID} -g phpgroup -ms /bin/bash php83

# Donner les permissions au nouvel utilisateur pour /var/www/html
RUN chown -R php83:phpgroup /var/www/html


RUN a2enmod rewrite remoteip 
# COPY docker_conf/vhost.conf /etc/apache2/sites-enabled/000-default.conf
COPY docker_conf/apache/vhost.conf /etc/apache2/sites-available/000-default.conf
# COPY docker_conf/apache.conf /etc/apache2/apache2.conf

# RUN chown -R php83:php83 /var/www/html

#--------------------------------------------------------------------------------
# Define user 
#--------------------------------------------------------------------------------
USER php83

SHELL ["/bin/sh", "-c"]
