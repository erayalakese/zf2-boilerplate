#!/bin/bash

printf "##### This script 'boils' zf2-boilerplate for you #####\n"
read -p "### First of all I'll install composer dependencies. Press ENTER when you are ready. This command will be executed : 'php composer.phar install'"
php composer.phar install
if [ $? -ne 0 ]; then
    echo "'php composer.phar install' command failed. Did you install php package?"
    exit;
fi
printf "### Composer dependencies installed. Now I'll install javascript / less task by using bower and grunt.\n"

## Checks if npm installed
## Using `command` instead of `which`, http://stackoverflow.com/a/677212/556169
command -v npm >/dev/null 2>&1 || { echo >&2 "npm is not installed on the system. Please check your NodeJS installation. Aborting."; exit; }

## Checks if bower installed, if not installs it
command -v bower >/dev/null 2>&1 || { echo >&2 "bower is not installed on the system."; read -p "I will install bower. Do you want to continue? This command will be executed : 'npm install -g bower' [y / n] ";
if [[ $REPLY =~ ^[Yy]$ ]]
then
    npm install -g bower;
else
		exit;
fi
}

## Checks if grunt-cli installed, if not installs it
command -v grunt >/dev/null 2>&1 || { echo >&2 "grunt-cli is not installed on the system."; read -p "I will install grunt-cli. Do you want to continue? This command will be executed : 'npm install -g grunt-cli' [y / n] ";
if [[ $REPLY =~ ^[Yy]$ ]]
then
    npm install -g grunt-cli;
else
		exit;
fi
}

## Install bower & grunt tasks
bower install && npm install;
if [ $? -ne 0 ]; then
    echo "'bower install && npm install' command failed. Did you install bower and npm?"
    exit;
fi

## grunt dev
grunt dev;
if [ $? -ne 0 ]; then
    echo "'grunt dev' command failed. Did you install grunt?"
    exit;
fi

printf "## Now all required files/folders created.\nIt's time to system setup\n";

## env. var. set up
read -p "## I will define APPLICATION_ENV=development environment variable for your computer. This command will be executed: 'echo \"export APPLICATION_ENV=development\" >> ~/.bashrc && source ~/.bashrc' . Type y if you want to do it, type n if you want to skip this step. [y / n] ";
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "export APPLICATION_ENV=development" >> ~/.bashrc
		source ~/.bashrc
fi

## Append hosts file
## TODO : Ask for domain
printf "Now I'll append this line to your /etc/hosts file.\n\n127.0.0.1 www.boilerplate.local admin.boilerplate.local api.boilerplate.local\n\n";
read -p "y for continue, n if you want to do it manually [y / n]";
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "127.0.0.1 www.boilerplate.local admin.boilerplate.local api.boilerplate.local" >> /etc/hosts
fi

## Database Setup
echo "### DATABASE SETUP";
`cp config/autoload/doctrine.local.{php.dist,php}`
echo "## By default, ZF2 boilerplate ships with an example PDO PostgreSQL configuration in doctrine.local.php. Now I'll open this file with your editor, so you can configure your DBMS connection.";
printf "## If you prefer switch to other DBMS, just replace the driverClass to :\n
Doctrine\DBAL\Driver\PDOPgSql\Driver for PostgreSQL\n
Doctrine\DBAL\Driver\PDOMySql\Driver for MySQL\n
Doctrine\DBAL\Driver\PDOSqlite\Driver for SQLite (Note: Folder and .db file should be writable via php server.)\n
Replace the @dbuser, @dbpass and @dbname in doctrine.local.php file with yours.\nDon't worry, you will create database at next step.\n";
read -p "Press ENTER if you ready";
"${EDITOR:-vi}" config/autoload/doctrine.local.php

printf "Now I'll create a database for zend boilerplate\n";
eval php public/index.php orm:schema-tool:create
eval php public/index.php data-fixture:import
