#!/usr/bin/env bash
set -eo pipefail

#terminal colors
COLOR_NC=$(tput sgr0)
export COLOR_NC
COLOR_RED=$(tput setaf 1)
export COLOR_RED
COLOR_GREEN=$(tput setaf 2)
export COLOR_GREEN
COLOR_YELLOW=$(tput setaf 3)
export COLOR_YELLOW
COLOR_BLUE=$(tput setaf 4)
export COLOR_BLUE

#Globsal Variables
NAGIOSVER="nagios-4.4.6"
NAGIOSPLUGINS="2.3.3"



#******************
#  functions
#******************

# Check version of ubuntu and install deps

release_checker(){
  RELEASE=$(lsb_release -sr | cut -d "." -f 1)
}

install_dep(){
  if ("$RELEASE" = "18"); then
    sudo apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php7.2 libgd-dev  libmcrypt-dev libssl-dev  bc gawk dc build-essential snmp libnet-snmp-perl gettext
  elif ("$RELEASE" = "20"); then
   sudo apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php7.4 libgd-dev libmcrypt-dev  libssl-dev  bc gawk dc build-essential snmp libnet-snmp-perl gettext
  else
    echo -e "\n\n${COLOR_BLUE}No compatible Ubuntu found, currently only Ubuntu 18.* or Ubuntu 20.* is supported ${COLOR_NC}"
  fi
}





install_nagios_core(){
  cd /tmp
  wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/releases/download/${NAGIOSVER}/${NAGIOSVER}.tar.gz
  tar xzf nagioscore.tar.gz
  cd /tmp/nagioscore-${NAGIOSVER}/
sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled
sudo make all
}

install_nagios_plugins(){
  cd /tmp
  wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/releases/download/release-${NAGIOSPLUGINS}/nagios-plugins-${NAGIOSPLUGINS}.tar.gz
  tar zxf nagios-plugins.tar.gz
  cd /tmp/nagios-plugins-release-${NAGIOSPLUGINS}/
  sudo ./tools/setup
  sudo ./configure
  sudo make
  sudo make install
}

create_users_groups(){
  sudo make install-groups-users
  sudo usermod -a -G nagios www-data
}

# This step installs the binary files, CGIs, and HTML files.
install_binaries(){
  sudo make install

}
# This installs the service or daemon files and also configures them to start on boot.
install_init(){
  sudo make install-daemoninit
}

install_commandfile(){
  sudo make install-commandmode
}


apache_setup(){
  sudo make install-webconf
  sudo a2enmod rewrite
  sudo a2enmod cgi
}

create_nagios_user(){
  sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
}





#******************
# End of functions
#******************