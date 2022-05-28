sudo dnf module install -y php:7.4
sudo dnf install -y nginx php-pdo php-gd php-zip php-intl php-mysqlnd
sudo dnf install -y mysql-common
sudo dnf install -y git

sudo mkdir /var/www/html/bagisto
sudo chown ec2-user:ec2-user /var/www/html/bagisto
sudo chmod 0600 /tmp/config_files/id_ed25519
eval $(ssh-agent -s)
ssh-add /tmp/config_files/id_ed25519
ssh-keygen -F github.com || ssh-keyscan github.com >> ~/.ssh/known_hosts
git clone git@github.com:SpotOnDev/bagisto_test.git /var/www/html/bagisto
sudo mkdir /etc/nginx/sites-available
sudo mkdir /etc/nginx/sites-enabled
sudo cp /tmp/config_files/www.conf /etc/php-fpm.d/www.conf
sudo cp /tmp/config_files/nginx.conf /etc/nginx/nginx.conf
sudo chown root:root /etc/nginx/nginx.conf
sudo chown root:root /etc/php-fpm.d/www.conf
sudo cp /tmp/config_files/.env /var/www/html/bagisto/.env
sudo cp /tmp/config_files/bagisto-test.com.conf /etc/nginx/sites-available/bagisto-test.com.conf
sudo ln -s /etc/nginx/sites-available/bagisto-test.com.conf /etc/nginx/sites-enabled/
sudo chown root:root /etc/nginx/sites-available/bagisto-test.com.conf

sudo setsebool -P httpd_unified 1
sudo setsebool -P httpd_can_network_connect_db 1
sudo systemctl enable --now php-fpm
sudo systemctl enable --now nginx

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

cd /var/www/html/bagisto
composer update
php artisan vendor:publish --all
sudo chown -R nginx:nginx /var/www/html/bagisto
sudo systemctl restart nginx
