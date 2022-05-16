#!/usr/bin/env bash

#############################################################
# Autor: Jesher Minelli Alves
# Automatiza Instalação do LAMP - Linux + Apache + MySQL/MariaDB + PHP
# ./lamp.sh
# Desde: Dom 01 Mai 2022 02:16:26 BRT
# Versão: 1
# Licença: GPLv3
# Testando no Debian

#################### VARIÁVEIS

lamp_server=(
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
	phpmyadmin
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

# Internet conectada?
if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
  echo -e "${VERMELHO}Seu computador não tem conexão com a Internet. Verifique os cabos e o modem.${SEM_COR}"
  exit 1
else
  echo -e "${VERDE}[INFO] - Conexão com a Internet funcionando normalmente.${SEM_COR}"
fi

# VALIDAR SE ESTÁ COMO ROOT
(($UID!=0)) && { echo -e "${VERMELHO}Precisa de Root!!!!${SEM_COR}"; exit 1 ; }

##################### FUNÇÕES

REMOVER_LOCKS() {
  echo -e "${VERDE}[INFO] - Removendo locks...${SEM_COR}"
  rm /var/lib/dpkg/lock-frontend &> /dev/null
  rm /var/cache/apt/archives/lock &> /dev/null
}

ATUALIZAR_REPO() {
  echo -e "${VERDE}[INFO] - Atualizando repositórios...${SEM_COR}"
  sudo apt update &> /dev/null
}

INSTALAR(){
	for programa in ${lamp_server[@]}; do
		if ! dpkg -l | grep -q $programa; then
			echo -e "${VERDE}[INFO] - Instalando o $programa...${SEM_COR}"
			apt install $programa -y &> /dev/null
		else
			echo -e "${VERDE}[INFO] - O pacote $programa já está instalado.${SEM_COR}"
		fi
	done
}

RESTART_SERVICES() {
	echo -e "${VERDE}[INFO] - Restartando serviços.....${SEM_COR}"
  /etc/init.d/apache2 restart &> /dev/null
  systemctl enable apache2 &> /dev/null
  /etc/init.d/mariadb restart &> /dev/null
  systemctl enable mariadb &> /dev/null
}

CHECK_STATUS() {
	echo -e "${VERDE}Apache service is $(systemctl show -p ActiveState --value apache2)${SEM_COR}"
	echo -e "${VERDE}Maria DB service is $(systemctl show -p ActiveState --value mariadb)${SEM_COR}"
}

MARIADB_CONFIG() {
	# Configure mariadb/mysql com atenção
	mysql_secure_installation
}

UPGRADE_LIMPA_SISTEMA() {
  echo -e "${VERDE}[INFO] - Fazendo upgrade e limpeza do sistema...${SEM_COR}"
  sudo apt upgrade -y &> /dev/null
  sudo apt autoclean &> /dev/null
  sudo apt autoremove -y &> /dev/null
}

###################### EXECUÇÃO

#chamando funções
ATUALIZAR_REPO
INSTALAR
RESTART_SERVICES
CHECK_STATUS
MARIADB_CONFIG
UPGRADE_LIMPA_SISTEMA


echo -e "${VERDE}LAMP Instalado com Sucesso!!!${SEM_COR}"
