# Changelog

All notable changes to this project will be documented in this file.

## Release 1.0.3

**Features**

* Added ufw service refresh when configuration files change ([#6](https://github.com/kogitoapp/puppet-ufw/pull/6))
* Added more acceptance tests ([#7](https://github.com/kogitoapp/puppet-ufw/pull/7))
* Added support for logging level setting ([#8](https://github.com/kogitoapp/puppet-ufw/pull/8))

**Bugfixes**

* No longer attempt to load rules and routes before ufw is installed ([#5](https://github.com/kogitoapp/puppet-ufw/pull/5))

## Release 1.0.2

**Bugfixes**

* Removed stdlib types from `ufw_rule` and `ufw_route` to allow module run on
agent nodes

## Release 1.0.1

**Features**

* Added Debian 8.0 "Jessie", Debian 9.0 "Stretch" to the list of supported systems
* Added Ubuntu 16.04 "Xenial", Ubuntu 20.04 "Focal" to the list of supported systems

## Release 1.0.0

**Features**

* Initial release of the module

## Template

**Features**

**Bugfixes**

**Known Issues**
