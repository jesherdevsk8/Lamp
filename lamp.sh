#!/usr/bin/env bash

#############################################################
# Autor: Jesher Minelli Alves
# Automatiza Instalação do LAMP - Linux + Apache + PHP + MySQL/MariaDB
# ./lamp.sh
# Desde: Dom 01 Mai 2022 02:16:26 BRT
# Versão: 1
# Licença: GPLv3
# Testando no Debian

#################### VARIÁVEIS

lamp=(	
	apache2
	php
	libapache2-mod-php
	php-zip
	php-mbstring
	php-cli
	php-common
	php-curl
	php-xml
	php-mysql
	php-pear
	php-dev
	php-curl
	php-xmlrpc
	php-gd
	mariadb-server
	#phpmyadmin -> fazer iteração com usuario no final
)

 #############################################################
 #  Dependências do Apache2 e do PHP que Vão Ser Instaladas
 #  apache2 apache2-bin apache2-data apache2-utils
 #  libapache2-mod-php7.4 libapr1 libaprutil1
 #  libaprutil1-dbd-sqlite3 libaprutil1-ldap php-common php7.4
 #  php7.4-cli php7.4-common php7.4-json php7.4-opcache
 #  php7.4-readline apache2-doc apache2-suexec-pristine
 #############################################################


##### CORES
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'

##################### TESTES

# VALIDAR SE ESTÁ COMO ROOT

(($UID!=0)) && { echo -e "${VERMELHO}Precisa de Root!!!!${SEM_COR}"; exit 1 ; }
#[[ "$UID" -ne "0" ]] && { echo "Necessita de root"; exit 1 ;}

##################### FUNÇÕES

remover_locks () {
  echo -e "${VERDE}[INFO] - Removendo locks...${SEM_COR}"
  rm /var/lib/dpkg/lock-frontend &> /dev/null
  rm /var/cache/apt/archives/lock &> /dev/null
}

ATUALIZAR_REPO() {
  echo -e "${VERDE}[INFO] - Atualizando repositórios...${SEM_COR}"
  sudo apt update &> /dev/null
}

INSTALAR(){
	for programa in ${lamp[@]}; do
		if ! dpkg -l | grep -q $programa; then
			echo -e "${VERDE}[INFO] - Instalando o $programa...${SEM_COR}"
			apt install $programa -y &> /dev/null
		else
			echo -e "${VERDE}[INFO] - O pacote $programa já está instalado.${SEM_COR}"
		fi
	done
}

	# CONFIGURE 
	# sudo nano /etc/php/7.4/apache2/php.ini

RESTART_SERVICES(){
	/etc/init.d/apache2 restart
	systemctl enable apache2
	/etc/init.d/mariadb restart
	systemctl enable mariadb
}

CHECK_STATUS(){
	echo -e "${VERDE}Apache service is $(systemctl show -p ActiveState --value apache2)${SEM_COR}"
	echo -e "${VERDE}Maria DB service is $(systemctl show -p ActiveState --value mariadb)${SEM_COR}"
}

MARIADB_CONFIG(){
	# Configurar mariadb/mysql
	mysql_secure_installation
}

UPGRADE_LIMPA_SISTEMA(){
  echo -e "${VERDE}[INFO] - Fazendo upgrade e limpeza do sistema...${SEM_COR}"
  sudo apt upgrade -y &> /dev/null
  sudo apt autoclean &> /dev/null
  sudo apt autoremove -y &> /dev/null
}

###################### EXECUÇÃO

ATUALIZAR_REPO
INSTALAR
RESTART_SERVICES
CHECK_STATUS
#MARIADB_CONFIG -> Fazer interação com usuario no final
UPGRADE_LIMPA_SISTEMA


echo -e "${VERDE}LAMP Instalado com Sucesso!!!${SEM_COR}"
