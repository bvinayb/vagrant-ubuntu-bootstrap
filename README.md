# Vagrant PHP7 

A simple Vagrant LAMP setup with PHP 7.1 running on Ubuntu 18.04 LTS.

## What's inside?

- Ubuntu 18.04 LTS (bento)
- Vim, Git, Curl, etc.
- Apache
- PHP 7.1 with some extensions
- MySQL 5.7
- Node.js 8 with NPM
- RabbitMQ
- Redis
- Composer
- phpMyAdmin

## Prerequisites
- [Vagrant](https://www.vagrantup.com/downloads.html)
- Plugin vagrant-vbguest (``vagrant plugin install vagrant-vbguest``)

## How to use
- Run ``vagrant up``
- Add the following lines to your hosts file:
````
192.168.33.10 appsbrewhouse.localdev
192.168.33.10 appsbrewhouse.phpmyadmin.localdev
192.168.33.10 appsbrewhouse.wpsite.localdev
````
- Navigate to ``http://appsbrewhouse.localdev/`` 
- Navigate to ``http://appsbrewhouse.phpmyadmin.localdev/`` (both username and password are 'root')
