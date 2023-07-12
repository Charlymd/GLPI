# Utilisation d'une image de base Debian 
FROM debian:latest

# Mis à jour des paquets du système
RUN apt-get update && apt-get upgrade -y

# Installation des dépendances nécessaires pour GLPI
RUN apt-get install -y apache2 mariadb-client wget gnupg2 && \
apt-get install -y lsb-release apt-transport-https ca-certificates && \
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated php8.1 \
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

# Téléchargement de la dernière version de GLPI depuis le site officiel
RUN wget -O glpi.tar.gz https://github.com/glpi-project/glpi/releases/download/10.0.9/glpi-10.0.9.tgz && \
tar xzf glpi.tar.gz && \
rm glpi.tar.gz && \
mv glpi /var/www/html && \
chown -R www-data:www-data /var/www/html/glpi && \
chmod -R 755 /var/www/html/glpi

#Installation des plugins
COPY ./plugins/. /var/www/html/glpi/plugins/

# Configuration d'Apache pour servir GLPI
RUN a2enmod rewrite && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/glpi/' /etc/apache2/sites-available/000-default.conf && \
    echo "Alias /glpi /var/www/html/glpi" >> /etc/apache2/apache2.conf && \
    sed -i 's/Directory \/var\/www\/html/Directory \/var\/www\/html\/glpi/' /etc/apache2/apache2.conf

# Démarrage d'Apache en tant que processus principal
CMD ["apachectl", "-D", "FOREGROUND"]
