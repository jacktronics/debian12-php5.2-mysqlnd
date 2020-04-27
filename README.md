<h1 align="center">
  Debian 9 (Stretch) PHP 5.2.17 with support "mysqlnd"
</h1>

## Installing required libraries
sudo apt-get install libxml2-dev libxslt1-dev libcurl4-openssl-dev libjpeg62-turbo-dev libpng-dev libxpm-dev \\<br />
libicu-dev libgd-dev libkrb5-dev libc-client2007e-dev libmcrypt-dev libmhash-dev

## Building and Install
git clone "https://github.com/SIP-Online/debian9-php5.2-mysqlnd.git"<br />
cd "debian9-php5.2-mysqlnd"<br />
chmod 0755 "configure.php5.2-Debian9.sh"<br />
./configure.php5.2-Debian9.sh
