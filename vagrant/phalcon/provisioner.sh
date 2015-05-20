#!/bin/bash
#
# Vagrant Provisionner for PHP Dev
#   - Apache
#   - MySQL
#   - PHP-fpm
#
# @author   Akarun for KRKN <akarun@krkn.be> and Passtech <akarun@passtech.be>
# @since    August 2014
#
# =============================================================================

PROJECT_NAME=$( echo $1 | sed -e 's/[A-Z]/\L&/g;s/ /_/g')
PROJECT_HOST=$2
PROJECT_ROOT=$3
PRIVATE_IP=$4

LOG_FILE="/vagrant/.vagrant/deploy.log"
DB_ROOT_PASS="vagrant"
DB_DUMP_FILE="/vagrant/.vagrant/dump.sql"

# =============================================================================

CLL="\r$(printf '%*s\n' 80)\r"
SEP="\r$(printf '%0.1s' "-"{1..80})"

function echo_line    { echo -en "${CLL}$*\n"; }
function echo_success { echo -en "${CLL}$*\033[69G\033[0;39m[   \033[1;32mOK\033[0;39m    ]\n"; }
function echo_failure { echo -en "${CLL}$*\033[69G\033[0;39m[ \033[1;31mFAILED\033[0;39m  ]\n"; }
function echo_warning { echo -en "${CLL}$*\033[69G\033[0;39m[ \033[1;33mWARNING\033[0;39m ]\n"; }
function echo_done    { echo -en "${CLL}$*\033[69G\033[0;39m[  \033[1;34mDONE\033[0;39m   ]\n"; }

# -----------------------------------------------------------------------------

GIT_REPO="git://github.com/phalcon/cphalcon.git"

echo_line "CPhalcon"
SLINE="\t- Phalcon Requirements"
sudo apt-get -y install php5-dev libpcre3-dev gcc make php5-mysql >>$LOG_FILE 2>&1 && echo_success $SLINE || echo_failure $SLINE &&

SLINE="\t- Cloning cphalcon git repo"
git clone --depth=1 $GIT_REPO >>$LOG_FILE 2>&1 && echo_success $SLINE || echo_failure $SLINE &&
cd cphalcon/build

SLINE="\t- Build cphalcon"
sudo ./install >>$LOG_FILE 2>&1 && echo_success $SLINE || echo_failure $SLINE &&

SLINE="\t- Adding extension"
echo "extension=phalcon.so" >> /etc/php5/apache2/php.ini >>$LOG_FILE 2>&1
cat /vagrant/vagrant/phalcon/phalcon.ini >> /etc/php5/mods-available/phalcon.ini && >>$LOG_FILE 2>&1 && echo_success $SLINE || echo_failure $SLINE &&

sudo ln -s /etc/php5/mods-available/phalcon.ini /etc/php5/apache/conf.d/phalcon.ini >>$LOG_FILE 2>&1
sudo ln -s /etc/php5/mods-available/phalcon.ini /etc/php5/cli/conf.d/phalcon.ini >>$LOG_FILE 2>&1
sudo ln -s /etc/php5/mods-available/phalcon.ini /etc/php5/fpm/conf.d/phalcon.ini >>$LOG_FILE 2>&1

SLINE="\t- Restart server"
service apache2 restart >>$LOG_FILE 2>&1 &&
echo_done "\t- Phalcon installed and server restarted"

