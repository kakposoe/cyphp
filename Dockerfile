FROM php:7

# Run some Debian packages installation.
RUN apt-get update -y && apt-get install -y build-essential php7.0-sqlite openssl zip unzip git gnupg \
    libgtk2.0-0 \
    libnotify-dev \
    libgconf-2-4 \
    libnss3 \
    libxss1 \
    libasound2 \
    xvfb
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN docker-php-ext-install pdo mbstring

# Run xdebug installation. 
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install NodeJS and Cypress
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -yq nodejs
RUN node -v && \
    npm -v
RUN npm install --save-dev cypress
RUN $(npm bin)/cypress verify

WORKDIR /tmp

RUN composer selfupdate && \
    composer require "phpunit/phpunit:~4.8.3" --prefer-source --no-interaction && \
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit

# Set up the application directory.
VOLUME ["/app"]
WORKDIR /app

# Set up the command arguments.
ENTRYPOINT ["/usr/local/bin/phpunit"]
CMD ["--help"]
