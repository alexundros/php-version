#!/usr/bin/env bash

if [ $BASH_VERSION ] ; then
  echo "BASH: $BASH_VERSION"
else
  echo 'Must be run BASH!'
  exit 1
fi
if [ $EUID -ne 0 ]; then
  echo 'Must be run as root!'
  exit 2
fi

readonly ERR_FN=3
readonly ERR_PR=4 
readonly DIR=$(pwd)
readonly PHP_DIR='/opt/php'
readonly SRC_DIR=$PHP_DIR'/src'
readonly BZ_DIR=$SRC_DIR'/bzips'
mkdir $PHP_DIR > /dev/null 2>&1
mkdir $SRC_DIR > /dev/null 2>&1
mkdir $BZ_DIR > /dev/null 2>&1
source functions

echo 'Enter PHP version/versions, (Default: [5.6.30])'
echo 'Example: [5.6.30] or [5.6.30 7.0.17 7.1.3]'
read -p ">" VERS
VERS=${VERS:-'5.6.30'}

echo 'Install packages and dependencies?(y/Y)'
read -p ">" K
if [ "$K" == 'y' ]||[ "$K" == 'Y' ]; then
  echo 'Start the installation of packages and dependencies. Please wait...';
  apt-get install make autoconf automake libtool gcc pkg-config dpkg-dev build-essential  \
  checkinstall fakeroot curl wget bison bzip2 libbz2-dev libxml2 libxml2-dev libssl-dev \
  libcurl4-openssl-dev libpcre3-dev libpcre++-dev libjpeg-dev libpng-dev libxpm-dev \
  libfreetype6-dev libmysqlclient-dev libgmp-dev libgmp3-dev \
  libsnmp-dev libtidy-dev libxslt1-dev libmcrypt-dev libpspell-dev -y
fi

for ver in $VERS; do
  echo 'Iinstall PHP '$ver
  src=$SRC_DIR'/php-'$ver
  dst=$PHP_DIR'/php-'$ver
  file=$BZ_DIR'/php-'$ver'.tar.bz2'
  if ! [ -d $src ]; then
    if ! [ -f $file ]; then
      GET_PHP $ver $file
    fi
    tar xjf $file -C $SRC_DIR
    if ! [ $? -eq 0 ] ; then
      echo 'TAR Error'
      exit $ERR_PR
    fi
  fi
  if ! [ -d $dst ]; then
    MAKE_PHP $ver $src $dst
  fi
  cd $DIR
  echo 'PHP ver. '$ver' installed'
  echo 'Installed in path: '$dst
done

exit 0