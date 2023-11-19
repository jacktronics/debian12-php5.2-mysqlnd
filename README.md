<h1 align="center">
  Debian 12 (Bookworm) PHP 5.2.17 with support "mysqlnd"
</h1>

Modified to support Debian 12 from https://github.com/SIP-Online/debian9-php5.2-mysqlnd

## Installing required libraries
sudo apt-get install autoconf make binutils gcc dpkg-dev libtool libxml2-dev libxslt1-dev libcurl4-openssl-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libicu-dev libgd-dev libkrb5-dev libc-client2007e-dev libmcrypt-dev libmhash-dev<br />


## Building and Install
git clone "https://github.com/jacktronics/debian12-php5.2-mysqlnd.git"<br />
cd "debian12-php5.2-mysqlnd"<br />
chmod 0755 "configure.php5.2-Debian12.sh"<br />
./configure.php5.2-Debian12.sh
