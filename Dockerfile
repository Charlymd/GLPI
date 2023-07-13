# Using a debian 12 image
FROM debian:12

# Update system packages
RUN apt-get update && apt-get upgrade -y

# Installation of dependencies required for GLPI
RUN apt-get install -y apache2 mariadb-client wget gnupg2  -y lsb-release apt-transport-https ca-certificates && \
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
# GPG key for PHP packages
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
# Installation PHP mods
apt-get update && \
apt-get install -y  php8.1 \
libapache2-mod-php8.1 \
php8.1-mysql \
php8.1-ldap \
php8.1-gd \
php8.1-curl \
php8.1-xml \
php8.1-mbstring \
php8.1-zip \
php8.1-bz2 \
php8.1-intl \
php8.1-apcu \
php8.1-cli \
php8.1-common \
php8.1-xmlrpc \
php8.1-soap \
php8.1-ldap \
php8.1-memcached

# Installation of GLPI
RUN wget -O glpi.tar.gz https://github.com/glpi-project/glpi/releases/download/10.0.9/glpi-10.0.9.tgz && \
tar xzf glpi.tar.gz -C /var/www/html/ && \
rm glpi.tar.gz 

# Installation of necessary  plugins
COPY ./plugins/. /var/www/html/glpi/plugins/

# Permission for HTML directory
RUN chown -R www-data:www-data /var/www/html/glpi && \
chmod -R 755 /var/www/html/glpi

# Configuration of Apache for GLPI
RUN a2enmod rewrite && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/glpi/' /etc/apache2/sites-available/000-default.conf && \
    echo "Alias /glpi /var/www/html/glpi" >> /etc/apache2/apache2.conf && \
    sed -i 's/Directory \/var\/www\/html/Directory \/var\/www\/html\/glpi/' /etc/apache2/apache2.conf

# Start Apach as main process
CMD ["apachectl", "-D", "FOREGROUND"]
