FROM ubuntu:bionic

# Install packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    curl \
    gettext-base \
    git \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libssh2-1-dev \
    libssl-dev \
    libzip-dev \
    nodejs \
    npm \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install sass css
RUN npm install -g sass

# Install terser for js minification
RUN npm install -g terser

# Enable php extensions
RUN pecl install igbinary \
    && pecl install ssh2-1.2 \
    && docker-php-ext-enable igbinary ssh2

# Install PHP Extensions
RUN docker-php-ext-install \
    gd \
    gettext \
    opcache \
    pcntl \
    pdo \
    pdo_mysql \
    sockets \
    zip

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/CN=ubuntu.test.net"

# Enable apache features
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2ensite default-ssl
RUN a2enmod ssl


#ENTRYPOINT ["/wobo-app-hooks.d/app-bootstrap.sh"]

#CMD ["sh", "-c", "cron && apache2-foreground"]

