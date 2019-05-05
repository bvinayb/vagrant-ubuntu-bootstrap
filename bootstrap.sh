#!/usr/bin/env bash

Update () {
    echo "-- Update packages --"
    sudo apt-get update
    sudo apt-get upgrade
}
Update

echo "-- Prepare configuration for MySQL --"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

echo "-- Install tools and helpers --"
sudo apt-get install -y --force-yes python-software-properties vim htop curl git npm build-essential libssl-dev

echo "-- Install PPA's --"
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:chris-lea/redis-server
Update

echo "-- Install NodeJS --"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

echo "-- Install packages --"
sudo apt-get install -y --force-yes apache2 mysql-server-5.7 git-core nodejs rabbitmq-server redis-server
sudo apt-get install -y --force-yes php7.1-common php7.1-dev php7.1-json php7.1-opcache php7.1-cli libapache2-mod-php7.1
sudo apt-get install -y --force-yes php7.1 php7.1-mysql php7.1-fpm php7.1-curl php7.1-gd php7.1-mcrypt php7.1-mbstring
sudo apt-get install -y --force-yes php7.1-bcmath php7.1-zip
Update

echo "-- Configure PHP &Apache --"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/apache2/php.ini
sudo a2enmod rewrite

#echo "-- Creating App and WP Directories  --"
#dirname = "/vagrant/public/app"
#read -p "Enter Directory Name: " dirname
#if [[ ! -d "$dirname" ]]
#then
#        if [[ ! -L ${dirname} ]]
#        then
#                echo "Directory doesn't exist. Creating now"
#                mkdir ${dirname}
#                echo "Directory created"
#        else
#                echo "Directory exists"
#        fi
#fi
#
#directory_name = "/vagrant/public/wpsite"
#
#if [ -d ${directory_name} ]
#then
#    echo "Directory already exists"
#else
#    mkdir ${directory_name}
#fi

echo "-- Creating virtual hosts --"
sudo ln -fs /vagrant/public/app/ /var/www/app
sudo ln -fs /vagrant/public/wpsite/ /var/www/wpsite
cat << EOF | sudo tee -a /etc/apache2/sites-available/default.conf
<Directory "/var/www/">
    AllowOverride All
</Directory>

<VirtualHost *:80>
    DocumentRoot /var/www/app
    ServerName appsbrewhouse.localdev
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot /var/www/phpmyadmin
    ServerName appsbrewhouse.phpmyadmin.localdev
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot /var/www/wpsite
    ServerName appsbrewhouse.wpsite.localdev
</VirtualHost>
EOF
sudo a2ensite default.conf

echo "-- Restart Apache --"
sudo /etc/init.d/apache2 restart

echo "-- Install Composer --"
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

echo "-- Install phpMyAdmin --"
wget -k https://files.phpmyadmin.net/phpMyAdmin/4.8.0.1/phpMyAdmin-4.8.0.1-english.tar.gz
sudo tar -xzvf phpMyAdmin-4.8.0.1-english.tar.gz -C /var/www/
sudo rm phpMyAdmin-4.8.0.1-english.tar.gz
sudo mv /var/www/phpMyAdmin-4.8.0.1-english/ /var/www/phpmyadmin

echo "-- Setup databases --"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS my_site_build";


echo "---------------------"
echo "Machine for Dev WordPress Project(s)"
echo "---------------------"
cd /vagrant/public/wpsite
echo "Installing WordPress"
wget http://WordPress.org/latest.tar.gz
tar -xzvf latest.tar.gz

echo "---------------------"
echo "----- Moving Wordpress files -------"
SOURCE="/vagrant/public/wpsite/wordpress"
DESTINATION="/vagrant/public/wpsite"

cp -r "$SOURCE/"* "$DESTINATION/"
echo "----- Wordpress files transfer completed -------"

echo "---------------------"
echo "----- Deleting tar-GZ folder and files  -------"
rm -rf "/vagrant/public/wpsite/wordpress/"
file="/vagrant/public/wpsite/latest.tar.gz"

if [ -f $file ] ; then
    rm $file
fi

#setting up mysql database, and user to use with WordPress
echo "---------------------"
echo "Setting up database for WordPress"
echo "---------------------"
echo "Setting up MySQL Database"
echo "CREATE USER IF NOT EXISTS 'vagrantwp'@'localhost' IDENTIFIED BY 'verystrongpassword'" | mysql -uroot -proot
echo "CREATE DATABASE IF NOT EXISTS  wpsite" | mysql -uroot -proot
echo "GRANT ALL ON vagrantwp.* TO 'wpsite'@'localhost'" | mysql -uroot -proot
echo "FLUSH PRIVILEGES" | mysql -uroot -proot
#enable mod_rewrite and restart apache
sudo a2enmod rewrite
sudo service apache2 restart
echo "---------------------"
echo "WordPress dev environment all ready to go."
echo "---------------------"